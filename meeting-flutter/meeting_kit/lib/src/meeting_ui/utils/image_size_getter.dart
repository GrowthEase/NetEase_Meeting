// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ImageSizeGetter {
  static Future<List<int>> getSizeAsync(String path) async {
    isg.ImageSizeGetter.registerDecoder(const _FixedJpegDecoder());

    var width = 0, height = 0;
    try {
      final size = await isg.ImageSizeGetter.getSizeAsync(
          isg.AsyncImageInput.input(FileInput(File(path))));
      width = size.needRotate ? size.height : size.width;
      height = size.needRotate ? size.width : size.height;
      assert(() {
        print('Image size success: $path, $size');
        return true;
      }());
    } catch (e) {
      assert(() {
        print('Image size error: $path, $e');
        return true;
      }());
    }
    return [width, height];
  }
}

// Fix 获取图片宽高不正确的问题
class _FixedJpegDecoder extends isg.BaseDecoder with isg.SimpleTypeValidator {
  const _FixedJpegDecoder();

  @override
  String get decoderName => 'jpeg';

  @override
  isg.Size getSize(isg.ImageInput input) {
    int start = 2;
    _BlockEntity? block;
    var orientation = 1;

    while (true) {
      block = _getBlockSync(input, start);

      if (block == null) {
        throw Exception('Invalid jpeg file');
      }

      // Check for App1 block
      if (block.type == 0xE1) {
        final app1BlockData = input.getRange(
          start,
          block.start + block.length,
        );
        final exifOrientation = _getOrientation(app1BlockData);
        if (exifOrientation != null) {
          orientation = exifOrientation;
        }
      }

      if (block.type == 0xC0 || block.type == 0xC2) {
        final widthList = input.getRange(start + 7, start + 9);
        final heightList = input.getRange(start + 5, start + 7);
        return _getSize(widthList, heightList, orientation);
      } else {
        start += block.length;
      }
    }
  }

  isg.Size _getSize(
      List<int> widthList, List<int> heightList, int orientation) {
    final width = convertRadix16ToInt(widthList);
    final height = convertRadix16ToInt(heightList);
    final needRotate = [5, 6, 7, 8].contains(orientation);
    return isg.Size(width, height, needRotate: needRotate);
  }

  @override
  Future<isg.Size> getSizeAsync(isg.AsyncImageInput input) async {
    int start = 2;
    _BlockEntity? block;
    var orientation = 1;

    while (true) {
      block = await _getBlockAsync(input, start);

      if (block == null) {
        throw Exception('Invalid jpeg file');
      }

      if (block.type == 0xE1) {
        final app1BlockData = await input.getRange(
          start,
          block.start + block.length,
        );
        final exifOrientation = _getOrientation(app1BlockData);
        if (exifOrientation != null) {
          orientation = exifOrientation;
        }
      }

      if (block.type == 0xC0 || block.type == 0xC2) {
        final widthList = await input.getRange(start + 7, start + 9);
        final heightList = await input.getRange(start + 5, start + 7);
        // DO NOT DO THIS
        // orientation = (await input.getRange(start + 9, start + 10))[0];
        return _getSize(widthList, heightList, orientation);
      } else {
        start += block.length;
      }
    }
  }

  _BlockEntity? _getBlockSync(isg.ImageInput input, int blockStart) {
    try {
      final blockInfoList = input.getRange(blockStart, blockStart + 4);

      if (blockInfoList[0] != 0xFF) {
        return null;
      }

      final blockSizeList = input.getRange(blockStart + 2, blockStart + 4);

      return _createBlock(blockSizeList, blockStart, blockInfoList);
    } catch (e) {
      return null;
    }
  }

  Future<_BlockEntity?> _getBlockAsync(
      isg.AsyncImageInput input, int blockStart) async {
    try {
      final blockInfoList = await input.getRange(blockStart, blockStart + 4);

      if (blockInfoList[0] != 0xFF) {
        return null;
      }

      final blockSizeList =
          await input.getRange(blockStart + 2, blockStart + 4);

      return _createBlock(blockSizeList, blockStart, blockInfoList);
    } catch (e) {
      return null;
    }
  }

  _BlockEntity _createBlock(
    List<int> sizeList,
    int blockStart,
    List<int> blockInfoList,
  ) {
    final blockLength =
        convertRadix16ToInt(sizeList) + 2; // +2 for 0xFF and TYPE
    final typeInt = blockInfoList[1];

    return _BlockEntity(typeInt, blockLength, blockStart);
  }

  @override
  isg.SimpleFileHeaderAndFooter get simpleFileHeaderAndFooter => _JpegInfo();

  int? _getOrientation(List<int> app1blockData) {
    // Check app1 block exif info is valid
    if (app1blockData.length < 14) {
      return null;
    }

    // Check app1 block exif info is valid
    final exifIdentifier = app1blockData.sublist(4, 10);

    if (!listEquals(exifIdentifier, [0x45, 0x78, 0x69, 0x66, 0x00, 0x00])) {
      return null;
    }

    final littleEndian = app1blockData[10] == 0x49;

    int getNumber(int start, int end) {
      final numberList = app1blockData.sublist(start, end);
      return convertRadix16ToInt(numberList, reverse: littleEndian);
    }

    // Get idf byte
    var idf0Start = 18;
    final tagEntryCount = getNumber(idf0Start, idf0Start + 2);

    var currentIndex = idf0Start + 2;

    for (var i = 0; i < tagEntryCount; i++) {
      final tagType = getNumber(currentIndex, currentIndex + 2);

      if (tagType == 0x0112) {
        return getNumber(currentIndex + 8, currentIndex + 10);
      }

      // every tag length is 0xC bytes
      currentIndex += 0xC;
    }

    return null;
  }
}

class _JpegInfo with isg.SimpleFileHeaderAndFooter {
  static const start = [0xFF, 0xD8];
  static const end = [0xFF, 0xD9];

  @override
  List<int> get endBytes => end;

  @override
  List<int> get startBytes => start;
}

class _BlockEntity {
  /// The block of jpeg format.
  _BlockEntity(this.type, this.length, this.start);

  /// The type of the block.
  int type;

  /// The length of the block.
  int length;

  /// Start of offset
  int start;

  @override
  String toString() {
    return "BlockEntity (type:$type, length:$length)";
  }
}
