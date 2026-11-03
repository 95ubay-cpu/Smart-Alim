/* Smart Ta'lim — ovoz yordamchisi.
   Ketma-ketlik: ilova native TTS -> brauzer speechSynthesis (tegishli ovoz bo'lsa) ->
   xitoy uchun Youdao -> Google ovoz fayli (zaxira). */
window.smartTTS = (function() {
  var native = (typeof window.SmartAlimTts !== 'undefined') ? window.SmartAlimTts : null;
  var audioEl = null;

  function nativeReady() {
    try { return !!native && !!native.isReady && native.isReady(); } catch (e) { return false; }
  }

  function normLang(lang) {
    var l = (lang || 'en').trim();
    var lower = l.toLowerCase();
    if (lower === 'zh' || lower === 'zh-cn' || lower === 'zh-hans') return 'zh-CN';
    if (lower === 'zh-tw' || lower === 'zh-hant') return 'zh-TW';
    return l;
  }

  function getAudio() {
    if (!audioEl) {
      audioEl = document.createElement('audio');
      audioEl.setAttribute('playsinline', '');
      audioEl.preload = 'auto';
      document.body.appendChild(audioEl);
    }
    return audioEl;
  }

  function urlsFor(text, lang) {
    var full = normLang(lang);
    var base = full.split('-')[0].toLowerCase();
    var q = text.length > 180 ? text.slice(0, 180) : text;
    var urls = [];
    if (base === 'zh' || base === 'ja') {
      urls.push('https://dict.youdao.com/dictvoice?le=' + base + '&audio=' + encodeURIComponent(q));
    }
    urls.push('https://translate.googleapis.com/translate_tts?client=gtx&ie=UTF-8&tl=' +
              encodeURIComponent(full) + '&q=' + encodeURIComponent(q));
    urls.push('https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=' +
              encodeURIComponent(full) + '&q=' + encodeURIComponent(q));
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
      settled = true; cleanup(); onFail();
    }
    function onOk() {
      if (settled) return;
      settled = true; cleanup();
    }
    a.addEventListener('error', onError);
    a.addEventListener('playing', onOk);
    try {
      a.src = url;
      a.volume = 1;
      var p = a.play();
      if (p && p.catch) p.catch(onError);
    } catch (e) { onError(); }
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

  /* null = ovozlar hali yuklanmagan (davom etamiz),
     undefined = mos ovoz yo'q (darhol zaxiraga o'tamiz), voice = mos ovoz */
  function voiceFor(lang) {
    try {
      if (!window.speechSynthesis) return undefined;
      var voices = window.speechSynthesis.getVoices() || [];
      if (!voices.length) return null;
      var want = (lang || 'en').toLowerCase();
      var base = want.split('-')[0];
      var i;
      for (i = 0; i < voices.length; i++) {
        if ((voices[i].lang || '').toLowerCase() === want) return voices[i];
      }
      for (i = 0; i < voices.length; i++) {
        if ((voices[i].lang || '').toLowerCase().split('-')[0] === base) return voices[i];
      }
      return undefined;
    } catch (e) { return null; }
  }

  function synthSpeak(text, lang) {
    if (!window.speechSynthesis || typeof SpeechSynthesisUtterance === 'undefined') return false;
    try {
      var v = voiceFor(lang);
      /* Xitoy ovozi ko'pincha o'rnatilmagan: kutmasdan ishonchli manbaga o'tamiz.
         Boshqa tillarda esa mos ovoz bo'lmasa ham sinab ko'ramiz (regressiya bo'lmasin). */
      if (v === undefined && /^(zh|ja)/.test((lang || '').toLowerCase())) return false;
      var u = new SpeechSynthesisUtterance(text);
      if (v) { u.voice = v; u.lang = v.lang; }
      else if (lang) { u.lang = normLang(lang); }
      var played = false;
      u.onstart = function() { played = true; };
      u.onerror = function() {
        if (!played) { gtts(text, lang); }
      };
      window.speechSynthesis.cancel();
      window.speechSynthesis.speak(u);
      setTimeout(function() {
        if (!played) {
          try { window.speechSynthesis.cancel(); } catch (e) {}
          gtts(text, lang);
        }
      }, 1000);
      return true;
    } catch (e) {
      return false;
    }
  }

  function speak(text, lang) {
    if (!text || !text.trim()) return false;
    if (native) {
      if (nativeReady()) {
        try {
          if (native.speak(text, lang)) return true;
        } catch (e) {}
      }
      return gtts(text, lang);
    }
    if (synthSpeak(text, lang)) return true;
    return gtts(text, lang);
  }

  function stop() {
    if (native) { try { native.stop(); } catch (e) {} }
    if (window.speechSynthesis) { try { window.speechSynthesis.cancel(); } catch (e) {} }
    if (audioEl) { try { audioEl.pause(); } catch (e) {} }
  }

  return {
    speak: speak,
    stop: stop,
    hasNative: !!native,
    nativeReady: nativeReady
  };
})();
