package uz.smartalim.app;

import android.content.Context;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import androidx.activity.OnBackPressedCallback;
import com.getcapacitor.BridgeActivity;
import java.util.Locale;

public class MainActivity extends BridgeActivity {

  private final TtsBridge ttsBridge = new TtsBridge();

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    ttsBridge.init(getApplicationContext());
    try {
      getBridge().getWebView().addJavascriptInterface(ttsBridge, "SmartAlimTts");
    } catch (Exception ignored) {}

    getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
      @Override
      public void handleOnBackPressed() {
        WebView wv = getBridge() != null ? getBridge().getWebView() : null;
        if (wv != null && wv.canGoBack()) {
          wv.goBack();
        } else {
          moveTaskToBack(true);
        }
      }
    });
  }

  public static class TtsBridge {
    private TextToSpeech tts;
    private boolean ready = false;

    public void init(Context context) {
      if (tts == null) {
        tts = new TextToSpeech(context, new TextToSpeech.OnInitListener() {
          @Override
          public void onInit(int status) {
            ready = (status == TextToSpeech.SUCCESS);
          }
        });
      }
    }

    @JavascriptInterface
    public boolean speak(String text, String lang) {
      if (!ready || tts == null || text == null || text.trim().isEmpty()) return false;
      try {
        Locale loc = pickLocale(lang);
        int result = tts.setLanguage(loc);
        if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
          return false;
        }
        int queued = tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "smartalim");
        return queued >= 0;
      } catch (Exception ignored) {
        return false;
      }
    }

    @JavascriptInterface
    public boolean hasLanguage(String lang) {
      if (tts == null) return false;
      try {
        Locale loc = pickLocale(lang);
        int s = tts.isLanguageAvailable(loc);
        return (s != TextToSpeech.LANG_MISSING_DATA && s != TextToSpeech.LANG_NOT_SUPPORTED);
      } catch (Exception ignored) {
        return false;
      }
    }

    @JavascriptInterface
    public boolean isReady() {
      return ready;
    }

    private Locale pickLocale(String lang) {
      Locale loc = new Locale("en", "US");
      if (lang == null || lang.isEmpty()) return loc;
      loc = Locale.forLanguageTag(lang.replace('_', '-'));
      if (tts.isLanguageAvailable(loc) == TextToSpeech.LANG_MISSING_DATA) {
        Locale base = new Locale(loc.getLanguage());
        if (tts.isLanguageAvailable(base) != TextToSpeech.LANG_MISSING_DATA) {
          return base;
        }
      }
      return loc;
    }

    @JavascriptInterface
    public void stop() {
      if (tts != null) {
        try { tts.stop(); } catch (Exception ignored) {}
      }
    }
  }
}