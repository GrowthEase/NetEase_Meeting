// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingImageMessageViewer extends StatefulWidget {
  final ImageMessageState message;
  final Future<VoidResult>? Function(ImageMessageState message)
      downloadAttachmentCallback;

  const MeetingImageMessageViewer({
    Key? key,
    required this.message,
    required this.downloadAttachmentCallback,
  }) : super(key: key);

  @override
  State<MeetingImageMessageViewer> createState() =>
      _MeetingImageMessageViewerState();
}

class _MeetingImageMessageViewerState extends State<MeetingImageMessageViewer> {
  final _imageFilePathCompleter = Completer<String>();

  @override
  void initState() {
    super.initState();
    _computeImageFilePath();
  }

  @override
  void dispose() {
    if (widget.message is InMessageState) {
      (widget.message as InMessageState)
          .attachmentDownloadProgress
          .removeListener(_onOriginFileProgress);
    }
    super.dispose();
  }

  void _computeImageFilePath() {
    if (_imageFilePathCompleter.isCompleted) {
      return;
    }
    final msg = widget.message;
    var path = msg.originPath;
    final file = File(path);
    if (file.existsSync()) {
      _imageFilePathCompleter.complete(path);
    } else if (msg is InMessageState) {
      (msg as InMessageState)
          .attachmentDownloadProgress
          .addListener(_onOriginFileProgress);
      widget.downloadAttachmentCallback(msg);
    }
  }

  void _onOriginFileProgress() async {
    if (_imageFilePathCompleter.isCompleted) {
      return;
    }
    final path = widget.message.originPath;
    await Future.delayed(Duration(milliseconds: 100));
    if (mounted &&
        await File(path).exists() == true &&
        mounted &&
        !_imageFilePathCompleter.isCompleted) {
      _imageFilePathCompleter.complete(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // double sw = min(size.width, size.height);
    double sh = max(size.width, size.height);
    final child = SafeArea(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: FutureBuilder(
                future: _imageFilePathCompleter.future,
                initialData: widget.message.thumbPath,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return InteractiveViewer(
                      child: Hero(
                        tag: widget.message.uuid,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          child: Image.file(
                            File(snapshot.requireData),
                            fit: BoxFit.contain,
                            // cacheWidth: sw.ceil(),
                            cacheHeight: sh.ceil(),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4C4C4C),
                    ),
                    margin: EdgeInsets.only(bottom: 35, left: 20),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () => saveToGallery(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4C4C4C),
                    ),
                    margin: EdgeInsets.only(bottom: 35, right: 20),
                    child: Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: child,
    );
  }

  void saveToGallery() async {
    final path = await _imageFilePathCompleter.future;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    if (statuses[Permission.storage] == PermissionStatus.granted) {
      final result = await ImageGallerySaver.saveFile(path);
      if (result['isSuccess'] == true) {
        _toastResult(true, _Strings.saveToGallerySuccess);
      } else {
        _toastResult(false, _Strings.saveToGalleryFail);
      }
    } else {
      _toastResult(false, _Strings.saveToGalleryFailNoPermission);
    }
  }

  void _toastResult(bool success, String msg) {
    if (mounted) {
      ToastUtils.showToast2(context, (context) {
        return Center(
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 10),
            decoration: ShapeDecoration(
              color: Color(0xFF4C4C4C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(height: 20),
                Text(
                  msg,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
  }
}
