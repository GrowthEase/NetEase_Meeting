// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 通讯录服务提供了账号通讯录相关的能力。
/// 通过这个服务可以获取到通讯录成员及其详细信息。
/// 可通过 [getContactsService] 获取对应的服务实例。
abstract class NEContactsService {
  /// 根据电话号码进行企业通讯录模糊搜索
  ///
  /// [phoneNumber] 用户电话号码，不可空
  /// [pageSize] 分页大小
  /// [pageNum] 页码
  ///
  /// 结果回调，回调数据类型为[NEContact]列表
  Future<NEResult<List<NEContact>>> searchContactListByPhoneNumber(
      String? phoneNumber, int pageSize, int pageNum);

  /// 根据用户名进行企业通讯录模糊搜索
  ///
  /// [name] 用户名，不可空
  /// [pageSize] 分页大小
  /// [pageNum] 页码
  ///
  /// 结果回调，回调数据类型为[NEContact]列表
  Future<NEResult<List<NEContact>>> searchContactListByName(
      String? name, int pageSize, int pageNum);

  /// 通讯录用户信息查询
  ///
  /// [userUuids] 用户id列表
  ///
  /// 结果回调，回调数据类型为[NEContactsInfoResult]
  Future<NEResult<NEContactsInfoResult>> getContactsInfo(
      List<String> userUuids);
}
