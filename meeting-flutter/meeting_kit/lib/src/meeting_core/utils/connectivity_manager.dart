// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_core;

///
/// 通用网络连接管理
///
class ConnectivityManager with ChangeNotifier, _AloggerMixin {
  static final _instance = ConnectivityManager._();

  factory ConnectivityManager() => _instance;

  ConnectivityManager._() {
    Connectivity().checkConnectivity().then(_updateConnectivity);
    _subscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectivity);
    // 重新回到前台后再次检查网络连接
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        commonLogger.i('on app onResume, check connectivity');
        Connectivity().checkConnectivity().then(_updateConnectivity);
      },
    );
  }

  late final AppLifecycleListener _lifecycleListener;
  late final StreamSubscription _subscription;
  final _initialized = Completer();
  var _isConnected = true;

  Future<bool> isConnected() async {
    await _initialized.future;
    return _isConnected;
  }

  bool isConnectedSync() => _isConnected;

  void _updateConnectivity(List<ConnectivityResult> result) {
    if (_onConnectedChanged.isClosed) return;
    bool connected =
        result.every((element) => element != ConnectivityResult.none);
    if (_isConnected != connected) {
      commonLogger.i('on connectivity changed: $_isConnected -> $connected');
      _isConnected = connected;
      _onConnectedChanged.add(connected);
      notifyListeners();
    }
    if (!_initialized.isCompleted) {
      _initialized.complete();
    }
  }

  StreamController<bool> _onConnectedChanged = StreamController.broadcast();

  /// 连接成功事件
  Stream get onReconnected =>
      onConnectedChanged.where((connected) => connected);

  /// 断开连接事件
  Stream get onDisconnected =>
      onConnectedChanged.where((connected) => !connected);

  /// 连接变更事件
  Stream<bool> get onConnectedChanged => _onConnectedChanged.stream;

  /// 确保网络连接
  Future awaitUntilConnected() async {
    if (!await isConnected()) {
      return onReconnected.first;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _onConnectedChanged.close();
    _lifecycleListener.dispose();
    super.dispose();
  }
}

mixin ConnectivityWatcher<T extends StatefulWidget> on State<T> {
  Future<bool> get isNetworkConnected => ConnectivityManager().isConnected();

  @override
  void initState() {
    super.initState();
    ConnectivityManager().addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    ConnectivityManager().removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() async {
    onNetworkChanged(await isNetworkConnected);
  }

  @protected
  void onNetworkChanged(bool connected) {}
}

class ConnectivityChangedBuilder extends StatelessWidget {
  const ConnectivityChangedBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  final ValueWidgetBuilder<bool> builder;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: ConnectivityManager()._isConnected,
      stream: ConnectivityManager().onConnectedChanged,
      builder: (context, snapshot) {
        return builder(context, snapshot.data as bool, child);
      },
    );
  }
}
