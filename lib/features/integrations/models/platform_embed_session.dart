/// Session payload from Autobus for embedded Postiz / Chatwoot sign-in in a WebView.
class PlatformEmbedSession {
  final String authorizationUrl;
  final String? message;

  /// Postiz: load this page so the user can sign in (`postiz_login.login_page_url`).
  final String? postizLoginPageUrl;
  final Map<String, dynamic>? postizLoginBody;

  /// When true, [authorizationUrl] is a direct provider OAuth URL (e.g. Facebook).
  /// Skip the Postiz login UI and open the provider immediately.
  final bool directOauth;

  /// Chatwoot: load this page and submit `chatwoot_login.body` (`login_page_url`).
  final String? chatwootLoginPageUrl;
  final Map<String, dynamic>? chatwootLoginBody;

  const PlatformEmbedSession({
    required this.authorizationUrl,
    this.message,
    this.postizLoginPageUrl,
    this.postizLoginBody,
    this.directOauth = false,
    this.chatwootLoginPageUrl,
    this.chatwootLoginBody,
  });

  bool get isPostiz =>
      !directOauth &&
      postizLoginPageUrl != null &&
      postizLoginPageUrl!.isNotEmpty;

  bool get isChatwoot =>
      chatwootLoginPageUrl != null &&
      chatwootLoginPageUrl!.isNotEmpty &&
      chatwootLoginBody != null;

  factory PlatformEmbedSession.fromPostizAutoLogin(Map<String, dynamic> json) {
    return PlatformEmbedSession.fromApiJson(json, loginKey: 'postiz_login');
  }

  factory PlatformEmbedSession.fromSocialConnect(Map<String, dynamic> json) {
    return PlatformEmbedSession.fromApiJson(json, loginKey: 'postiz_login');
  }

  factory PlatformEmbedSession.fromChatwoot(Map<String, dynamic> json) {
    return PlatformEmbedSession.fromApiJson(json, loginKey: 'chatwoot_login');
  }

  factory PlatformEmbedSession.fromApiJson(
    Map<String, dynamic> json, {
    required String loginKey,
  }) {
    final authUrl = (json['authorization_url'] ?? '').toString();
    final directOauth = json['direct_oauth'] == true;
    final loginRaw = json[loginKey];
    Map<String, dynamic>? loginMap;
    if (loginRaw is Map) {
      loginMap = Map<String, dynamic>.from(loginRaw);
    }

    if (loginKey == 'postiz_login') {
      final pageUrl = (loginMap?['login_page_url'] ?? '').toString();
      final body = loginMap?['body'];
      // Direct provider OAuth (Facebook, etc.): open Meta/provider URL only.
      if (directOauth) {
        return PlatformEmbedSession(
          authorizationUrl: authUrl,
          message: json['message']?.toString(),
          directOauth: true,
        );
      }
      return PlatformEmbedSession(
        authorizationUrl: authUrl,
        message: json['message']?.toString(),
        postizLoginPageUrl: pageUrl.isEmpty ? null : pageUrl,
        postizLoginBody: body is Map ? Map<String, dynamic>.from(body) : null,
        directOauth: false,
      );
    }

    final pageUrl = (loginMap?['login_page_url'] ?? '').toString();
    final body = loginMap?['body'];
    return PlatformEmbedSession(
      authorizationUrl: authUrl,
      message: json['message']?.toString(),
      chatwootLoginPageUrl: pageUrl.isEmpty ? null : pageUrl,
      chatwootLoginBody: body is Map ? Map<String, dynamic>.from(body) : null,
    );
  }
}
