import 'package:flutter/material.dart';
import '../data/surahs_data.dart';
import '../models/surah.dart';
import 'learn_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: SurahsData.surahs.length,
                itemBuilder: (ctx, i) => _surahCard(ctx, SurahsData.surahs[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E9F6E), Color(0xFF0B7A54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                "﷽",
                style: TextStyle(fontSize: 28, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Qur'on o'rganish",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Harflarni surtib o'rganing",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _surahCard(BuildContext context, Surah surah) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LearnScreen(surah: surah)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCEFE6)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFD8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "${surah.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B7A54),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${surah.totalAyahs} oyat",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5B6B65),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              surah.arabicName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B7A54),
                fontFamily: 'Amiri',
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF5B6B65),
            ),
          ],
        ),
      ),
    );
  }
}
