class AssistantReply {
  final String text;
  const AssistantReply(this.text);
}

class AssistantException implements Exception {
  final String message;
  const AssistantException(this.message);
  @override
  String toString() => message;
}

/// Contract for any cooking assistant. The UI only knows this interface, so
/// a real AI backend can be plugged in later without changing the screens.
///
/// A real implementation should call YOUR backend (which holds the API key).
/// Never put an AI API key in this Flutter app.
abstract class CookingAssistantService {
  /// True when answers come from built-in rules instead of a real AI model.
  bool get isDemo;

  /// [pantry] are the ingredient ids the user has selected.
  /// Throws [AssistantException] when no answer can be produced.
  Future<AssistantReply> ask(String question, {Set<String> pantry = const {}});
}
