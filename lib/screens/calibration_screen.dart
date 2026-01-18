import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/noise_service.dart';
import '../theme/stitch_theme.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  late final NoiseService _noiseService;

  @override
  void initState() {
    super.initState();
    _noiseService = NoiseService();
  }

  void _adjustOffset(double delta) {
    _noiseService.calibrate(_noiseService.calibrationOffset + delta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CALIBRATE',
          style: GoogleFonts.inter(
            fontSize: 16,
            letterSpacing: 4,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _noiseService,
        builder: (context, _) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildLiveSection(),
                    const SizedBox(height: 60),
                    _buildAdjustmentSection(),
                    const SizedBox(height: 60),
                    _buildResetButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: StitchColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            'CURRENT READING',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: StitchColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _noiseService.currentDb.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  color: StitchColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'dB',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: StitchColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallInfo('RAW', '${_noiseService.rawDb.toStringAsFixed(1)} dB'),
              Container(width: 1, height: 20, color: Colors.white.withOpacity(0.05)),
              _buildSmallInfo('OFFSET', '${_noiseService.calibrationOffset > 0 ? "+" : ""}${_noiseService.calibrationOffset.toStringAsFixed(1)} dB'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: StitchColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentSection() {
    return Column(
      children: [
        Text(
          'MANUAL CALIBRATION',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildRoundButton(Icons.remove, () => _adjustOffset(-1.0), isLarge: true),
            _buildRoundButton(Icons.remove, () => _adjustOffset(-0.1)),
            Column(
              children: [
                Text(
                  _noiseService.calibrationOffset.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'dB OFFSET',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: StitchColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            _buildRoundButton(Icons.add, () => _adjustOffset(0.1)),
            _buildRoundButton(Icons.add, () => _adjustOffset(1.0), isLarge: true),
          ],
        ),
        const SizedBox(height: 48),
        Text(
          'Industry Standard: Calibrate against a 94.0 dB or 114.0 dB reference tone to ensure acoustic accuracy.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: StitchColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onTap, {bool isLarge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 16 : 12),
        decoration: BoxDecoration(
          color: StitchColors.cardDark,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isLarge ? Colors.white : StitchColors.primary,
          size: isLarge ? 24 : 18,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return TextButton(
      onPressed: () => _noiseService.calibrate(0.0),
      child: Text(
        'RESET CALIBRATION',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.redAccent.withOpacity(0.7),
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
