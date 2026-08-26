import 'package:flutter/material.dart';
import '../models/surah.dart';
import 'result_screen.dart';

class LearnScreen extends StatefulWidget {
  final Surah surah;
  const LearnScreen({super.key, required this.surah});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late Ayah currentAyah;
  late List<String> poolLetters;
  List<String?> placedLetters = [];
  int nextSlotIndex = 0;
  bool completed = false;
  int attemptCount = 0;

  @override
  void initState() {
    super.initState();
    currentAyah = widget.surah.ayahs.first;
    _initLevel();
  }

  void _initLevel() {
    final clean = currentAyah.cleanLetters;
    placedLetters = List.filled(clean.length, null);
    poolLetters = List.from(clean);
    poolLetters.shuffle();
    nextSlotIndex = 0;
    completed = false;
    attemptCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSurahHeader(),
            _buildAyahDisplay(),
            const SizedBox(height: 12),
            _buildSlotArea(),
            const SizedBox(height: 12),
            _buildPoolArea(),
            const Spacer(),
            _buildControls(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Qur'on o'rganish",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Manrope',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E9F6E), Color(0xFF0B7A54)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            widget.surah.arabicName,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Amiri',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.surah.name,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Oyat ${currentAyah.number} / ${widget.surah.totalAyahs}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCEFE6)),
      ),
      child: Column(
        children: [
          const Text(
            "OYAT MATNI",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5B6B65),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            currentAyah.arabicText,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B7A54),
              fontFamily: 'Amiri',
              height: 1.8,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSlotArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "HARFLARNI SHU YERGA QO'YING",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5B6B65),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: completed ? const Color(0xFF22c55e) : const Color(0xFFDCEFE6),
                width: completed ? 2 : 1,
              ),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: List.generate(placedLetters.length, (i) {
                return _buildSlot(i);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(int index) {
    final letter = placedLetters[index];
    final isFilled = letter != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isFilled ? const Color(0xFF0E9F6E) : const Color(0xFFD8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFilled ? const Color(0xFF0E9F6E) : const Color(0xFFDCEFE6),
          width: isFilled ? 0 : 2,
        ),
      ),
      child: Center(
        child: Text(
          letter ?? '',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isFilled ? Colors.white : const Color(0xFF0B7A54),
            fontFamily: 'Amiri',
          ),
        ),
      ),
    );
  }

  Widget _buildPoolArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MAVJUD HARFLAR — BOSING",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5B6B65),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCEFE6)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(poolLetters.length, (i) {
                return _buildPoolLetter(i);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoolLetter(int index) {
    final letter = poolLetters[index];
    if (letter == ' ') {
      return const SizedBox(width: 12);
    }

    final isUsed = _isLetterUsed(index);

    return GestureDetector(
      onTap: isUsed ? null : () => _placeLetter(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isUsed ? const Color(0xFFE5E7EB) : const Color(0xFFD8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUsed ? const Color(0xFFD1D5DB) : const Color(0xFFDCEFE6),
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isUsed ? const Color(0xFF9CA3AF) : const Color(0xFF16241F),
              fontFamily: 'Amiri',
            ),
          ),
        ),
      ),
    );
  }

  bool _isLetterUsed(int poolIndex) {
    int letterIdx = 0;
    for (int i = 0; i < poolLetters.length; i++) {
      if (poolLetters[i] == ' ') continue;
      if (i == poolIndex) break;
      letterIdx++;
    }
    return placedLetters[letterIdx] != null;
  }

  void _placeLetter(int poolIndex) {
    if (nextSlotIndex >= placedLetters.length) return;

    setState(() {
      final letter = poolLetters[poolIndex];
      placedLetters[nextSlotIndex] = letter;
      nextSlotIndex++;
      attemptCount++;
    });

    _checkComplete();
  }

  void _checkComplete() {
    final allFilled = placedLetters.every((l) => l != null);
    if (allFilled) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    final correct = currentAyah.cleanLetters;
    bool allCorrect = true;

    for (int i = 0; i < correct.length; i++) {
      if (placedLetters[i] != correct[i]) {
        allCorrect = false;
        break;
      }
    }

    setState(() => completed = allCorrect);

    if (allCorrect) {
      _showSuccess();
    } else {
      _showError();
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Mukammal! To'g'ri o'qindingiz!",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF22c55e),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Xato bor — qayta urinib ko'ring!",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFef4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetLevel() {
    setState(() {
      _initLevel();
    });
  }

  void _nextAyah() {
    final ayahs = widget.surah.ayahs;
    final currentIndex = ayahs.indexOf(currentAyah);

    if (currentIndex < ayahs.length - 1) {
      setState(() {
        currentAyah = ayahs[currentIndex + 1];
        _initLevel();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(surah: widget.surah),
        ),
      );
    }
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetLevel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFDCEFE6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Qayta boshlash",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16241F),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: completed ? _nextAyah : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E9F6E),
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                completed ? "Keyingi oyat" : "To'g'ri bosing",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
