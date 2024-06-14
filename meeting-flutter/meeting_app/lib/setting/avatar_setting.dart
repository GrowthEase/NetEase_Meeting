// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../image_crop/crop_controller.dart';
import '../image_crop/crop_error.dart';
import '../image_crop/crop_target_size.dart';
import '../image_crop/crop_widget.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../service/repo/user_repo.dart';

class AvatarSetting extends StatefulWidget {
  const AvatarSetting({super.key});

  @override
  State<AvatarSetting> createState() => _AvatarSettingState();
}

class _AvatarSettingState extends State<AvatarSetting> {
  FileImage? _fileImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fileImage == null) {
      setState(() {
        _fileImage = ModalRoute.of(context)!.settings.arguments as FileImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fileImage == null) {
      return Container();
    } else {
      return Container(
        color: Colors.black,
        child: ImageCropper(
          ImageCropController(
            imageProvider: _fileImage!,
            target: const ImageCropTargetSize(320, 320),
            maximumScale: 4,
            onDone: _onDone,
            onError: _onError,
            onCancel: _onCancel,
          ),
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        ),
      );
    }
  }

  void _onDone(MemoryImage img) async {
    LoadingUtil.showLoading();
    final filePath = await _saveImage(img);
    final ret =
        await NEMeetingKit.instance.getAccountService().updateAvatar(filePath);

    /// 上传完成后删除本地文件
    File(filePath).delete();
    LoadingUtil.cancelLoading();
    ToastUtils.showToast(
        context,
        ret.isSuccess()
            ? getAppLocalizations().settingAvatarUpdateSuccess
            : getAppLocalizations().settingAvatarUpdateFail);
    Navigator.of(context).pop();
  }

  Future<String> _saveImage(MemoryImage img) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final filePath =
        '${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(img.bytes);
    return filePath;
  }

  void _onError(ImageCropError e) {}

  void _onCancel() {
    Navigator.of(context).pop();
  }
}
