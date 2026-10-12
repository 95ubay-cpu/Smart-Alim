# Qur'on — Android ilova

`smartalim.store` saytini ochuvchi Android (Capacitor WebView) ilova. Ilova saytning o'zi kabi ishlaydi: bosh sahifa — Qur'on o'rganish (sura tanlash, arab alifbosi, TTS ovoz), boshqa sahifalar saytdan ko'rsatiladi.

> **Alohida ilova:** paket nomi `uz.smartalim.quron`. Saytni ochuvchi eski "Smart Ta'lim" ilovasi (`uz.smartalim.app`) bundan alohida — ikkalasi telefonda birga turadi.

## Ish prinsipi

- Ilova ishga tushganda `https://smartalim.store` saytini ochadi (`capacitor.config.json` → `server.url`).
- Ovoz uchun native TTS (`MainActivity` → `SmartAlimTts`) mavjud — saytdagi `tts.js` avval undan foydalanadi, agar bo'lmasa brauzer/Google TTS zaxira bo'ladi.
- `www/index.html` faqat zaxira (ofsayt holatida saytga yo'naltiradi). Alohida oflayn menular/suralar yo'q — ilova saytning o'zi kabi ishlaydi.

## Qurish (talablar)

- Node.js (16+)
- Android Studio (JDK 17 bilan) — https://developer.android.com/studio

```bash
npm install
npx cap sync android   # www ni android/ loyihasiga nusxalaydi
npx cap open android   # Android Studio ochiladi
```

Android Studio yoki CLI orqali qurish:

```bash
# Windows (Android Studio JBR misolida)
$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'
$env:ANDROID_HOME="$env:LOCALAPPDATA\Android\Sdk"
.\gradlew.bat assembleRelease   # android/ papkasida
```

Imzolangan APK: `android\app\build\outputs\apk\release\app-release.apk` (imzo `android/keystore/`). Tayyor artefaktlar `release/` papkasida (`Quron-<versiya>.apk` — ushbu Qur'on ilovasi; `Smart-Alim-<versiya>-test.apk` — eski sayt-ilova uchun).

## Play Marketga joylash

1. https://play.google.com/console — hisob oching (bir martalik $25).
2. **Create app**: Nomi "Qur'on", til o'zbek.
3. **Testing > Internal testing** bo'limiga imzolangan `aab`/`apk` yuklang (Play App Signing uchun `bundleRelease` tavsiya etiladi).
4. **Store listing**: tavsif, 512×512 ikona, 1024×500 feature graphic, skrinshotlar.
5. **Privacy policy**: `https://smartalim.com/maxfiylik.html`
6. **App signing**: Play App Signing yoqilgan bo'lsa — upload keystore (`smartalim-upload.jks`) Play konsolga beriladi, mahalliy `release` imzosi bilan Play o'rtasida farqga e'tibor bering.

## Versiya

`android/app/build.gradle` — `versionCode` / `versionName` (hozir 1.1.0). Har yangilanishda `versionCode` ni oshiring.