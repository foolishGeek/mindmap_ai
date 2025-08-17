enum UiEventType { success, error }

class UiEvent {
  final UiEventType type;
  final String message;
  final String title;

  const UiEvent(this.type, this.title, this.message);

  static UiEvent success(String t, String m) =>
      UiEvent(UiEventType.success, t, m);

  static UiEvent error(String t, String m) =>
      UiEvent(UiEventType.error, t, m);
}
