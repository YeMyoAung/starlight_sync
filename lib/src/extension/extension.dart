part of starlight_sync;

@protected
extension _StarlightSyncExtension on StarlightSync {
  static _StarlightTask<N, R> _process<N, R>(String id) {
    try {
      return StarlightSync._tasks.firstWhere((task) => task._id == id)
          as _StarlightTask<N, R>;
    } catch (e) {
      throw _StarlightException(
        error: "There is no process id with that name `$id`",
        message: "Please register first.",
      );
    }
  }
}
