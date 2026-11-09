/* Smart Ta'lim ilovasi uchun ovoz ko'prigi.
   Android WebView'ning speechSynthesis'i odatda ovoz chiqarmaydi, shuning uchun
   avval qurilmaning o'z TTS dvigateliga (native) uzatamiz, u ishlamasa —
   internet orqali Google ovoz fayliga o'tamiz.
   Saytning tts.js i ham, to'g'ridan-to'g'ri speechSynthesis ishlatadigan
   sahifalari ham shu qatlam orqali ovoz chiqaradi. */
(function () {
  if (window.__smartTtsShimInstalled) {
    // Keyingi sahifalarda til ro'yxati yangilangan bo'lishi mumkin.
    try {
      if (typeof window.__smartSetTtsLangs === 'function') {
        window.__smartSetTtsLangs(__SMART_TTS_LANGS__);
      }
    } catch (e) {}
    return;
  }
  window.__smartTtsShimInstalled = true;

  // Ilova tomonidan to'ldiriladi: qurilma TTS i qo'llab-quvvatlaydigan tillar.
  var NATIVE_LANGS = __SMART_TTS_LANGS__;
  window.__smartSetTtsLangs = function (list) {
    if (list && list.length) NATIVE_LANGS = list;
  };
  var bridge = window.SmartTtsBridge;

  var audioEl = null;

  function getAudio() {
    if (!audioEl) {
      audioEl = document.createElement('audio');
      audioEl.setAttribute('playsinline', '');
      audioEl.preload = 'auto';
      (document.body || document.documentElement).appendChild(audioEl);
    }
    return audioEl;
  }

  function normLang(lang) {
    var full = (lang || 'en').trim() || 'en';
    var base = full.split('-')[0].toLowerCase();
    if (base === 'ar') return 'ar';
    return full;
  }

  function urlsFor(text, lang) {
    var full = normLang(lang);
    var q = text.length > 180 ? text.slice(0, 180) : text;
    var base = full.split('-')[0].toLowerCase();
    var extra = '&total=1&idx=0&textlen=' + q.length;
    var urls = [
      'https://translate.googleapis.com/translate_tts?ie=UTF-8&client=gtx&tl=' +
        encodeURIComponent(full) + '&q=' + encodeURIComponent(q) + extra,
      'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=' +
        encodeURIComponent(full) + '&q=' + encodeURIComponent(q) + extra
    ];
    // Nemis va fransuz uchun qo'shimcha manba (Google ishlamasa).
    if (base === 'de' || base === 'fr') {
      urls.push('https://dict.youdao.com/dictvoice?le=' + base +
        '&audio=' + encodeURIComponent(q));
    }
    return urls;
  }

  function playOne(url, onFail) {
    var a = getAudio();
    var settled = false;
    function cleanup() {
      a.removeEventListener('error', onError);
      a.removeEventListener('playing', onOk);
    }
    function onError() {
      if (settled) return;
      settled = true;
      cleanup();
      onFail();
    }
    function onOk() {
      if (settled) return;
      settled = true;
      cleanup();
    }
    a.addEventListener('error', onError);
    a.addEventListener('playing', onOk);
    try {
      a.src = url;
      a.volume = 1;
      var p = a.play();
      if (p && p.catch) p.catch(onError);
    } catch (e) {
      onError();
    }
  }

  function gtts(text, lang) {
    var urls = urlsFor(text, lang);
    var i = 0;
    function next() {
      if (i >= urls.length) return;
      playOne(urls[i++], next);
    }
    next();
    return true;
  }

  function langSupported(lang) {
    if (!NATIVE_LANGS || !NATIVE_LANGS.length) return true;
    var full = (lang || 'en').toLowerCase();
    var base = full.split('-')[0];
    for (var i = 0; i < NATIVE_LANGS.length; i++) {
      var l = String(NATIVE_LANGS[i]).toLowerCase();
      if (l === full || l === base) return true;
    }
    return false;
  }

  var lastNative = null;

  function nativeSpeak(text, lang) {
    if (!bridge || !bridge.postMessage) return false;
    var s = (text == null) ? '' : String(text);
    if (!s.trim()) return false;
    if (!langSupported(lang)) return false;
    lastNative = { text: s, lang: lang || 'en-US' };
    try {
      bridge.postMessage(JSON.stringify({
        action: 'speak',
        text: s,
        lang: lang || 'en-US'
      }));
      return true;
    } catch (e) {
      lastNative = null;
      return false;
    }
  }

  // Ilova tomonidan chaqiriladi: qurilma TTS i ovozni chiqara olmadi
  // (til ovozi o'rnatilmagan va h.k.) — onlayn zaxiraga o'tamiz.
  window.__smartTtsNativeFailed = function () {
    var pending = lastNative;
    lastNative = null;
    if (pending) gtts(pending.text, pending.lang);
  };

  function speak(text, lang) {
    var s = (text == null) ? '' : String(text);
    if (!s.trim()) return false;
    if (nativeSpeak(s, lang)) return true;
    return gtts(s, lang || 'en');
  }

  var realSynth = null;
  try { realSynth = window.speechSynthesis; } catch (e) {}

  function stop() {
    lastNative = null;
    try { audioEl && audioEl.pause(); } catch (e) {}
    if (bridge && bridge.postMessage) {
      try { bridge.postMessage(JSON.stringify({ action: 'stop' })); } catch (e) {}
    }
    if (realSynth && realSynth.cancel) {
      try { realSynth.cancel(); } catch (e) {}
    }
  }

  // 1) Saytning o'z tts.js i `SmartAlimTts` ni ko'rsa, to'g'ridan-to'g'ri
  //    native dvigatelga murojaat qiladi.
  try {
    window.SmartAlimTts = {
      isReady: function () { return true; },
      speak: function (text, lang) { return nativeSpeak(text, lang); },
      stop: function () { stop(); }
    };
  } catch (e) {}

  function Utt(text) {
    this.text = (text == null) ? '' : String(text);
    this.lang = '';
    this.rate = 1;
    this.pitch = 1;
    this.volume = 1;
    this.voice = null;
    this.onstart = null;
    this.onend = null;
    this.onerror = null;
  }
  if (typeof window.SpeechSynthesisUtterance === 'undefined') {
    window.SpeechSynthesisUtterance = Utt;
  }

  // 2) speechSynthesis ni almashtiramiz: sahifalar to'g'ridan-to'g'ri
  //    speechSynthesis.speak() chaqirsa ham ovoz chiqadi.
  var shim = {
    getVoices: function () {
      try {
        return (realSynth && realSynth.getVoices) ? realSynth.getVoices() : [];
      } catch (e) {
        return [];
      }
    },
    cancel: function () { stop(); },
    speak: function (u) {
      try {
        if (!u || !u.text) return;
        // tts.js onstart ni kutadi — darhol xabar beramiz, aks holda u
        // 1 soniyadan keyin yana bir marta ovoz qo'yadi.
        if (typeof u.onstart === 'function') {
          try { u.onstart(); } catch (e) {}
        }
        speak(u.text, u.lang || 'en-US');
      } catch (e) {}
    },
    pause: function () {},
    resume: function () {},
    addEventListener: function () {},
    removeEventListener: function () {},
    dispatchEvent: function () { return false; },
    speaking: false,
    pending: false,
    paused: false,
    onvoiceschanged: null
  };

  try {
    Object.defineProperty(window, 'speechSynthesis', {
      configurable: true,
      get: function () { return shim; }
    });
  } catch (e) {
    try { window.speechSynthesis = shim; } catch (e2) {}
  }

  // 3) tts.js sahifa yuklanganda `SmartAlimTts` ni ko'rmagan bo'lsa, uning
  //    global obyektini ham native yo'liga o'giramiz.
  try {
    var orig = window.smartTTS;
    if (orig && typeof orig.speak === 'function' && !orig.__smartNativeWrapped) {
      window.smartTTS = {
        speak: function (text, lang) { return speak(text, lang); },
        stop: function () {
          stop();
          if (typeof orig.stop === 'function') {
            try { orig.stop(); } catch (e) {}
          }
        },
        hasNative: true,
        nativeReady: function () { return true; },
        __smartNativeWrapped: true
      };
    }
  } catch (e) {}
})();
