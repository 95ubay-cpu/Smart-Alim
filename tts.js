/* Smart Ta'lim — ovoz yordamchisi.
   Ketma-ketlik: ilova native TTS -> brauzer speechSynthesis (tekshirilgan) -> Google ovoz fayli (zaxira). */
window.smartTTS = (function() {
  var native = (typeof window.SmartAlimTts !== 'undefined') ? window.SmartAlimTts : null;
  var audioEl = null;

  function nativeReady() {
    try { return !!native && !!native.isReady && native.isReady(); } catch (e) { return false; }
  }

  function gtts(text, lang) {
    try {
      var l = (lang || 'en').split('-')[0];
      var q = text.length > 180 ? text.slice(0, 180) : text;
      var url = 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=' +
                encodeURIComponent(l) + '&q=' + encodeURIComponent(q);
      if (!audioEl) {
        audioEl = document.createElement('audio');
        document.body.appendChild(audioEl);
      }
      audioEl.src = url;
      audioEl.volume = 1;
      var p = audioEl.play();
      if (p && p.catch) p.catch(function() {});
      return true;
    } catch (e) {
      return false;
    }
  }

  function synthSpeak(text, lang) {
    if (!window.speechSynthesis) return false;
    try {
      var u = new SpeechSynthesisUtterance(text);
      if (lang) u.lang = lang;
      var played = false;
      var done = false;
      u.onstart = function() { played = true; };
      u.onerror = function() {
        if (!played) { if (audioEl) { try { audioEl.pause(); } catch (e) {} } gtts(text, lang); }
      };
      u.onend = function() {};
      window.speechSynthesis.cancel();
      window.speechSynthesis.speak(u);
      setTimeout(function() {
        if (!played) {
          try { window.speechSynthesis.cancel(); } catch (e) {}
          gtts(text, lang);
        }
      }, 1800);
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
    if (audioEl) {
      try { audioEl.pause(); } catch (e) {}
    }
  }

  return {
    speak: speak,
    stop: stop,
    hasNative: !!native,
    nativeReady: nativeReady
  };
})();