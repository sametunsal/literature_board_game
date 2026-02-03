import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/managers/audio_manager.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  double _bgmVolume = 0.5; // Default fallback
  double _sfxVolume = 1.0; // Default fallback

  @override
  void initState() {
    super.initState();
    _bgmVolume = AudioManager.instance.bgmVolume;
    _sfxVolume = AudioManager.instance.sfxVolume;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00695C); // Deep Teal
    const accentColor = Color(0xFFD4AF37); // Metallic Gold
    const bgColor = Color(0xFFF9F7F2); // Warm Cream

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: accentColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, color: primaryColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  "AYARLAR",
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // BGM Slider
            _buildVolumeSection(
              label: "Müzik Sesi",
              icon: Icons.music_note_rounded,
              value: _bgmVolume,
              primaryColor: primaryColor,
              accentColor: accentColor,
              onChanged: (val) {
                setState(() => _bgmVolume = val);
                AudioManager.instance.setBgmVolume(val);
              },
            ),

            const SizedBox(height: 20),

            // SFX Slider
            _buildVolumeSection(
              label: "Efekt Sesleri",
              icon: Icons.volume_up_rounded,
              value: _sfxVolume,
              primaryColor: primaryColor,
              accentColor: accentColor,
              onChanged: (val) {
                setState(() => _sfxVolume = val);
                AudioManager.instance.setSfxVolume(val);
              },
            ),

            const SizedBox(height: 24),

            // Language Section (Disabled Look)
            Opacity(
              opacity: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.language_rounded,
                        size: 20,
                        color: primaryColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Dil Seçeneği",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Türkçe",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Section
            Center(
              child: Column(
                children: [
                  Text(
                    "Edebina v1.0",
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    "Developed by Antigravity",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Close Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "TAMAM",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSection({
    required String label,
    required IconData icon,
    required double value,
    required Color primaryColor,
    required Color accentColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: primaryColor.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const Spacer(),
            Text(
              "${(value * 100).toInt()}%",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: accentColor,
            inactiveTrackColor: primaryColor.withValues(alpha: 0.1),
            thumbColor: accentColor,
            overlayColor: accentColor.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}
