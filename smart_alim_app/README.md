# Smart Ta'lim — smartalim.com ilovasi

`https://smartalim.com` saytining Android (Flutter + WebView) ilovasi. Ilova ochilganda saytning o'zini ko'rsatadi: bosh sahifa, darslar, lug'at, profil va boshqa barcha bo'limlar saytdan keladi.

> **Bu ilova "Qur'on o'rganish" (`smartalim.store`) ilovasidan butunlay alohida.**
> Paket nomi: `uz.smartalim.com`. `.store` ilovasi (`uz.smartalim.store`) bilan umumiy nom, ikonka yoki fayl yo'q.

## Ish prinsipi

- Ishga tushganda `https://smartalim.com` ochiladi.
- **Ovoz:** Android WebView'ning `speechSynthesis` i odatda jim qoladi, shuning uchun har bir sahifa yuklangach `assets/tts_shim.js` dagi ko'prik o'rnatiladi (`lib/main.dart` → `_injectTts`). Ovoz avval **qurilmaning o'z TTS dvigateliga** (Android TextToSpeech, `MainActivity.kt` dagi `uz.smartalim.com/tts` kanali) uzatiladi — bu oflayn ham ishlaydi. Dvigatelda til ovozi bo'lmasa, zaxira sifatida Google TTS audio fayli ishlatiladi (internet talab qiladi).
- **Orqaga tugmasi:** avval sayt ichida oldingi sahifaga qaytadi; bosh sahifada esa ilovadan chiqmaydi — fon rejimiga o'tadi (`MainActivity` dagi method channel orqali).
- Internet yo'q bo'lsa, "Internet aloqasi yo'q" ekrani va "Qayta urinish" tugmasi ko'rsatiladi.
- Sayt sessiyasi (Supabase login) WebView'ning DOM storage'ida saqlanadi — ilova yopilsa ham hisob ochiq qoladi.

## Qurish

Talablar: Flutter 3.47+ va Android SDK.

```powershell
flutter pub get
flutter build apk --release   # imzolangan APK
flutter build apk --debug     # sinov uchun APK
```

Tayyor fayllar:

- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/flutter-apk/app-debug.apk`

Reliz nusxalari `release/` papkasiga ko'chiriladi:

- `release/SmartTalim-1.1.0.apk` — imzolangan (tarqatish uchun)
- `release/SmartTalim-1.1.0-test.apk` — debug (telefonga tez o'rnatish uchun)

## Imzolash

`android/keystore.properties` va `android/keystore/smartalim-upload.jks` ishlatiladi (git'ga qo'shilmaydi). Fayllar mavjud bo'lmasa, release debug kaliti bilan imzolanadi.

## Versiya

`pubspec.yaml` → `version: 1.1.0+2` (nom+versiya). Har yangilanishda `+` dan keyingi raqamni (versionCode) oshiring.
## Saytga joylashtirish (yuklab olish sahifasi)

Ilova smartalim.com saytidan yuklab olinadi. Sayt ildizida (repo ildizida) quyidagi fayllar turadi:

- `ilova.html` - yuklab olish sahifasi (o'zbek tilida, o'rnatish yo'riqnomasi bilan)
- `ilova-icon.png` - ilova ikonkasi (192px)
- `smart-talim.apk` - `release/SmartTalim-<versiya>.apk` nusxasi (42 MB)

Bosh sahifadagi (`index.html`) "Bo'limlar" ro'yxatida "Ilova (Android)" kartochkasi `ilova.html` ga havola qiladi.

Yangi versiya chiqqanda `release/SmartTalim-<yangi>.apk` ni `smart-talim.apk` ustiga nusxalab, saytga qayta yuklang (havola o'zgarmaydi). APK **o'sha keystore** bilan imzolanishi shart, aks holda eski ilova ustiga yangilanmaydi. `ilova.html` dagi versiya va o'lcham yozuvini ham yangilang.
