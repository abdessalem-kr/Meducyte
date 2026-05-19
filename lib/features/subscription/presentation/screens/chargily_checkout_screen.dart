import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChargilyCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;

  const ChargilyCheckoutScreen({super.key, required this.checkoutUrl});

  @override
  State<ChargilyCheckoutScreen> createState() => _ChargilyCheckoutScreenState();
}

class _ChargilyCheckoutScreenState extends State<ChargilyCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            //Detect success/failure based on the URL if needed
            //The webhook handles the actual activation,but we can close the screen here.
            if (url.contains('/payment/success')) {
              Navigator.of(context).pop(true);
            } else if (url.contains('/payment/failure')) {
              Navigator.of(context).pop(false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement Sécurisé"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
