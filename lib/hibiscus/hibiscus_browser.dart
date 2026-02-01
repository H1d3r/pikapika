class HibiscusBrowser {
  /// 默认的首页地址
  static const String defaultHomePage = 'https://www.bing.com';

  static const  _pk = 'pika://start';

  /// 判断是否是激活协议
  static bool isActivationUrl(String url) {
    final normalized = url.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return normalized == _pk;
  }

  /// 用户输入可能是关键词、域名或者完整链接，统一转成可加载的 URL
  static String normalizeInput(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return defaultHomePage;
    }
    if (isActivationUrl(trimmed)) {
      return trimmed;
    }
    if (_containsScheme(trimmed)) {
      return trimmed;
    }
    if (_looksLikeDomain(trimmed)) {
      return 'https://$trimmed';
    }
    final query = Uri.encodeComponent(trimmed);
    return 'https://www.bing.com/search?q=$query';
  }

  static bool _containsScheme(String value) {
    return RegExp(r'^[a-zA-Z][a-zA-Z0-9+\-.]*://').hasMatch(value);
  }

  static bool _looksLikeDomain(String value) {
    return value.contains('.') && !value.contains(' ');
  }
}
