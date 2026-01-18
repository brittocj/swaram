import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../logic/noise_service.dart';
import '../theme/stitch_theme.dart';
import '../widgets/gauge_painter.dart';
import '../screens/calibration_screen.dart';
import '../screens/coming_soon_screen.dart';
import '../ui/info_screen.dart';
import 'history_screen.dart';

class MeterScreen extends StatefulWidget {
  const MeterScreen({super.key});

  @override
  State<MeterScreen> createState() => _MeterScreenState();
}

class _MeterScreenState extends State<MeterScreen> with SingleTickerProviderStateMixin {
  late final NoiseService _noiseService;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _noiseService = NoiseService();
    _initNoiseService();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  Future<void> _initNoiseService() async {
    await _noiseService.start();
  }

  @override
  void dispose() {
    _noiseService.stop();
    _noiseService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getNoiseCategory(double db) {
    if (db < 30) return 'Silent';
    if (db < 45) return 'Quiet';
    if (db < 60) return 'Conversation';
    if (db < 75) return 'Noisy';
    if (db < 90) return 'Danger';
    if (db < 105) return 'Loss';
    return 'Damage';
  }

  Color _getCategoryColor(double db) {
    if (db < 45) return StitchColors.silent;
    if (db < 60) return StitchColors.moderate;
    if (db < 75) return StitchColors.noisy;
    if (db < 90) return StitchColors.danger;
    return StitchColors.damage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedBuilder(
                animation: _noiseService,
                builder: (context, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGaugeSection(),
                        _buildReadoutSection(),
                        _buildStatsRow(),
                        _buildLiveHistory(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SWARAM',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 0,
                  color: Colors.white,
                ),
              ),
              Text(
                'SOUND ANALYSIS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: StitchColors.textSecondary,
                ),
              ),
            ],
          ),
          PopupMenuButton<int>(
            offset: const Offset(0, 50),
            color: const Color(0xFF1A1D24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.settings, color: Color(0xFF64748B), size: 20),
            ),
            onSelected: (value) {
              if (value == 0) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalibrationScreen()));
              } else if (value == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ComingSoonScreen(title: 'Stats')));
              } else if (value == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ComingSoonScreen(title: 'Logs')));
              } else if (value == 3) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoScreen()));
              }
            },
            itemBuilder: (context) => [
              _buildPopupItem(0, Icons.tune, 'Calibrate'),
              _buildPopupItem(1, Icons.analytics_outlined, 'Stats'),
              _buildPopupItem(2, Icons.history, 'Logs'),
              _buildPopupItem(3, Icons.info_outline, 'Info'),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<int> _buildPopupItem(int value, IconData icon, String label) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeSection() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 280,
            height: 160,
            child: CustomPaint(
              painter: GaugePainter(value: _noiseService.currentDb),
            ),
          ),
          // Labels (Silent, Quiet, Whisper, etc.)
          _buildGaugeLabel('SILENT', -165, 0.8),
          _buildGaugeLabel('QUIET', -130, 0.85),
          _buildGaugeLabel('WHISPER', -100, 0.9),
          _buildGaugeLabel('NORMAL', -75, 0.9),
          _buildGaugeLabel('NOISY', -45, 0.9),
          _buildGaugeLabel('DANGER', -15, 0.9, color: Colors.red.withOpacity(0.8)),
          _buildGaugeLabel('DAMAGE', 15, 0.8, color: Colors.red.withOpacity(0.8)),
        ],
      ),
    );
  }

  Widget _buildGaugeLabel(String text, double angleDeg, double distScale, {Color? color}) {
    final angle = angleDeg * pi / 180;
    final r = 140.0 * distScale; // Adjusted for 280 width
    return Positioned(
      left: 140 + r * cos(angle) - 20,
      top: 160 + r * sin(angle), // Balanced with gauge center Y (160)
      child: Transform.rotate(
        angle: angle + pi/2,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 8, // Slightly smaller
            fontWeight: FontWeight.bold,
            color: color ?? StitchColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildReadoutSection() {
    final db = _noiseService.currentDb;
    final category = _getNoiseCategory(db);
    final color = _getCategoryColor(db);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              db.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: 72, // Reduced from 88
                fontWeight: FontWeight.w200,
                color: Colors.white,
                letterSpacing: -3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 4),
              child: Text(
                'dB',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: StitchColors.textSecondary.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            category.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('MIN', _noiseService.sessionMinDb.toStringAsFixed(1)),
        _buildDivider(),
        _buildStatItem('AVG', _noiseService.sessionAvgDb.toStringAsFixed(1), isMain: true),
        _buildDivider(),
        _buildStatItem('MAX', _noiseService.sessionMaxDb.toStringAsFixed(1)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, {bool isMain = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
            color: StitchColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isMain ? 20 : 18,
            fontWeight: isMain ? FontWeight.w600 : FontWeight.w400,
            color: isMain ? Colors.white : StitchColors.textDark.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildLiveHistory() {
    return Container(
      height: 140, // Slightly taller for the sparkline
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24).withOpacity(0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0), // Padding for titles if any
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LIVE TREND',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: StitchColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    FadeTransition(
                      opacity: _pulseController,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: StitchColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'REALTIME',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: StitchColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 99,
                  minY: 0,
                  maxY: 120,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(),
                      isCurved: true,
                      color: StitchColors.primary,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            StitchColors.primary.withOpacity(0.2),
                            StitchColors.primary.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots() {
    final history = _noiseService.history;
    final List<FlSpot> spots = [];
    
    // Fill with zero if history is short
    int offset = 100 - history.length;
    for (int i = 0; i < offset; i++) {
      spots.add(FlSpot(i.toDouble(), 0));
    }
    
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot((offset + i).toDouble(), history[i]));
    }
    
    return spots;
  }

}
