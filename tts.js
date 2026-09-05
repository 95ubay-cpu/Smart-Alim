/* Smart Ta'lim — ovoz yordamchisi.
   Ilovada (SmartAlimTts) native TTS, aks holda speechSynthesis ishlaydi. */
window.smartTTS = (function() {
  var native = (typeof window.SmartAlimTts !== 'undefined') ? window.SmartAlimTts : null;

  function speak(text, lang) {
    if (!text || !text.trim()) return false;
    if (native) {
      try { native.speak(text, lang); return true; } catch (e) {}
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
    return false;
  }

  function stop() {
    if (native) { try { native.stop(); } catch (e) {} }
    if (window.speechSynthesis) { try { window.speechSynthesis.cancel(); } catch (e) {} }
  }

  return { speak: speak, stop: stop, hasNative: !!native };
})();