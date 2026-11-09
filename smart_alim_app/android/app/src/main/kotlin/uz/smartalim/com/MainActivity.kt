package uz.smartalim.com

import android.os.Bundle
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private val backChannelName = "uz.smartalim.com/back"
    private val ttsChannelName = "uz.smartalim.com/tts"

    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private var pendingSpeak: PendingSpeak? = null
    private val pendingLanguageResults = mutableListOf<MethodChannel.Result>()

    private data class PendingSpeak(
        val text: String,
        val lang: String,
        val result: MethodChannel.Result
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        tts = TextToSpeech(this, this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, backChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "minimize" -> {
                        moveTaskToBack(true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ttsChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "speak" -> {
                        val text = call.argument<String>("text").orEmpty()
                        val lang = call.argument<String>("lang") ?: "en-US"
                        if (text.isBlank()) {
                            result.success(false)
                        } else if (!ttsReady) {
                            pendingSpeak = PendingSpeak(text, lang, result)
                        } else {
                            result.success(speakNow(text, lang))
                        }
                    }
                    "stop" -> {
                        pendingSpeak?.result?.success(false)
                        pendingSpeak = null
                        tts?.stop()
                        result.success(null)
                    }
                    "languages" -> {
                        if (ttsReady) {
                            result.success(supportedLanguages())
                        } else {
                            pendingLanguageResults.add(result)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onInit(status: Int) {
        ttsReady = status == TextToSpeech.SUCCESS
        if (!ttsReady) {
            pendingSpeak?.result?.success(false)
            pendingSpeak = null
            pendingLanguageResults.forEach { it.success(emptyList<String>()) }
            pendingLanguageResults.clear()
            return
        }
        val pending = pendingSpeak
        pendingSpeak = null
        // Natijani faqat haqiqiy holatga qarab qaytaramiz: JS tomoni "false"
        // olganda onlayn zaxira ovozga o'tadi.
        if (pending != null) {
            pending.result.success(speakNow(pending.text, pending.lang))
        }
        val languages = supportedLanguages()
        pendingLanguageResults.forEach { it.success(languages) }
        pendingLanguageResults.clear()
    }

    private fun speakNow(text: String, lang: String): Boolean {
        val engine = tts ?: return false
        val locale = Locale.forLanguageTag(lang)
        var selected = locale
        var status = engine.isLanguageAvailable(locale)
        if (status == TextToSpeech.LANG_MISSING_DATA || status == TextToSpeech.LANG_NOT_SUPPORTED) {
            val base = Locale(lang.substringBefore('-').substringBefore('_'))
            val baseStatus = engine.isLanguageAvailable(base)
            if (baseStatus == TextToSpeech.LANG_MISSING_DATA || baseStatus == TextToSpeech.LANG_NOT_SUPPORTED) {
                return false
            }
            selected = base
            status = baseStatus
        }
        val setResult = engine.setLanguage(selected)
        if (setResult == TextToSpeech.LANG_MISSING_DATA || setResult == TextToSpeech.LANG_NOT_SUPPORTED) {
            return false
        }
        engine.stop()
        val result = engine.speak(text, TextToSpeech.QUEUE_FLUSH, null, "smartalim")
        return result == TextToSpeech.SUCCESS
    }

    private fun supportedLanguages(): List<String> {
        val engine = tts ?: return emptyList()
        if (!ttsReady) return emptyList()
        val out = linkedSetOf<String>()
        // Dvigatel o'zi qo'llab-quvvatlaydigan tillarni qo'shamiz (nemis tili
        // ham shu yerga tushadi).
        try {
            engine.availableLanguages?.forEach { locale ->
                val status = engine.isLanguageAvailable(locale)
                if (status != TextToSpeech.LANG_MISSING_DATA && status != TextToSpeech.LANG_NOT_SUPPORTED) {
                    val tag = locale.toLanguageTag()
                    if (tag.isNotEmpty() && tag != "und") {
                        out.add(tag)
                        if (locale.country.isNotEmpty()) out.add(locale.language)
                    }
                }
            }
        } catch (_: Throwable) {
        }
        val candidates = listOf(
            "ar", "ar-SA", "en", "en-US", "en-GB", "de", "de-DE", "fr", "fr-FR",
            "es", "es-ES", "ko", "ko-KR", "ja", "ja-JP", "zh", "zh-CN", "ru",
            "ru-RU", "uz", "uz-UZ"
        )
        candidates.forEach { tag ->
            val status = engine.isLanguageAvailable(Locale.forLanguageTag(tag))
            if (status != TextToSpeech.LANG_MISSING_DATA && status != TextToSpeech.LANG_NOT_SUPPORTED) {
                out.add(tag)
            }
        }
        return out.toList()
    }

    override fun onDestroy() {
        pendingSpeak = null
        tts?.stop()
        tts?.shutdown()
        tts = null
        super.onDestroy()
    }
}
