// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef MyWaitingRoomStatusChangedHandler = void Function(
    int status, int reason);

typedef MyWaitingRoomMemberJoinHandler = void Function(
    NEWaitingRoomMember member, int reason);

class WaitingRoomManager with NEWaitingRoomListener, _AloggerMixin {
  static const pageSize = 20;
  static const pageOrder = true;

  final NERoomContext roomContext;
  final MyWaitingRoomStatusChangedHandler? waitingRoomStatusChangedHandler;
  final MyWaitingRoomMemberJoinHandler? waitingRoomMemberJoinHandler;
  late final waitingRoomController = roomContext.waitingRoomController;
  late final waitingRoomMemberCountListenable =
      ValueNotifier(waitingRoomController.getWaitingRoomInfo().memberCount);
  late final waitingRoomEnabledOnEntryListenable = ValueNotifier(
      waitingRoomController.getWaitingRoomInfo().isEnabledOnEntry);
  late final _users = <String, NEWaitingRoomMember>{};
  List<NEWaitingRoomMember>? _userList; // to prevent sort every time
  var _loadingMore = false;
  var _disposed = false;
  var _hasInit = false;
  Object? _loadingToken;
  StreamSubscription? _connectivitySubscription;
  final _userListChangeController = StreamController<Object>.broadcast();
  Stream<Object> get userListChanged => _userListChangeController.stream;

  List<NEWaitingRoomHost>? _hostAndCoHostList;
  List<NEWaitingRoomHost> get hostAndCoHostList {
    _ensureInit();
    return _hostAndCoHostList ?? [];
  }

  final _hostAndCoHostListChangeController =
      StreamController<List<NEWaitingRoomHost>>.broadcast();
  Stream<List<NEWaitingRoomHost>> get hostAndCoHostListChanged {
    if (_hostAndCoHostList == null) {
      tryLoadHostAndCoHost();
    }
    return _hostAndCoHostListChangeController.stream
        .addInitial(hostAndCoHostList);
  }

  int compareHost(NEWaitingRoomHost lhs, NEWaitingRoomHost rhs) {
    if (lhs.role == MeetingRoles.kHost) {
      return -1;
    }
    if (rhs.role == MeetingRoles.kHost) {
      return 1;
    }
    return lhs.name.compareTo(rhs.name);
  }

  final _unreadMemberUuids = <String>{};
  final _unreadMemberCountNotify = ValueNotifier(0);
  ValueNotifier<int> get unreadMemberCountListenable =>
      _unreadMemberCountNotify;

  WaitingRoomManager(
    this.roomContext, {
    this.waitingRoomStatusChangedHandler,
    this.waitingRoomMemberJoinHandler,
  }) {
    waitingRoomController.addListener(this);
  }

  bool get isFeatureSupported {
    return roomContext.waitingRoomController.isSupported ||
        waitingRoomEnabledOnEntryListenable.value;
  }

  void _ensureInit() {
    if (!_hasInit) {
      _hasInit = true;
      _connectivitySubscription =
          ConnectivityManager().onReconnected.listen((connected) {
        if (connected) {
          tryLoadMoreUser(reset: true);
          tryLoadHostAndCoHost();
        }
      });
      tryLoadMoreUser(reset: true);
      tryLoadHostAndCoHost();
    }
  }

  void resetUnreadMemberCount() {
    commonLogger.i('resetUnreadMemberCount');
    _unreadMemberCountNotify.value = 0;
    _unreadMemberUuids.clear();
  }

  void reset() {
    commonLogger.i('reset: supported=$isFeatureSupported');
    resetUnreadMemberCount();
    _loadingMore = false;
    _userList = null;
    _users.clear();
    _userListChangeController.add(const Object());
    _ensureInit();
    if (isMySelfManager && _hasInit) {
      tryLoadMoreUser(reset: true);
      tryLoadHostAndCoHost();
    }
  }

  void dispose() {
    _disposed = true;
    _connectivitySubscription?.cancel();
    _userListChangeController.close();
    waitingRoomController.removeListener(this);
  }

  bool get isMySelfManager =>
      roomContext.isMySelfHost() || roomContext.isMySelfCoHost();

  void onWaitingRoomInfoUpdated(NEWaitingRoomInfo info) {
    waitingRoomMemberCountListenable.value = info.memberCount;
    waitingRoomEnabledOnEntryListenable.value = info.isEnabledOnEntry;
  }

  void onMemberJoin(NEWaitingRoomMember member, int reason) {
    if (isMySelfManager) {
      _users[member.uuid] = member;
      _userList = null;
      _userListChangeController.add(const Object());
      if (_unreadMemberUuids.add(member.uuid)) _unreadMemberCountNotify.value++;
      waitingRoomMemberJoinHandler?.call(member, reason);
    }
  }

  void onMemberLeave(String member, int reason) {
    if (isMySelfManager && _users.remove(member) != null) {
      _userList = null;
      _userListChangeController.add(const Object());
      if (_unreadMemberUuids.remove(member)) _unreadMemberCountNotify.value--;
    }
  }

  void onMemberAdmitted(String member) {
    if (isMySelfManager) {
      _users[member]?.status = NEWaitingRoomConstants.STATUS_ADMITTED;
      _userListChangeController.add(const Object());
      if (_unreadMemberUuids.remove(member)) _unreadMemberCountNotify.value--;
    }
  }

  void onMemberNameChanged(String member, String name) {
    if (isMySelfManager) {
      _users[member]?.name = name;
      _userListChangeController.add(const Object());
    }
  }

  @override
  void onAllMembersKicked() {
    if (isMySelfManager) {
      _users.clear();
      _userList = null;
      _userListChangeController.add(const Object());
      resetUnreadMemberCount();
    }
  }

  @override
  void onManagersUpdated(List<NEWaitingRoomHost> updatedHosts) {
    updateHostAndCoHostList(updatedHosts);
  }

  void onMyWaitingRoomStatusChanged(int status, int reason) {
    waitingRoomStatusChangedHandler?.call(status, reason);
  }

  int get currentMemberCount => waitingRoomMemberCountListenable.value;

  List<NEWaitingRoomMember> get userList {
    _ensureInit();
    if (_userList == null) {
      _userList = _users.values.toList()
        ..sort((lhs, rhs) {
          return lhs.joinTime.compareTo(rhs.joinTime);
        });
    }
    return _userList!;
  }

  /// 等候室成员更新主持人和联席主持人列表
  Future<void> tryLoadHostAndCoHost() async {
    if (!roomContext.isInWaitingRoom()) return;
    final result = await waitingRoomController.getHostAndCoHostList();
    if (!_disposed && result.isSuccess()) {
      updateHostAndCoHostList(result.data ?? []);
    }
  }

  /// 更新主持人和联席主持人列表
  void updateHostAndCoHostList(List<NEWaitingRoomHost> updatedHosts) {
    _hostAndCoHostList = updatedHosts;
    _hostAndCoHostList?.sort(compareHost);
    _hostAndCoHostListChangeController.add(updatedHosts);
  }

  void tryLoadMoreUser({bool reset = false}) async {
    commonLogger.i('tryLoadMoreUser: reset=$reset');
    if (_loadingMore || _disposed || !isMySelfManager || !isFeatureSupported)
      return;
    if (!reset && _users.length > 0 && _users.length >= currentMemberCount)
      return;
    _loadingMore = true;
    _loadingToken = Object();
    final loadingToken = _loadingToken;
    final pageResult = await waitingRoomController.getMemberList(
      reset ? 0 : (userList.lastOrNull?.joinTime ?? 0),
      pageSize,
      pageOrder,
    );
    if (loadingToken != _loadingToken) return;
    _loadingMore = false;
    if (reset) {
      _userList = null;
      _users.clear();
      _userListChangeController.add(const Object());
      resetUnreadMemberCount();
    }
    final more = pageResult.data;
    if (more != null && more.isNotEmpty && !_disposed && isMySelfManager) {
      _userList = null;
      _users.addEntries(more.map((e) => MapEntry(e.uuid, e)));
      _userListChangeController.add(const Object());
      if (reset) {
        _unreadMemberUuids.addAll(more.map((e) => e.uuid));
        _unreadMemberCountNotify.value = _unreadMemberUuids.length;
      }
    }
  }

  Future<VoidResult> expelMember(String uuid,
      {bool disallowRejoin = false}) async {
    final result = await waitingRoomController.expelMember(uuid,
        disallowRejoin: disallowRejoin);
    if (!_disposed && result.isSuccess()) {
      _removeMemberInner(uuid);
    }
    return result;
  }

  Future<VoidResult> expelAllMembers({bool disallowRejoin = false}) {
    return waitingRoomController.expelAllMembers(
        disallowRejoin: disallowRejoin);
  }

  Future<VoidResult> admitMember(String uuid, {bool autoAdmit = false}) async {
    final result =
        await waitingRoomController.admitMember(uuid, autoAdmit: autoAdmit);
    if (!_disposed && result.code == NEErrorCode.waitingRoomMemberNotExist) {
      _removeMemberInner(uuid);
    }
    return result;
  }

  Future<VoidResult> admitAllMembers() {
    return waitingRoomController.admitAllMembers();
  }

  void _removeMemberInner(String uuid) {
    if (isMySelfManager && _users.remove(uuid) != null) {
      _userList = null;
      _userListChangeController.add(const Object());
    }
  }
}
