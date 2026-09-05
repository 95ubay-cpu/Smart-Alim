package uz.smartalim.app;

import android.content.Context;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.webkit.JavascriptInterface;
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
    public void speak(String text, String lang) {
      if (!ready || tts == null || text == null || text.trim().isEmpty()) return;
      try {
        Locale loc = new Locale("en", "US");
        if (lang != null && !lang.isEmpty()) {
          loc = Locale.forLanguageTag(lang.replace('_', '-'));
          if (tts.isLanguageAvailable(loc) == TextToSpeech.LANG_MISSING_DATA) {
            Locale base = new Locale(loc.getLanguage());
            if (tts.isLanguageAvailable(base) == TextToSpeech.LANG_AVAILABLE) {
              loc = base;
            }
          }
        }
        tts.setLanguage(loc);
        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "smartalim");
      } catch (Exception ignored) {}
    }

    @JavascriptInterface
    public void stop() {
      if (tts != null) {
        try { tts.stop(); } catch (Exception ignored) {}
      }
    }
  }
}