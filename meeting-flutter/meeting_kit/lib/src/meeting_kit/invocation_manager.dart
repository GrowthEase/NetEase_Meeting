// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_kit;

typedef OnError = void Function(int code, String msg);

class InvocationManager {
  static const _tag = 'InvocationManager';
  int _token = 0;

  final Map<int, List<Resource>> _tokenToResource;

  final Map<Resource, int> _resourceToCount;

  static final InvocationManager _instance = InvocationManager._();

  InvocationManager._()
      : _tokenToResource = <int, List<Resource>>{},
        _resourceToCount = <Resource, int>{};

  factory InvocationManager() => _instance;

  T syncWithResource<T>(
    List<Resource> resources,
    T Function() onAccept,
    T Function() onDeny,
  ) {
    assert(resources.isNotEmpty);
    var token = _lockResource(resources);
    if (token == 0) {
      return onDeny();
    }
    try {
      return onAccept();
    } catch (e) {
      Alog.e(
          tag: _tag,
          moduleName: _moduleName,
          content: 'InvocationManager#syncWithResource error $e');
      rethrow;
    } finally {
      _unlockResource(token);
    }
  }

  Future<T> asyncWithResource<T>(
    List<Resource> resources,
    Future<T> Function() onAccept,
    Future<T> Function() onDeny,
  ) {
    assert(resources.isNotEmpty);
    var token = _lockResource(resources);
    if (token == 0) {
      return onDeny();
    }
    try {
      final future = onAccept();
      future.whenComplete(() => _unlockResource(token));
      return future;
    } catch (e) {
      Alog.e(
          tag: _tag,
          moduleName: _moduleName,
          content: 'InvocationManager#asyncWithResource error $e');
      _unlockResource(token);
      rethrow;
    }
  }

  int _lockResource(List<Resource> resources) {
    //check remain resources
    for (var element in resources) {
      final remain = _resourceToCount.putIfAbsent(element, () => element.count);
      if (remain < 1) {
        Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content:
                'InvocationManager#acquire fail, no remain resource for ${element.name}');
        return 0;
      }
    }

    resources.forEach((element) {
      _resourceToCount.update(element, (value) => value - 1);
    });
    var token = ++_token;
    _tokenToResource.putIfAbsent(token, () => resources);
    if (kDebugMode) {
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content:
              'InvocationManager#acquire success for resources: ${resources.map((e) => e.name).join(',')} token=$token');
    }
    return token;
  }

  void _unlockResource(int token) {
    if (token > 0) {
      if (kDebugMode) {
        Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content: 'InvocationManager#release resources with token $token');
      }
      var resources = _tokenToResource.remove(token);
      resources?.forEach((element) {
        _resourceToCount.update(element, (value) => value + 1);
      });
    }
  }
}

class Resource {
  /// 账号资源
  static const Resource account = Resource('account', 1);

  /// 会议房间资源
  static const Resource room = Resource('room', 1);

  /// 资源名称
  final String name;

  /// 资源数量
  final int count;

  const Resource(this.name, this.count) : assert(count > 0);
}
