import 'package:autobus/features/marketing/models/postiz_integration.dart';

String _titleFromContent(String content) {
  final lines = content.split(RegExp(r'[\r\n]+'));
  for (final line in lines) {
    final t = line.trim();
    if (t.isNotEmpty) {
      return t.length > 100 ? '${t.substring(0, 97)}...' : t;
    }
  }
  return 'Marketing post';
}

/// Minimal `settings` for Postiz Public API `POST /api/public/v1/posts`.
/// See https://docs.postiz.com/public-api/posts/create
Map<String, dynamic> postizSettingsForIntegration(
  PostizIntegration integration,
  String titleFallback,
) {
  final t = integration.identifier.toLowerCase();
  switch (t) {
    case 'instagram':
    case 'instagram-standalone':
      return {
        '__type': t,
        'post_type': 'post',
        'is_trial_reel': false,
        'collaborators': <String>[],
      };
    case 'x':
      return {
        '__type': 'x',
        'who_can_reply_post': 'everyone',
        'community': '',
      };
    case 'youtube':
      return {
        '__type': 'youtube',
        'title': titleFallback,
        'type': 'public',
        'selfDeclaredMadeForKids': 'no',
        'tags': <Map<String, String>>[],
      };
    case 'tiktok':
      return {
        '__type': 'tiktok',
        'privacy_level': 'PUBLIC_TO_EVERYONE',
        'duet': true,
        'stitch': true,
        'comment': true,
        'autoAddMusic': 'no',
        'brand_content_toggle': false,
        'brand_organic_toggle': false,
        'video_made_with_ai': false,
        'content_posting_method': 'DIRECT_POST',
      };
    case 'medium':
      return {
        '__type': 'medium',
        'title': titleFallback,
        'subtitle': '',
        'tags': <Map<String, dynamic>>[],
      };
    case 'devto':
      return {
        '__type': 'devto',
        'title': titleFallback,
        'tags': <Map<String, dynamic>>[],
      };
    case 'hashnode':
      return {
        '__type': 'hashnode',
        'title': titleFallback,
        'subtitle': '',
        'publication': '',
        'tags': <Map<String, dynamic>>[],
      };
    case 'wordpress':
      return {
        '__type': 'wordpress',
        'title': titleFallback,
        'type': 'post',
      };
    default:
      return {'__type': t};
  }
}

/// Body for Autobus `POST /api/v1/social/postiz/posts` (passthrough to Postiz).
Map<String, dynamic> buildPostizCreatePostPayload({
  required Iterable<PostizIntegration> selectedIntegrations,
  required String content,
  required List<String> mediaUrls,
  required bool postRightAway,
  DateTime? scheduledUtc,
}) {
  final trimmed = content.trim();
  final bodyText = trimmed.isEmpty ? ' ' : trimmed;
  final title = _titleFromContent(bodyText);

  final scheduleMode = !postRightAway && scheduledUtc != null;
  final type = scheduleMode ? 'schedule' : 'now';
  final DateTime dateUtc;
  if (scheduleMode) {
    dateUtc = scheduledUtc.toUtc();
  } else {
    dateUtc = DateTime.now().toUtc();
  }
  final dateIso = dateUtc.toIso8601String();

  final imageBlocks = <Map<String, dynamic>>[
    for (var i = 0; i < mediaUrls.length; i++)
      {'id': 'media_$i', 'path': mediaUrls[i]},
  ];

  final posts = <Map<String, dynamic>>[];
  for (final integration in selectedIntegrations) {
    posts.add({
      'integration': {'id': integration.id},
      'value': [
        {
          'content': bodyText,
          'image': imageBlocks,
        },
      ],
      'settings': postizSettingsForIntegration(integration, title),
    });
  }

  return {
    'type': type,
    'date': dateIso,
    'shortLink': false,
    'tags': <Map<String, dynamic>>[],
    'posts': posts,
  };
}
