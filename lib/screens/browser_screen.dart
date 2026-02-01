import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _webController;
  bool _isLoading = true;
  double _loadProgress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = HibiscusBrowser.defaultHomePage;
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigationRequest,
          onPageStarted: _handlePageStarted,
          onPageFinished: _handlePageFinished,
          onProgress: _handleProgress,
        ),
      )
      ..loadRequest(Uri.parse(_urlController.text));
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    if (HibiscusBrowser.isActivationUrl(request.url)) {
      _activateAndExit();
      return NavigationDecision.prevent;
    }
    _updateUrlTextIfNeeded(request.url);
    return NavigationDecision.navigate;
  }

  void _handlePageStarted(String url) {
    _updateUrlTextIfNeeded(url);
    setState(() {
      _isLoading = true;
      _loadProgress = 0;
    });
  }

  Future<void> _handlePageFinished(String url) async {
    await _updateNavigationState();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadProgress = 1;
    });
  }

  void _handleProgress(int progress) {
    if (!mounted) return;
    setState(() {
      _loadProgress = progress / 100;
    });
  }

  Future<void> _updateNavigationState() async {
    final canBack = await _webController.canGoBack();
    final canForward = await _webController.canGoForward();
    if (!mounted) return;
    setState(() {
      _canGoBack = canBack;
      _canGoForward = canForward;
    });
  }

  void _updateUrlTextIfNeeded(String url) {
    if (_urlFocusNode.hasFocus) {
      return;
    }
    _urlController
      ..text = url
      ..selection = TextSelection.collapsed(offset: url.length);
  }

  Future<void> _activateAndExit() async {
    await firstPassed();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CloseAppScreen()),
    );
  }

  void _loadFromInput() {
    final normalized = HibiscusBrowser.normalizeInput(_urlController.text);
    _urlController.text = normalized;
    _urlController.selection =
        TextSelection.collapsed(offset: normalized.length);
    _webController.loadRequest(Uri.parse(normalized));
    _urlFocusNode.unfocus();
  }

  void _navigateHome() {
    final home = HibiscusBrowser.defaultHomePage;
    _urlController.text = home;
    _urlController.selection = TextSelection.collapsed(offset: home.length);
    _webController.loadRequest(Uri.parse(home));
  }

  void _reload() => _webController.reload();

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
            child: WebViewWidget(controller: _webController),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildUrlField(ColorScheme colorScheme) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _urlFocusNode,
              controller: _urlController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '输入网址或搜索',
                hintStyle:
                    TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
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
              color: colorScheme.onSurface.withOpacity(0.7),
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
            top:
                BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              tooltip: '后退',
              onPressed: _canGoBack ? () => _webController.goBack() : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              tooltip: '前进',
              onPressed:
                  _canGoForward ? () => _webController.goForward() : null,
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
