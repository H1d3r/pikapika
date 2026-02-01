import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:pikapika/basic/config/passed.dart';
import 'package:pikapika/hibiscus/hibiscus_browser.dart';
import 'CloseAppScreen.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({Key? key}) : super(key: key);

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  InAppWebViewController? _webController;
  bool _isLoading = true;
  double _loadProgress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _currentUrl = HibiscusBrowser.defaultHomePage;

  @override
  void initState() {
    super.initState();
    _urlController.text = _currentUrl;
  }

  Future<NavigationActionPolicy?> _handleNavigationRequest(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final target = navigationAction.request.url?.toString() ?? '';
    if (HibiscusBrowser.isActivationUrl(target)) {
      _activateAndExit();
      return NavigationActionPolicy.CANCEL;
    }
    _updateUrlTextIfNeeded(target);
    return NavigationActionPolicy.ALLOW;
  }

  void _updateUrlTextIfNeeded(String url) {
    if (_urlFocusNode.hasFocus) {
      return;
    }
    _currentUrl = url;
    _urlController
      ..text = url
      ..selection = TextSelection.collapsed(offset: url.length);
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _webController = controller;
    _updateNavigationState();
  }

  void _handleLoadStart(InAppWebViewController controller, WebUri? url) {
    _updateUrlTextIfNeeded(url?.toString() ?? '');
    setState(() {
      _isLoading = true;
      _loadProgress = 0;
    });
  }

  Future<void> _handleLoadStop(InAppWebViewController controller, WebUri? url) async {
    await _updateNavigationState();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadProgress = 1;
    });
  }

  void _handleProgress(InAppWebViewController controller, int progress) {
    if (!mounted) return;
    setState(() {
      _loadProgress = progress / 100;
    });
  }

  Future<void> _updateNavigationState() async {
    final controller = _webController;
    if (controller == null) {
      return;
    }
    final canBack = await controller.canGoBack();
    final canForward = await controller.canGoForward();
    if (!mounted) return;
    setState(() {
      _canGoBack = canBack;
      _canGoForward = canForward;
    });
  }

  void _loadFromInput() {
    final normalized = HibiscusBrowser.normalizeInput(_urlController.text);
    if (HibiscusBrowser.isActivationUrl(normalized)) {
      _activateAndExit();
      return;
    }
    _urlController.text = normalized;
    _urlController.selection =
        TextSelection.collapsed(offset: normalized.length);
    _webController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(normalized)),
    );
    _urlFocusNode.unfocus();
  }

  void _navigateHome() {
    final home = HibiscusBrowser.defaultHomePage;
    _urlController.text = home;
    _urlController.selection = TextSelection.collapsed(offset: home.length);
    _webController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(home)),
    );
  }

  Future<void> _activateAndExit() async {
    await firstPassed();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CloseAppScreen()),
    );
  }

  void _reload() {
    _webController?.reload();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: _buildUrlField(theme.colorScheme),
      ),
      body: Column(
        children: [
          if (_isLoading) LinearProgressIndicator(value: _loadProgress),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
              ),
              shouldOverrideUrlLoading: _handleNavigationRequest,
              onWebViewCreated: _onWebViewCreated,
              onLoadStart: _handleLoadStart,
              onLoadStop: _handleLoadStop,
              onProgressChanged: _handleProgress,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildUrlField(ColorScheme colorScheme) {
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    return Container(
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _urlFocusNode,
              controller: _urlController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '输入网址或搜索',
                hintStyle: TextStyle(color: textColor.withOpacity(0.7)),
              ),
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _loadFromInput(),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              size: 20,
              color: textColor.withOpacity(0.7),
            ),
            onPressed: _loadFromInput,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              tooltip: '后退',
              onPressed: _canGoBack ? () => _webController?.goBack() : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              tooltip: '前进',
              onPressed:
                  _canGoForward ? () => _webController?.goForward() : null,
            ),
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: '首页',
              onPressed: _navigateHome,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '刷新',
              onPressed: _reload,
            ),
          ],
        ),
      ),
    );
  }
}
