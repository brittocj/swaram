import 'package:flutter_test/flutter_test.dart';
import 'package:swaram/logic/noise_service.dart';
import 'package:noise_meter/noise_meter.dart';

// A mock class to simulate NoiseReading
class MockNoiseReading implements NoiseReading {
  @override
  final double meanDecibel;
  @override
  final double maxDecibel;

  MockNoiseReading(this.meanDecibel, [double? max]) : maxDecibel = max ?? meanDecibel;
}

void main() {
  group('NoiseService Hold Max Logic Tests', () {
    late NoiseService noiseService;

    setUp(() {
      noiseService = NoiseService();
    });

    test('Hold Max should capture the highest value even after levels drop', () {
      // 1. Initial state
      expect(noiseService.holdMaxDb, 0.0);

      // 2. First reading: 50 dB
      noiseService.processNoiseReading(MockNoiseReading(50.0));
      expect(noiseService.currentDb, 50.0);
      expect(noiseService.holdMaxDb, 50.0);

      // 3. Peak reading: 90 dB
      noiseService.processNoiseReading(MockNoiseReading(90.0));
      expect(noiseService.currentDb, 90.0);
      expect(noiseService.holdMaxDb, 90.0);

      // 4. Lower reading: 40 dB (Hold Max should stay at 90)
      noiseService.processNoiseReading(MockNoiseReading(40.0));
      expect(noiseService.currentDb, 40.0);
      expect(noiseService.holdMaxDb, 90.0);

      // 5. Another lower reading: 65 dB
      noiseService.processNoiseReading(MockNoiseReading(65.0));
      expect(noiseService.holdMaxDb, 90.0);
    });

    test('resetMax should reset Hold Max to current dB', () {
      // 1. Establish a peak
      noiseService.processNoiseReading(MockNoiseReading(80.0));
      noiseService.processNoiseReading(MockNoiseReading(30.0));
      expect(noiseService.holdMaxDb, 80.0);
      expect(noiseService.currentDb, 30.0);

      // 2. Reset
      noiseService.resetMax();
      expect(noiseService.holdMaxDb, 30.0);
    });

    test('calibration should affect currentDb and consequently Hold Max', () {
      noiseService.calibrate(10.0); // +10 dB offset
      
      noiseService.processNoiseReading(MockNoiseReading(50.0));
      
      // raw 50 + 10 = 60
      expect(noiseService.currentDb, 60.0);
      expect(noiseService.holdMaxDb, 60.0);
    });
  });
}
