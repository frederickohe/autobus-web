/// Credit resource types aligned with backend `CreditType` values.
class CreditCategory {
  CreditCategory._();

  static const String llm = 'llm';
  static const String imageGen = 'image_gen';
  static const String videoGen = 'video_gen';
  static const String email = 'email';
  static const String sms = 'sms';
  static const String storageMb = 'storage_mb';
  static const String server = 'server';

  static const Map<String, String> labels = {
    llm: 'LLM Chats',
    imageGen: 'Image Gen',
    videoGen: 'Video Gen',
    email: 'Email',
    sms: 'SMS',
    storageMb: 'Storage',
    server: 'Server',
  };

  static const Map<String, String> shortLabels = {
    llm: 'Chats',
    imageGen: 'Images',
    videoGen: 'Videos',
    email: 'Email',
    sms: 'SMS',
    storageMb: 'Storage',
    server: 'Requests',
  };

  static String labelFor(String category) =>
      labels[category] ?? shortLabels[category] ?? category;

  static String shortLabelFor(String category) =>
      shortLabels[category] ?? labelFor(category);
}
