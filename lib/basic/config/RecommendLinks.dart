import 'package:event/event.dart';

import '../Method.dart';

var recommendLinksEvent = Event<EventArgs>();

Map<String, String> _recommendLinks = {};

Map<String, String> currentRecommendLinks() => _recommendLinks;

Future<void> initRecommendLinks() async {
  try {
    _recommendLinks = await method.configLinks();
  } catch (_) {
    _recommendLinks = {};
  }
  recommendLinksEvent.broadcast();
}
