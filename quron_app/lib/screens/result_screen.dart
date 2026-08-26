import 'package:flutter/material.dart';
import '../models/surah.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final Surah surah;
  const ResultScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E9F6E),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "🎉",
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Tabriklaymiz!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Manrope',
                    color: Color(0xFF16241F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${surah.name} surasini\nmukammal o'rgandingiz!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5B6B65),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDCEFE6)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        surah.arabicName,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Amiri',
                          color: Color(0xFF0B7A54),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${surah.totalAyahs} oyat — tugatildi!",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5B6B65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E9F6E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Bosh sahifaga qaytish",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
