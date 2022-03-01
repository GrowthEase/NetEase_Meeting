// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class _FutureImageStreamCompleter extends ImageStreamCompleter {
  final Future<double> futureScale;
  final InformationCollector? informationCollector;

  _FutureImageStreamCompleter(
      {required Future<ui.Codec> codec, required this.futureScale, this.informationCollector}) {
    codec.then<void>(_onCodecReady, onError: (Object error, StackTrace stack) {
      reportError(
        context: ErrorDescription('resolving a single-frame image stream'),
        exception: error,
        stack: stack,
        informationCollector: informationCollector,
        silent: true,
      );
    });
  }

  Future<void> _onCodecReady(ui.Codec codec) async {
    try {
      ui.FrameInfo nextFrame = await codec.getNextFrame();
      double scale = await futureScale;
      setImage(ImageInfo(image: nextFrame.image, scale: scale));
    } catch (exception, stack) {
      reportError(
        context: ErrorDescription('resolving an image frame'),
        exception: exception,
        stack: stack,
        informationCollector: this.informationCollector,
        silent: true,
      );
    }
  }
}

/// Performs exactly like a [MemoryImage] but instead of taking in bytes it takes
/// in a future that represents bytes.
class _FutureMemoryImage extends ImageProvider<_FutureMemoryImage> {
  /// Constructor for FutureMemoryImage.  [_futureBytes] is the bytes that will
  /// be loaded into an image and [_futureScale] is the scale that will be applied to
  /// that image to account for high-resolution images.
  const _FutureMemoryImage(this._futureBytes, this._futureScale);

  final Future<Uint8List> _futureBytes;
  final Future<double> _futureScale;

  /// See [ImageProvider.obtainKey].
  @override
  Future<_FutureMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_FutureMemoryImage>(this);
  }

  /// See [ImageProvider.load].
  @override
  ImageStreamCompleter load(_FutureMemoryImage key, DecoderCallback decode) {
    return _FutureImageStreamCompleter(
      codec: _loadAsync(key, decode),
      futureScale: _futureScale,
    );
  }

  Future<ui.Codec> _loadAsync(
      _FutureMemoryImage key, DecoderCallback decode) async {
    assert(key == this);
    return _futureBytes.then((Uint8List bytes) {
      return decode(bytes);
    });
  }

  /// See also:
  ///
  /// * [Object.operator ==].
  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final _FutureMemoryImage typedOther = other as _FutureMemoryImage;
    return _futureBytes == typedOther._futureBytes &&
        _futureScale == typedOther._futureScale;
  }

  /// See also:
  ///
  /// * [Object.hashCode].
  @override
  int get hashCode => hashValues(_futureBytes.hashCode, _futureScale);

  /// See [ImageProvider.toString].
  @override
  String toString() =>
      '$runtimeType(${describeIdentity(_futureBytes)}, scale: $_futureScale)';
}

class _PlatformImageKey {

  final String key;
  final ImageConfiguration? configuration;
  final int? quality;

  _PlatformImageKey({required this.key, this.quality, this.configuration});

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is _PlatformImageKey
        && other.key == key
        && other.quality == quality
        && other.configuration == configuration;
  }

  @override
  int get hashCode => hashValues(key, quality, configuration);

}

/// Class to help loading of iOS platform images into Flutter.
///
/// For example, loading an image that is in `Assets.xcassts`.
class PlatformImage extends ImageProvider<_PlatformImageKey> {
  static MethodChannel _channel = NEMeetingPlugin()._methodChannel;

  final String key;
  final int? quality;

  PlatformImage({required this.key, this.quality});

  @override
  Future<_PlatformImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_PlatformImageKey>(_PlatformImageKey(key: key, quality: quality, configuration: configuration));
  }

  @override
  ImageStreamCompleter load(_PlatformImageKey key, DecoderCallback decode) {
    Future<Map?> loadInfo = _channel.invokeMethod('loadImage', {
      'module': 'ImageLoader',
      'key': key.key,
      'imageQuality': key.quality,
      //'maxWidth': key.configuration?.size?.width,
      //'maxHeight': key.configuration?.size?.height,
    });
    Completer<Uint8List> bytesCompleter = Completer<Uint8List>();
    Completer<double> scaleCompleter = Completer<double>();
    loadInfo.then((map) {
      if (bytesCompleter.isCompleted) return;
      if (map != null || map!["scale"] != null || map["data"] != null) {
        scaleCompleter.complete(map["scale"] as double?);
        bytesCompleter.complete(map["data"] as Uint8List?);
      } else {
        bytesCompleter.completeError("Load image named '${key.key}' error");
      }
    });
    return _FutureImageStreamCompleter(
      codec: bytesCompleter.future.then((Uint8List bytes) {
        return decode(bytes);
      }),
      futureScale: scaleCompleter.future,
    );
  }

}
