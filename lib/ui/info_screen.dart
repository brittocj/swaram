import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../theme/stitch_theme.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ABOUT SWARAM',
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Branding
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: StitchColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: StitchColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.info_outline, color: StitchColors.primary, size: 40),
                ),
                const SizedBox(height: 32),
                Text(
                  'G9 Inc.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: StitchColors.g9Blue,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 48),
                // Description
                Text(
                  'Swaram is a high-precision sound measurement tool designed specifically for audio professionals and studio environments. We believe in empowering creators with professional-grade diagnostics, which is why Swaram is offered as a fully complimentary tool with no hidden costs or professional tier restrictions.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: StitchColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 60),
                _buildPermissionSection(),
                const SizedBox(height: 60),
                // Buttons
                _buildActionButton(
                  label: 'CONTACT SUPPORT',
                  icon: Icons.mail_outline,
                  onTap: () => launchUrlString('mailto:info@g9clouds.com'),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  label: 'SHARE SWARAM',
                  icon: Icons.ios_share,
                  onTap: () => Share.share('Check out Swaram - Professional Decibel Meter for your android device!'),
                ),
                const SizedBox(height: 48),
                // Version
                Text(
                  'VERSION 0.1',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF444444),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2128).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: StitchColors.primary, size: 18),
              const SizedBox(width: 12),
              Text(
                'REQUIRED PERMISSIONS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPermissionItem(
            Icons.mic_none,
            'Microphone',
            'Used to capture real-time ambient sound levels. Swaram does not record or transmit audio data.',
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            Icons.location_on_outlined,
            'Location',
            'Used to tag noise measurements with GPS coordinates for spatial analysis and logging.',
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: StitchColors.textSecondary, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: StitchColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: StitchColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: StitchColors.primary, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
