/* Smart Ta'lim — ovoz yordamchisi.
   Ketma-ketlik: ilova native TTS -> brauzer speechSynthesis -> Google ovoz fayli (zaxira). */
window.smartTTS = (function() {
  var native = (typeof window.SmartAlimTts !== 'undefined') ? window.SmartAlimTts : null;
  var el = null;

  function nativeReady() {
    try { return !!native && !!native.isReady() && native.isReady(); } catch (e) { return false; }
  }

  function nativeHasLang(lang) {
    try { return !lang || (!!native.hasLanguage && native.hasLanguage(lang)); } catch (e) { return false; }
  }

  function gtts(text, lang) {
    try {
      var l = (lang || 'en').split('-')[0];
      var q = text.length > 180 ? text.slice(0, 180) : text;
      var url = 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=' +
                encodeURIComponent(l) + '&q=' + encodeURIComponent(q);
      if (!el) {
        el = document.createElement('audio');
        document.body.appendChild(el);
      }
      el.src = url;
      var p = el.play();
      if (p && p.catch) p.catch(function(){});
      return true;
    } catch (e) {
      return false;
    }
  }

  function speak(text, lang) {
    if (!text || !text.trim()) return false;
    if (nativeReady() && nativeHasLang(lang)) {
      try {
        if (native.speak(text, lang)) return true;
      } catch (e) {}
    }
    if (window.speechSynthesis) {
      try {
        window.speechSynthesis.cancel();
        var u = new SpeechSynthesisUtterance(text);
        if (lang) u.lang = lang;
        window.speechSynthesis.speak(u);
        return true;
      } catch (e) {}
    }
    return gtts(text, lang);
  }

  function stop() {
    if (native) { try { native.stop(); } catch (e) {} }
    if (window.speechSynthesis) { try { window.speechSynthesis.cancel(); } catch (e) {} }
    if (el) { try { el.pause(); } catch (e) {} }
  }

  return {
    speak: speak,
    stop: stop,
    hasNative: !!native,
    nativeReady: nativeReady,
    nativeHasLang: nativeHasLang
  };
})();