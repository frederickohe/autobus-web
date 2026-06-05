/// Connected channel from Postiz `GET /api/public/v1/integrations`.
class PostizIntegration {
  final String id;
  final String name;
  final String identifier;
  final String? picture;
  final bool disabled;
  final String? profile;

  const PostizIntegration({
    required this.id,
    required this.name,
    required this.identifier,
    this.picture,
    this.disabled = false,
    this.profile,
  });

  factory PostizIntegration.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ??
        json['integrationId'] ??
        json['integration_id'] ??
        '';
    return PostizIntegration(
      id: idRaw.toString(),
      name: (json['name'] ?? '').toString(),
      identifier: (json['identifier'] ?? '').toString().toLowerCase(),
      picture: json['picture']?.toString(),
      disabled: json['disabled'] == true,
      profile: json['profile']?.toString(),
    );
  }

  bool get isActive => !disabled && id.isNotEmpty;
}
