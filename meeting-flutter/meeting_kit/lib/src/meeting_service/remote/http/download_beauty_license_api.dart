// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 下载美颜证书
class _DownloadBeautyLicenseApi extends HttpApi<Uint8List> {
  String licenseUrl;
  ProgressCallback progressCallback;

  _DownloadBeautyLicenseApi(this.licenseUrl, this.progressCallback);

  @override
  String path() => throw UnimplementedError();

  @override
  Future<NEResult<Uint8List>> execute() async {
    var response = await _HttpExecutor().download(licenseUrl, progressCallback);
    if (response == null || response.statusCode != MeetingErrorCode.success) {
      return NEResult(code: MeetingErrorCode.networkError);
    } else {
      // var raf = file.openSync(mode: FileMode.write);
      // raf.writeFromSync(response.data);
      // await raf.close();
      return NEResult(
          code: MeetingErrorCode.success, data: response.data as Uint8List);
    }
  }

  @override
  double result(Map<dynamic, dynamic> map) {
    throw UnimplementedError();
  }

  @override
  Map data() => throw UnimplementedError();
}
