part of starlight_sync;

@protected
class _StarlightTask<N, R> {
  final String _id;
  final StreamController<R> _controller;
  N? _task;
  _StarlightTask._(this._id, this._controller, [this._task]);

  factory _StarlightTask.byId(String id) => _StarlightTask<N, R>._(
        id,
        StreamController<R>.broadcast(),
      );

  _StarlightTask<N, R> next(
    N task,
  ) =>
      _StarlightTask<N, R>._(
        _id,
        _controller,
        task,
      );

  @override
  bool operator ==(covariant Object other) {
    if (other is _StarlightTask) return other._id == _id;
    return other == _id;
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => _id;
}
