// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEImageGallerySaver extends _Service {
  NEImageGallerySaver(
      MethodChannel _methodChannel, Map<String, _Handler> handlerMap)
      : super(_methodChannel, handlerMap);

  @override
  String _getModule() {
    return 'NEImageGallerySaver';
  }

  @override
  Future<dynamic> _handlerMethod(
      String method, int code, Map arg, dynamic callback) {
    return Future<dynamic>.value();
  }

  /// save image to Gallery
  /// imageBytes can't null
  /// return Map type
  /// for example:{"isSuccess":true, "filePath":String?}
  FutureOr<dynamic> saveImage(Uint8List imageBytes,
      {int quality = 80,
      String? name,
      bool isReturnImagePathOfIOS = false}) async {
    final result = await _methodChannel.invokeMethod(
      'saveImageToGallery',
      buildArguments(arg: <String, dynamic>{
        'imageBytes': imageBytes,
        'quality': quality,
        'name': name,
        'isReturnImagePathOfIOS': isReturnImagePathOfIOS
      }),
    );
    return result;
  }

  /// Save the PNG，JPG，JPEG image or video located at [file] to the local device media gallery.
  Future saveFile(String file,
      {String? name, String? extension, bool isReturnPathOfIOS = false}) async {
    final result = await _methodChannel.invokeMethod(
      'saveFileToGallery',
      buildArguments(arg: <String, dynamic>{
        'file': file,
        'name': name,
        'extension': extension,
        'isReturnPathOfIOS': isReturnPathOfIOS
      }),
    );
    return result;
  }
}
