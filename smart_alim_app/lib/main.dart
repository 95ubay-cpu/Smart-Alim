import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const SmartAlimApp());
}

class SmartAlimApp extends StatelessWidget {
  const SmartAlimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Alim',
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
  int _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _progress = progress;
            });
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? false) {
              setState(() {
                _failed = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://smartalim.com'));
  }

  Future<void> _onBackPressed() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      SystemNavigator.pop();
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