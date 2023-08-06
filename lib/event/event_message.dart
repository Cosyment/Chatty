class EventMessage<T> {
  final T data;

  EventMessage(this.data);
}

enum EventType {
  CLOSE_DRAWER,
  CHANGE_LANGUAGE
}
