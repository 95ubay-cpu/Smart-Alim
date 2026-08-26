class Surah {
  final int id;
  final String name;
  final String arabicName;
  final int totalAyahs;
  final List<Ayah> ayahs;

  const Surah({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.totalAyahs,
    required this.ayahs,
  });
}

class Ayah {
  final int number;
  final String arabicText;
  final List<String> letters;

  const Ayah({
    required this.number,
    required this.arabicText,
    required this.letters,
  });

  List<String> get cleanLetters =>
      letters.where((l) => l.trim().isNotEmpty).toList();
}
