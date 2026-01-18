import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import '../models/session.dart';

class NoiseService extends ChangeNotifier {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  final DatabaseService _dbService = DatabaseService();

  double _currentDb = 0.0;
  double _holdMaxDb = 0.0;
  double _calibrationOffset = 0.0;
  
  // Singleton pattern to ensure persistent calibration state
  static final NoiseService _instance = NoiseService._internal();
  factory NoiseService() => _instance;
  NoiseService._internal() {
    _loadCalibration();
  }

  Future<void> _loadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    _calibrationOffset = prefs.getDouble('calibration_offset') ?? 0.0;
    notifyListeners();
  }

  // Session tracking
  double _sessionSumDb = 0.0;
  int _sessionCount = 0;
  double _sessionMaxDb = 0.0;
  double _sessionMinDb = 120.0;
  
  final List<double> _history = [];
  final int _maxHistoryPoints = 100;
  bool _isRecording = false;
  bool _isPermissionGranted = false;

  /// Returns whether permissions are granted.
  bool get isPermissionGranted => _isPermissionGranted;

  /// Returns the current decibel level adjusted by the calibration offset.
  double get currentDb => _currentDb + _calibrationOffset;

  /// Returns the raw db without calibration
  double get rawDb => _currentDb;

  /// Returns the maximum decibel level recorded since the last reset or start.
  double get holdMaxDb => _holdMaxDb;

  /// Returns the current calibration offset.
  double get calibrationOffset => _calibrationOffset;

  /// Returns the session average dB.
  double get sessionAvgDb => _sessionCount > 0 ? _sessionSumDb / _sessionCount : 0.0;

  /// Returns the session max dB.
  double get sessionMaxDb => _sessionMaxDb;

  /// Returns the session min dB.
  double get sessionMinDb => _sessionCount > 0 ? _sessionMinDb : 0.0;

  /// Returns a list of the last 100 data points for the history chart.
  List<double> get history => List.unmodifiable(_history);

  /// Returns whether the noise meter is currently recording.
  bool get isRecording => _isRecording;

  /// Starts the noise meter stream after checking permissions.
  Future<void> start() async {
    if (_isRecording) return;

    // Explicitly request permissions on the UI thread before starting
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.location,
    ].request();

    if (statuses[Permission.microphone] != PermissionStatus.granted) {
      debugPrint('Microphone permission denied');
      return;
    }

    _isPermissionGranted = true;
    _sessionSumDb = 0.0;
    _sessionCount = 0;
    _sessionMaxDb = 0.0;
    _sessionMinDb = 120.0;

    _noiseMeter ??= NoiseMeter();
    _noiseSubscription = _noiseMeter!.noise.listen(
      (NoiseReading noiseReading) {
        processNoiseReading(noiseReading);
      },
      onError: (Object error) {
        debugPrint('NoiseMeter Error: ${error.toString()}');
        stop();
      },
    );
    _isRecording = true;
    notifyListeners();
  }

  /// Stops the noise meter stream.
  void stop() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _isRecording = false;
    notifyListeners();
  }

  @visibleForTesting
  void processNoiseReading(NoiseReading noiseReading) {
    // raw reading
    double rawDb = noiseReading.meanDecibel;
    
    // Safety check for invalid input
    if (!rawDb.isFinite || rawDb < 0) {
      return;
    }
    
    _currentDb = rawDb;

    // Adjusted reading for storage and max hold
    double adjustedDb = currentDb;

    // Session stats
    _sessionSumDb += adjustedDb;
    _sessionCount++;
    
    if (_sessionCount == 1) {
      _sessionMaxDb = adjustedDb;
      _sessionMinDb = adjustedDb;
    } else {
      if (adjustedDb > _sessionMaxDb) {
        _sessionMaxDb = adjustedDb;
      }
      if (adjustedDb < _sessionMinDb) {
        _sessionMinDb = adjustedDb;
      }
    }

    // Update Hold Max
    if (adjustedDb > _holdMaxDb) {
      _holdMaxDb = adjustedDb;
    }

    // Update history
    _history.add(adjustedDb);
    if (_history.length > _maxHistoryPoints) {
      _history.removeAt(0);
    }

    notifyListeners();
  }

  Future<void> saveSession() async {
    if (_sessionCount == 0) return;

    double avgDb = _sessionSumDb / _sessionCount;
    double maxDb = _sessionMaxDb;
    
    Position? position;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }

    final session = NoiseSession(
      averageDb: avgDb,
      peakDb: maxDb,
      timestamp: DateTime.now(),
      latitude: position?.latitude ?? 0.0,
      longitude: position?.longitude ?? 0.0,
    );

    await _dbService.insertSession(session);
    
    // Reset session stats for next one
    _sessionSumDb = 0.0;
    _sessionCount = 0;
    _sessionMaxDb = 0.0;
    notifyListeners();
  }

  /// Adjusts the raw dB reading by a specified offset and persists it.
  Future<void> calibrate(double offset) async {
    _calibrationOffset = offset;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calibration_offset', offset);
    notifyListeners();
  }

  /// Resets the 'Hold Max' variable to the current dB level.
  void resetMax() {
    _holdMaxDb = currentDb;
    notifyListeners();
  }

  @override
  void dispose() {
    // Singleton should not really be disposed like this, but if it is:
    stop();
    super.dispose();
  }
}
