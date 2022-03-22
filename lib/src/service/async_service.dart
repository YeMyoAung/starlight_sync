part of starlight_sync;

@protected
abstract class StarlightSync<N, R> {
  StarlightSync._();

  static final List<_StarlightTask> _tasks = [];

  /// Register a new [Stream] and [Sink] instance by [id].
  ///
  /// eg.
  ///
  /// ```
  ///   StarlightSync.register(id:"process 1");
  /// ```
  static void register<N, R>({
    required String id,
  }) {
    if (_tasks.where((_StarlightTask task) => task._id == id).isNotEmpty) {
      throw _StarlightException(
        error: "Already register with that process id `$id`",
        message: "Please register with another process id",
      );
    }
    _tasks.add(_StarlightTask<N, R>.byId(id));
  }

  /// Terminate an existing [Stream] and [Sink] instance by [id].
  ///
  /// After terminate an existing [Stream] and [Sink] instance,
  ///
  /// you can't execute that [Stream] and [Sink] anymore.
  ///
  /// eg.
  ///
  /// ```
  ///   StarlightSync.terminate(id:"process 1");
  /// ```
  static void terminate({
    required String id,
  }) {
    final _StarlightTask _task = _StarlightSyncExtension._process(id);
    _task._controller.close();
    _tasks.remove(_task);
  }

  /// Terminate all existing [Stream] and [Sink]
  ///
  /// After terminate all [Stream] and [Sink] instance,
  ///
  /// you can't execute that [Stream] and [Sink] anymore.
  ///
  /// eg.
  ///
  // / ```
  // /   StarlightSync.terminateAll();
  // / ```
  static void terminateAll() {
    for (_StarlightTask _task in _tasks) {
      _task._controller.close();
    }
    _tasks.clear();
  }

  /// By invoking [last] method by [id],
  ///
  /// you will get the last value of your [Future] with that [id]
  static N? last<N, R>({required String id}) =>
      _StarlightSyncExtension._process<N, R>(id)._task;

  /// If you want to execute a [Future], like this
  ///
  /// <https://flutter.dev/assets-and-images/>
  ///
  /// you need to create a [Stream] and [Sink] instance by using
  ///
  /// eg.
  ///
  // / ```
  // / StarlightSync.register(id:"process 1");
  // / StarlightSync.stream(id:"process 1").listen((event){
  // /   print("future stream is ${event['body']}");
  // / });
  // / Timer.periodic(Duration(seconds:1), (){
  // /   StarlightSync.execute(id:"process 1",task:()async{
  // /     await http.get('/get/random-images');
  // /   })
  // / });
  // / ```
  static void execute<N, R>({
    required String id,
    required Future<R> Function() task,
  }) {
    try {
      final _StarlightTask _task = _StarlightSyncExtension._process(id);
      task().then((result) {
        _task._task = result;
        _task._controller.sink.add(result);
      });
    } catch (e) {
      throw _StarlightException(
        error: "Execute error occour on $id",
        message: e.toString(),
      );
    }
  }

  /// If you want to invoke a method one more times using that result,
  ///
  /// you can use this [repeat] method by providing
  ///
  /// [id],[next],[stop],[task],[terminate] and [delay].
  ///
  /// [id] must be registered.
  ///
  /// [next] parameter will use in next time invoke.
  ///
  /// [stop] parameter will determine the [task] method need to invoke or not.
  ///
  /// [task] parameter is your [Future] work.
  ///
  /// [terminate] parameter will determine the [Stream] and [Sink] should be terminated or not.
  ///
  /// [delay] parameter will invoke after [task] is done.
  ///
  /// eg.
  ///
  // / ```
  // / StarlightSync.register<String?, ResponseModel>(id: 'all user');
  // / int i = 0;
  // / StarlightSync.stream<String?, ResponseModel>(id: 'all user')
  // /     .listen((event) {
  // /   i += (event.body['users'] as List).length;
  // /   print("listen body ${event.body}");
  // /   print("listen data is $i");
  // / });
  // / StarlightSync.repeat<String?, ResponseModel>(
  // /   id: 'all user',
  // /   next: (result) => result.body['next_page'],
  // /   stop: (next) => next == null,
  // /   task: ([next]) async {
  // /     return appInstance<ApiService>().getMethod(
  // /       RequestModel(
  // /         query: "/get/users/$next",
  // /       ),
  // /     );
  // /   },
  // / );
  // / ```
  static void repeat<N, R>({
    required String id,
    required N Function(R) next,
    required bool Function(N) stop,
    required Future<R> Function([N]) task,
    bool terminate = false,
    Duration delay = const Duration(milliseconds: 1000),
  }) {
    try {
      final _StarlightTask _task = _StarlightSyncExtension._process(id);
      task().then((R result) async {
        _task._task = next(result);
        _task._controller.sink.add(result);
        if (!stop(next(result))) {
          await Future.delayed(delay);
          repeat(
            id: id,
            next: next,
            stop: stop,
            task: ([e]) => task(_task._task),
            terminate: terminate,
            delay: delay,
          );
        } else {
          if (terminate) _tasks.removeWhere((task) => task._id == id);
        }
      });
    } catch (e) {
      throw _StarlightException(
        error: "Repeat error occour on $id",
        message: e.toString(),
      );
    }
  }

  /// You can listen your [Future] by [id]
  ///
  /// eg.
  ///
  /// ```
  /// StarlightSync.stream(id:"process 1").listen((event){
  ///   print("event is $event")
  /// });
  /// ```
  static Stream<R> stream<N, R>({
    required String id,
  }) =>
      _StarlightSyncExtension._process<N, R>(id)._controller.stream;
}
