# Smart Ta'lim — Android ilova

`smartalim.com` saytini ichida ochuvchi Android (WebView) ilova.

- Sayt yangilansa — ilovani yangilash shart emas (barchasi internet orqali).
- Ro'yxatdan o'tish / tizimga kirish saytning `kirish.html` sahifasida amalga oshadi; kirmagan foydalanuvchi hech qanday sahifani ko'ra olmaydi (sayt darvozasi `auth-gate.js` orqali).
- Kirish sessiyasi qurilmada saqlanadi — keyingi ochilishda qayta kirish shart emas.

## Lokal qurish (talablar)

- Node.js (16+)
- Android Studio (JDK 17 bilan) — https://developer.android.com/studio

```bash
npm install
npx cap sync android   # android/ loyihasi allaqachon repo'da bor
npx cap open android   # Android Studio ochiladi
```

Android Studio'da: `Build > Generate Signed App Bundle / APK...`

- **App bundle (.aab)** tanlang — Play Market aynan shuni oladi.
- Yangi keystore yarating (buni xavfsiz saqlang, yo'qolsa ilovani yangilab bo'lmaydi).
- ``uz.smartalim.app`` application ID. Versiya: `versionName` (masalan 1.0.0) va `versionCode`.

## Play Marketga joylash

1. https://play.google.com/console — hisob oching (bir martalik $25).
2. **Create app**: Nomi "Smart Ta'lim", til o'zbek.
3. **Testing > Internal testing** bo'limiga `.aab` faylni yuklang.
4. **Store listing**: tavsif, 512×512 ikona, 1024×500 feature graphic, skrinshotlar (kirish va o'yin sahifalari).
5. **Privacy policy**: `https://smartalim.com/maxfiylik.html`
6. **Data safety** anketasi: Hisob ma'lumotlari (email, ism, parol) yig'iladi; boshqa shaxslarga berilmaydi.
7. **App signing**: Play App Signing yoqish tavsiya etiladi.
8. Skrinshotlar uchun vaqtincha kirishni ochish kerak bo'lsa — avval `auth-gate.js`'ni vaqtincha o'chirib deploy qilishingiz, keyin qayta yoqishingiz mumkin.

Sinovdan o'tkazib, keyinchalik **Production** chiqaring.

## Foydali eslatma

- Ilova hajmi taxminan 5–8 MB (Capacitor + Android).
- Ilovadagi login/tizim to'liq saytdagi Supabase backend bilan ishlaydi — alohida servis kerak emas.