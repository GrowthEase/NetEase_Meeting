// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'crop_const.dart';
import 'crop_error.dart';
import 'crop_target_size.dart';

enum _CropAction { move, resizeCropArea, scale }

enum CropHandle { topLeft, topRight, bottomRight, bottomLeft }

typedef OnCropError = void Function(ImageCropError);
typedef OnCropDone = FutureOr<void> Function(MemoryImage);

class ImageCropController extends ChangeNotifier {
  final ImageProvider imageProvider;
  final ImageCropTargetSize target;
  double _maximumScale;

  /// 裁剪完成
  final OnCropDone onDone;

  /// 裁剪失败
  final OnCropError onError;

  /// 取消裁剪
  final Function() onCancel;

  AnimationController? _activeAnimation;

  final bool alwaysShowGrid;

  AnimationController? get activeAnimation => _activeAnimation;

  set activeAnimation(AnimationController? value) {
    _activeAnimation = value;
    if (alwaysShowGrid) {
      _activeAnimation?.value = 1.0;
    }
  }

  Rect? _viewport;
  Rect _cropArea = Rect.zero;
  Rect _imageView = Rect.zero;
  double _scale = 1;

  _CropAction? _action;
  CropHandle? _handle;

  double _startScale = 1;

  late ImageStream _imageStream;

  ui.Image? _image;

  ui.Image? get image => _image;

  Rect get imageView => _imageView;

  Rect get cropArea => _cropArea;

  double get scale => _scale;

  ImageCropController({
    required this.imageProvider,
    required this.onDone,
    required this.onError,
    required this.onCancel,
    required this.target,
    double maximumScale = 2.0,
    this.alwaysShowGrid = false,
  })  : assert(maximumScale > 0.0, 'maximumScale should be greater than 0.0'),
        _maximumScale = maximumScale;

  double get active => _activeAnimation?.value ?? 0.0;

  double _minimumScale(ui.Image image) {
    return max(_cropArea.width / image.width, _cropArea.height / image.height);
  }

  @override
  void dispose() {
    _activeAnimation?.dispose();
    super.dispose();
  }

  cancel() {
    onCancel();
  }

  Future<void> crop(double pixelRatio) async {
    final vp = _viewport;
    final image = _image;
    if (image == null || vp == null) {
      return;
    }

    try {
      final recorder = ui.PictureRecorder();

      final src = Rect.fromLTWH(
        0.0,
        0.0,
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final offset = Offset.zero - _cropArea.topLeft;
      Canvas(recorder, vp)
        ..scale(pixelRatio / target.scaleFactor(_cropArea))
        ..translate(offset.dx, offset.dy)
        ..drawImageRect(
          image,
          src,
          _imageView,
          ui.Paint()..isAntiAlias = false,
        );

      final picture = recorder.endRecording();
      try {
        final image = await picture.toImage(
          (target.width * pixelRatio).toInt(),
          (target.height * pixelRatio).toInt(),
        );
        try {
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          if (data == null) {
            onError(ImageCropError.noData());
            return;
          }
          await onDone(
            MemoryImage(data.buffer.asUint8List(), scale: pixelRatio),
          );
        } catch (e, st) {
          onError(ImageCropError.imageDecode(e, st));
        } finally {
          image.dispose();
        }
      } catch (e, st) {
        onError(ImageCropError.pictureToImage(e, st));
      } finally {
        picture.dispose();
      }
    } catch (e, st) {
      onError(ImageCropError.resize(e, st));
    } finally {}
  }

  void resolveImage(ImageConfiguration config) {
    _imageStream = imageProvider.resolve(config);
    _imageStream
        .addListener(ImageStreamListener(_updateImage, onError: _onImageError));
  }

  void handleScaleStart(ScaleStartDetails details) {
    if (_handle != null) return;
    _activate();
    _action = null;
    _handle = _hitCropHandle(details.localFocalPoint);
    _startScale = _scale;
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
    final vp = _viewport;
    if (vp == null) {
      return;
    }
    switch (_getAction(details)) {
      case _CropAction.move:
        _moveImage(vp, details);
        break;
      case _CropAction.resizeCropArea:
        _resizeCropArea(vp, details);
        break;
      case _CropAction.scale:
        _scaleImage(vp, details);
        break;
    }
  }

  void handleScaleEnd(ScaleEndDetails details) {
    _handle = null;
    if (!alwaysShowGrid) {
      _activeAnimation?.animateTo(
        0.0,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 250),
      );
    }
    if (_getActionEx(details) == _CropAction.resizeCropArea) {
      final defaultArea =
          target.containedIn(_viewport!.deflate(kCropAreaPadding));
      final image = _image;
      if (image != null) {
        /// 对imageView进行放大处理
        final areaScale = defaultArea.width / _cropArea.width;
        _scale = _startScale * areaScale;
        final dx = _cropArea.center.dx - defaultArea.center.dx;
        final dy = _cropArea.center.dy - defaultArea.center.dy;
        final width = image.width * _scale;
        final height = image.height * _scale;
        if (_scale <= _maximumScale) {
          final view;
          if (dx <= 0 && dy <= 0) {
            /// 第二象限
            final a = defaultArea.topLeft;
            final b = _imageView.topLeft;
            final left = (1 - areaScale) * a.dx + areaScale * b.dx;
            final top = (1 - areaScale) * a.dy + areaScale * b.dy;
            view = Rect.fromLTWH(left, top, width, height);
          } else if (dx <= 0 && dy >= 0) {
            /// 第三象限
            final a = defaultArea.bottomLeft;
            final b = _imageView.bottomLeft;
            final left = (1 - areaScale) * a.dx + areaScale * b.dx;
            final bottom = areaScale * b.dy + (1 - areaScale) * a.dy;
            view = Rect.fromLTWH(left, bottom - height, width, height);
          } else if (dx >= 0 && dy <= 0) {
            /// 第一象限
            final a = defaultArea.topRight;
            final b = _imageView.topRight;
            final right = areaScale * b.dx + (1 - areaScale) * a.dx;
            final top = (1 - areaScale) * a.dy + areaScale * b.dy;
            view = Rect.fromLTWH(right - width, top, width, height);
          } else {
            /// 第四象限
            final a = defaultArea.bottomRight;
            final b = _imageView.bottomRight;
            final right = areaScale * b.dx + (1 - areaScale) * a.dx;
            final bottom = areaScale * b.dy + (1 - areaScale) * a.dy;
            view = Rect.fromLTWH(right - width, bottom - height, width, height);
          }
          if (view != _imageView) {
            _imageView = view;
            notifyListeners();
          }
        }
      }
      _cropArea = defaultArea;
    }
  }

  void _moveImage(Rect vp, ScaleUpdateDetails details) {
    final image = _image;
    if (image == null) {
      return;
    }

    final delta = details.focalPointDelta;
    final newView = _clampImageWithinCropArea(_imageView.shift(delta));
    if (newView != _imageView) {
      _imageView = newView;
      notifyListeners();
    }
  }

  void _scaleImage(Rect vp, ScaleUpdateDetails details) {
    final image = _image;
    if (image == null) {
      return;
    }

    _scale = _startScale * details.scale;
    if (_scale > _maximumScale) {
      _scale = _maximumScale;
    }

    final view = _clampImageWithinCropArea(
      Rect.fromCenter(
        center: _imageView.center,
        width: image.width * _scale,
        height: image.height * _scale,
      ),
    );
    if (view != _imageView) {
      _imageView = view;
      notifyListeners();
    }
  }

  void _resizeCropArea(Rect vp, ScaleUpdateDetails details) {
    final deltaY = details.focalPointDelta.dy;
    final deltaX = details.focalPointDelta.dx;
    var area;
    switch (_handle) {
      case null:
        return;
      case CropHandle.topLeft:
        double length =
            min(_cropArea.height - deltaY, _cropArea.width - deltaX);
        length = max(length, kMinCropArea);
        area = _clampCropAreaWithinViewport(
          vp.deflate(kCropAreaPadding),
          Rect.fromLTWH(
            _cropArea.right - length,
            _cropArea.bottom - length,
            length,
            length,
          ),
        );
        break;
      case CropHandle.bottomRight:
        double length =
            min(_cropArea.height + deltaY, _cropArea.width + deltaX);
        length = max(length, kMinCropArea);
        area = _clampCropAreaWithinViewport(
          vp.deflate(kCropAreaPadding),
          Rect.fromLTWH(
            _cropArea.left,
            _cropArea.top,
            length,
            length,
          ),
        );
        break;
      case CropHandle.topRight:
        double length =
            min(_cropArea.height - deltaY, _cropArea.width + deltaX);
        length = max(length, kMinCropArea);
        area = _clampCropAreaWithinViewport(
          vp.deflate(kCropAreaPadding),
          Rect.fromLTWH(
            _cropArea.left,
            _cropArea.bottom - length,
            length,
            length,
          ),
        );
        break;
      case CropHandle.bottomLeft:
        double length =
            min(_cropArea.height + deltaY, _cropArea.width - deltaX);
        length = max(length, kMinCropArea);
        area = _clampCropAreaWithinViewport(
          vp.deflate(kCropAreaPadding),
          Rect.fromLTWH(
            _cropArea.right - length,
            _cropArea.top,
            length,
            length,
          ),
        );
        break;
    }

    if (area != _cropArea) {
      _cropArea = area;
      _imageView = _clampImageWithinCropArea(_imageView);
      notifyListeners();
    }
  }

  _CropAction _getAction(ScaleUpdateDetails details) {
    if (_action != null) {
      return _action!;
    }
    if (_handle == null) {
      return _action =
          details.pointerCount == 2 ? _CropAction.scale : _CropAction.move;
    } else {
      return _action = _CropAction.resizeCropArea;
    }
  }

  _CropAction _getActionEx(ScaleEndDetails details) {
    if (_action != null) {
      return _action!;
    }
    if (_handle == null) {
      return _action =
          details.pointerCount == 2 ? _CropAction.scale : _CropAction.move;
    } else {
      return _action = _CropAction.resizeCropArea;
    }
  }

  void _activate() {
    _activeAnimation?.animateTo(
      1.0,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  CropHandle? _hitCropHandle(Offset hitPoint) {
    final topLeftHitBox = Rect.fromCenter(
      center: _cropArea.topLeft,
      width: kCropHandleHitSize,
      height: kCropHandleHitSize,
    );
    if (topLeftHitBox.contains(hitPoint)) {
      return CropHandle.topLeft;
    }

    final topRightHitBox = Rect.fromCenter(
      center: _cropArea.topRight,
      width: kCropHandleHitSize,
      height: kCropHandleHitSize,
    );
    if (topRightHitBox.contains(hitPoint)) {
      return CropHandle.topRight;
    }

    final bottomLeftHitBox = Rect.fromCenter(
      center: _cropArea.bottomLeft,
      width: kCropHandleHitSize,
      height: kCropHandleHitSize,
    );
    if (bottomLeftHitBox.contains(hitPoint)) {
      return CropHandle.bottomLeft;
    }

    final bottomRightHitBox = Rect.fromCenter(
      center: _cropArea.bottomRight,
      width: kCropHandleHitSize,
      height: kCropHandleHitSize,
    );
    if (bottomRightHitBox.contains(hitPoint)) {
      return CropHandle.bottomRight;
    }

    return null;
  }

  Rect _clampImageWithinCropArea(Rect view) {
    final image = _image;
    if (image == null) {
      return view;
    }

    final minScale = _minimumScale(image);
    if (_scale < minScale) {
      _scale = minScale;
      view = Rect.fromCenter(
        center: view.center,
        width: image.width * _scale,
        height: image.height * _scale,
      );
    }

    final boundaries = _cropArea;
    var dx = 0.0;
    var dy = 0.0;

    if (boundaries.left < view.left) {
      dx = boundaries.left - view.left;
    } else if (boundaries.right > view.right) {
      dx = boundaries.right - view.right;
    }
    if (boundaries.top < view.top) {
      dy = boundaries.top - view.top;
    } else if (boundaries.bottom > view.bottom) {
      dy = boundaries.bottom - view.bottom;
    }

    return (dx == 0.0 && dy == 0.0) ? view : view.translate(dx, dy);
  }

  Rect _clampCropAreaWithinViewport(Rect vp, Rect area) {
    return vp.width < area.width || vp.height < area.height
        ? target.containedIn(vp)
        : area;
  }

  /// size: 整个画布的尺寸
  Rect setViewport(Size size) {
    if (_viewport?.size == size) {
      return _viewport!;
    }
    final vp = _viewport = Offset.zero & size;

    /// 默认的裁剪框位置
    _cropArea = target.containedIn(vp.deflate(kCropAreaPadding));
    _centerImageView();
    return vp;
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    final image = imageInfo.image;
    _image = image;
    _scale = imageInfo.scale;

    _centerImageView();
    notifyListeners();
  }

  void _centerImageView() {
    final image = _image;
    final vp = _viewport;

    if (image != null && vp != null) {
      final target = ImageCropTargetSize(image.width, image.height);
      _imageView = target.cover(vp);

      /// 当前的缩放比例
      _scale = target.scaleFactor(_imageView);
      if (_scale > _maximumScale) {
        _maximumScale = _scale;
      }
    }
  }

  void _onImageError(Object error, StackTrace? stackTrace) {
    onError(ImageCropError.load(error, stackTrace));
  }
}
