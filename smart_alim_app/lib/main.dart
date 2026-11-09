import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

const String _homeUrl = 'https://smartalim.com';
const MethodChannel _backChannel = MethodChannel('uz.smartalim.com/back');
const MethodChannel _ttsChannel = MethodChannel('uz.smartalim.com/tts');

/// JS tomonidagi ko'prik nomi: `window.SmartTtsBridge.postMessage(...)`.
const String _ttsBridgeName = 'SmartTtsBridge';

/// Ovoz skriptidagi til ro'yxati joyi.
const String _langsToken = '__SMART_TTS_LANGS__';
const String _ttsShimAsset = 'assets/tts_shim.js';

void main() {
  runApp(const SmartTalimApp());
}

class SmartTalimApp extends StatelessWidget {
  const SmartTalimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart Ta'lim",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E9F6E)),
        scaffoldBackgroundColor: const Color(0xFFEAFBF4),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final WebViewController _controller;
  Future<String>? _shimTemplateFuture;
  Future<List<String>>? _langsFuture;
  int _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFEAFBF4))
      ..addJavaScriptChannel(
        _ttsBridgeName,
        onMessageReceived: _onTtsMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress;
            });
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              _failed = false;
              _progress = 0;
            });
            // Sahifa skriptlaridan oldin ulgurishga harakat qilamiz.
            _injectTts();
          },
          onPageFinished: (url) {
            // Har bir sahifa yuklangach ovoz ko'prigini o'rnatamiz.
            _injectTts();
          },
          onWebResourceError: (error) {
            if ((error.isForMainFrame ?? false) && mounted) {
              setState(() {
                _failed = true;
              });
            }
          },
        ),
      );

    // Video/audio fayllar foydalanuvchi bosishisiz ham ijro etilishi mumkin.
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    // Ovoz skriptini va qurilma tillarini oldindan yuklab qo'yamiz.
    _loadShimTemplate();
    _loadNativeLanguages();
    _controller.loadRequest(Uri.parse(_homeUrl));
  }

  Future<String> _loadShimTemplate() {
    return _shimTemplateFuture ??= rootBundle.loadString(_ttsShimAsset);
  }

  Future<List<String>> _loadNativeLanguages() async {
    final cached = _langsFuture;
    if (cached != null) {
      final list = await cached;
      // Bo'sh ro'yxatni keshlab qo'ymaymiz: TTS hali tayyor bo'lmagan
      // bo'lishi mumkin, keyingi urinishda qayta so'raymiz.
      if (list.isNotEmpty) return list;
      _langsFuture = null;
    }
    final future = _ttsChannel
        .invokeListMethod<String>('languages')
        .then<List<String>>((value) => value ?? const <String>[])
        .catchError((Object _) => const <String>[]);
    _langsFuture = future;
    return future;
  }

  /// JS ko'prigidan kelgan xabarni qurilma TTS iga uzatadi.
  void _onTtsMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message);
      if (data is! Map) return;
      final action = data['action'];
      if (action == 'speak') {
        final text = data['text'];
        if (text is! String || text.trim().isEmpty) return;
        final lang = data['lang'] is String ? data['lang'] as String : 'en-US';
        _speakNative(text, lang);
      } else if (action == 'stop') {
        _ttsChannel.invokeMethod<void>('stop');
      }
    } catch (_) {
      // Buzilgan xabar ovozni to'xtatib qo'ymasligi kerak.
    }
  }

  /// Native TTS muvaffaqiyatsiz bo'lsa (masalan, qurilmada o'sha til ovozi
  /// o'rnatilmagan bo'lsa) JS tomonga xabar beramiz — u onlayn zaxiraga o'tadi.
  Future<void> _speakNative(String text, String lang) async {
    bool ok = false;
    try {
      ok = await _ttsChannel.invokeMethod<bool>('speak', {
            'text': text,
            'lang': lang,
          }) ??
          false;
    } catch (_) {
      ok = false;
    }
    if (ok) return;
    try {
      await _controller.runJavaScript(
        'window.__smartTtsNativeFailed && window.__smartTtsNativeFailed();',
      );
    } catch (_) {}
  }

  Future<void> _injectTts() async {
    try {
      final template = await _loadShimTemplate();
      if (template.isEmpty) return;
      List<String> langs;
      try {
        langs = await _loadNativeLanguages().timeout(
          const Duration(seconds: 4),
        );
      } catch (_) {
        langs = const <String>[];
      }
      final js = template.replaceAll(_langsToken, jsonEncode(langs));
      await _controller.runJavaScript(js);
    } catch (_) {
      // Ovoz bo'lmasa ham sayt ishlashda davom etadi.
    }
  }

  Future<void> _onBackPressed() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    // Bosh sahifada ilovadan butunlay chiqmaymiz — fon rejimiga o'tkazamiz.
    try {
      await _backChannel.invokeMethod('minimize');
    } catch (_) {
      await SystemNavigator.pop();
    }
  }

  void _reload() {
    setState(() {
      _failed = false;
      _progress = 0;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBackPressed();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_failed)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFEAFBF4),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 56,
                          color: Color(0xFF0B7A54),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Internet aloqasi yo'q",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16241F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Ilovani ochish uchun internetga ulaning",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF5B6B65)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _reload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E9F6E),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Qayta urinish",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_progress < 100)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: _progress / 100,
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                    color: const Color(0xFF0E9F6E),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
