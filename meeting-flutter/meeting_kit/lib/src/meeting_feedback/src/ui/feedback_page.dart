// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of feedback;

class FeedbackPage extends StatefulWidget {
  FeedbackPage();

  @override
  State<StatefulWidget> createState() {
    return _FeedbackPageState();
  }
}

class _FeedbackPageState extends State<FeedbackPage> with _AloggerMixin {
  _FeedbackPageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: NEMeetingKitFeatureConfig(
              child: FeedbackContent(onFeedback: _onFeedbackWrap),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  NEMeetingUIKitLocalizations get localizations =>
      NEMeetingUIKit.instance.getUIKitLocalizations();

  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        localizations.feedback,
        style: TextStyle(
            color: _UIColors.color1E1E27,
            fontSize: 16,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.0,
      leading: IconButton(
        icon: const Icon(
          NEMeetingIconFont.icon_yx_returnx,
          size: 14,
          color: _UIColors.color1E1E27,
        ),
        padding: EdgeInsets.all(5),
        onPressed: () {
          Navigator.maybePop(context);
        },
      ),
    );
  }

  bool isLoading = false;

  void _onFeedbackWrap(_FeedbackResult result) async {
    if (isLoading) return;
    isLoading = true;
    LoadingUtil.showLoading();
    await Future.delayed(Duration(milliseconds: 20));
    await _onFeedback(result);
    isLoading = false;
    LoadingUtil.cancelLoading();
  }

  Future<void> _onFeedback(_FeedbackResult feedbackResult) async {
    if (!await ConnectivityManager().isConnected()) {
      ToastUtils.showToast(
          context, localizations.globalNetworkUnavailableCheck);
      return;
    }

    var result = await FeedbackRepository()
        .addFeedbackTask(feedbackResult.convertToFeedback())
        .whenComplete(() {
      feedbackResult.images?.forEach((path) {
        try {
          File(path).delete();
        } catch (e) {
          apiLogger.e(
            '_onFeedbackResult: $e',
          );
        }
      });
    });

    apiLogger.i(
      '_onFeedbackResult: ${result.toString()}',
    );

    if (!mounted) return;
    ToastUtils.showToast(
        context,
        result.isSuccess()
            ? localizations.feedbackSuccess
            : localizations.feedbackFail,
        key: ValueKey('feedbackResult'));

    UINavUtils.pop(context);
  }
}

class _FeedBackItem {
  String name;
  bool needQuestionDetail;
  bool selected = false;

  _FeedBackItem(this.name, {this.needQuestionDetail = false});
}

class _FeedbackResult {
  final List<String> audioProblems;
  final List<String> videoProblems;
  final List<String> otherProblems;
  final String? desc;
  final DateTime? dateTime;
  final List<String>? images;

  _FeedbackResult(
    this.audioProblems,
    this.videoProblems,
    this.otherProblems,
    this.desc,
    this.dateTime,
    this.images,
  );

  NEFeedback convertToFeedback({bool needAudioDump = false}) {
    var category = [
      ...audioProblems,
      ...videoProblems,
      ...otherProblems,
    ].join(',');

    var description = '${desc}';

    if (dateTime != null) {
      description = '$description@${dateTime}';
    }
    final seconds = (dateTime?.millisecondsSinceEpoch ?? 0 / 1000).toInt();
    return NEFeedback(
        category: category,
        description: description,
        time: seconds,
        imageList: images,
        needAudioDump: needAudioDump);
  }
}

class FeedbackContent extends StatefulWidget {
  final EdgeInsets? padding;
  final void Function(_FeedbackResult) onFeedback;

  const FeedbackContent({Key? key, required this.onFeedback, this.padding})
      : super(key: key);

  @override
  State<FeedbackContent> createState() => _FeedbackContentState();
}

class _FeedbackContentState extends State<FeedbackContent> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const maxImageCount = 3;
  static const imageItemSpace = 14;
  final imagePathList = <String>[];
  late int imageSize;
  final maxDate = DateTime.now();
  late DateTime? selectingDate = maxDate;
  DateTime? feedbackDate;

  final audioQuestions = <_FeedBackItem>{};
  final videoQuestions = <_FeedBackItem>{};
  final otherQuestions = <_FeedBackItem>{};
  late ModalRoute myselfRoute;

  void didChangeDependencies() {
    super.didChangeDependencies();
    imageSize = (MediaQuery.of(context).size.width -
            40 -
            (maxImageCount - 1) * imageItemSpace) ~/
        maxImageCount;
    imageSize = imageSize > 0 ? imageSize : 0;
    myselfRoute = ModalRoute.of(context)!;
  }

  NEMeetingUIKitLocalizations get localizations =>
      NEMeetingUIKit.instance.getUIKitLocalizations();

  Widget buildContent() {
    return Container(
      color: _UIColors.globalBg,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MeetingCard(children: [
              buildTitle(localizations.feedbackTitleAudio),
              ...audioQuestions.map((item) {
                return buildItem(item);
              }).toList()
            ]),
            MeetingCard(children: [
              buildTitle(localizations.feedbackTitleVideo),
              ...videoQuestions.map((item) {
                return buildItem(item);
              }).toList()
            ]),
            MeetingCard(children: [
              buildTitle(localizations.feedbackTitleOthers),
              ...otherQuestions.map((item) {
                return buildItem(item);
              }).toList()
            ]),
            MeetingCard(children: [
              buildTitle(localizations.feedbackTitleDescription),
              buildInputItem(),
            ]),
            MeetingCard(children: [
              buildTitle(localizations.feedbackTitleExtras),
              MeetingArrowItem(
                title: localizations.feedbackTitleDate,
                content: feedbackDate?.formatToTimeString('yyyy-MM-dd HH:mm') ??
                    localizations.feedbackContentEmpty,
                onTap: selectDate,
                titleTextStyle: TextStyle(
                  color: _UIColors.color53576A,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              buildImagePick(),
            ]),
            SizedBox(height: 40),
            buildSubmit(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildImagePick() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...Iterable.generate(imagePathList.length, (index) {
              return Container(
                width: imageSize.toDouble(),
                height: imageSize.toDouble(),
                margin: EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      child: Image.file(
                        File(imagePathList[index]),
                        fit: BoxFit.fill,
                        cacheWidth: imageSize,
                        cacheHeight: imageSize,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          imagePathList.removeAt(index);
                        });
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close_outlined,
                            size: 14.0,
                            color: _UIColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (imagePathList.length < maxImageCount)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: selectImage,
                child: Container(
                  width: imageSize.toDouble(),
                  height: imageSize.toDouble(),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _UIColors.colorE1E3E5,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: _UIColors.color_999999,
                      ),
                      SizedBox(
                        height: 7.0,
                      ),
                      Text(
                        localizations.feedbackTitleSelectPicture,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: _UIColors.color_999999,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void selectDate() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
              color: _UIColors.white,
              height: MediaQuery.of(context).copyWith().size.height / 3,
              child: CupertinoDatePicker(
                maximumDate: maxDate,
                initialDateTime: maxDate,
                use24hFormat: true,
                backgroundColor: _UIColors.white,
                onDateTimeChanged: (DateTime time) {
                  debugPrint('Feedback select date: $time');
                  selectingDate = time;
                },
              ));
        }).then((value) {
      if (!mounted || selectingDate == feedbackDate) return;
      setState(() {
        feedbackDate = selectingDate;
        selectingDate = null;
      });
    });
  }

  void selectImage() async {
    final hasPermission = await requestStoragePermissionForImagePicker(context);
    if (!mounted || !myselfRoute.isActive) return;
    if (!hasPermission) {
      ToastUtils.showToast(
          context, context.meetingUiLocalizations.globalNoPermission);
      return;
    }
    FilePicker.platform
        .pickFiles(
      type: FileType.image,
    )
        .then((value) {
      if (!mounted) return;
      final platformFile = value?.files.first;
      if (platformFile == null) return;
      final path = platformFile.path;
      if (path != null && File(path).existsSync()) {
        setState(() {
          imagePathList.add(path);
        });
      }
    });
  }

  Future<bool> requestStoragePermissionForImagePicker(
      BuildContext context) async {
    if (!Platform.isAndroid) return true;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.version.sdkInt >= 33) return true;
    final granted = await Permission.storage.isGranted;
    if (granted) return true;
    final canRequest = await showDialog(
            context: context,
            useRootNavigator: false,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(localizations.globalPhotosPermission),
                content: Text(localizations.globalPhotosPermissionRationale),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(localizations.globalCancel),
                    onPressed: () => Navigator.of(context).pop(false),
                    textStyle: TextStyle(color: _UIColors.color666666),
                  ),
                  CupertinoDialogAction(
                    child: Text(localizations.globalGotoSettings),
                    onPressed: () => Navigator.of(context).pop(true),
                    textStyle: TextStyle(color: _UIColors.color337eff),
                  ),
                ],
              );
            }) ==
        true;
    if (canRequest && await Permission.storage.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }
    return canRequest &&
        await Permission.storage.request() == PermissionStatus.granted;
  }

  Widget buildItem(_FeedBackItem categoryQuestion) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: 48,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              categoryQuestion.selected = !categoryQuestion.selected;
            });
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(right: 12),
                  alignment: Alignment.centerRight,
                  child: checkIcon(categoryQuestion.selected),
                ),
                Expanded(
                  child: Text(
                    categoryQuestion.name,
                    strutStyle: StrutStyle(forceStrutHeight: true),
                    style: TextStyle(
                        color: _UIColors.color53576A,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none),
                  ),
                )
              ]),
        ));
  }

  Widget checkIcon(bool value, {double iconSize = 16}) {
    return value
        ? Icon(
            NEMeetingIconFont.icon_checked,
            color: _UIColors.color337eff,
            size: iconSize,
          )
        : Icon(
            NEMeetingIconFont.icon_unchecked,
            color: _UIColors.colorCDCFD7,
            size: iconSize,
          );
  }

  Widget buildTitle(String title) {
    return MeetingArrowItem(
        title: title,
        showArrow: false,
        titleTextStyle: TextStyle(
          color: _UIColors.color1E1F27,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ));
  }

  bool isInit = false;

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      isInit = true;
      _initQuestions();
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: hideKeyboard,
      child: buildContent(),
    );
  }

  void _initQuestions() {
    audioQuestions.addAll([
      _FeedBackItem(localizations.feedbackAudioLatency),
      _FeedBackItem(localizations.feedbackAudioMechanicalNoise),
      _FeedBackItem(localizations.feedbackAudioFreeze),
      _FeedBackItem(localizations.feedbackAudioNoise),
      _FeedBackItem(localizations.feedbackAudioEcho),
      _FeedBackItem(localizations.feedbackCannotHearOthers),
      _FeedBackItem(localizations.feedbackCannotHearMe),
      _FeedBackItem(localizations.feedbackAudioVolumeSmall),
    ]);
    videoQuestions.addAll([
      _FeedBackItem(localizations.feedbackVideoFreeze),
      _FeedBackItem(localizations.feedbackVideoIntermittent),
      _FeedBackItem(localizations.feedbackVideoTearing),
      _FeedBackItem(localizations.feedbackVideoTooBrightOrDark),
      _FeedBackItem(localizations.feedbackVideoBlurry),
      _FeedBackItem(localizations.feedbackVideoNoise),
      _FeedBackItem(localizations.feedbackAudioVideoNotSync),
    ]);
    otherQuestions.addAll([
      _FeedBackItem(localizations.feedbackUnexpectedExit),
      _FeedBackItem(localizations.feedbackOthers, needQuestionDetail: true),
    ]);
  }

  Widget buildInputItem() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 14),
      padding: EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: _UIColors.white,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: _focusNode.hasFocus
              ? _UIColors.color337eff
              : _UIColors.colorE6E7EB,
          width: 1,
        ),
      ),
      child: Container(
        height: 80,
        child: TextField(
          autofocus: false,
          focusNode: _focusNode,
          controller: _textController,
          onChanged: (text) {
            setState(() {});
          },
          // maxLength: 200,
          minLines: 3,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          onEditingComplete: hideKeyboard,
          keyboardAppearance: Brightness.light,
          decoration: InputDecoration(
              hintText: localizations.feedbackOtherTip,
              hintStyle: TextStyle(fontSize: 14, color: _UIColors.colorCDCFD7),
              border: InputBorder.none,
              suffixIcon: _focusNode.hasFocus && _textController.text.isNotEmpty
                  ? ClearIconButton(onPressed: () {
                      _textController.clear();
                      setState(() {});
                    })
                  : null),
          style: TextStyle(
            color: _UIColors.color1E1E27,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget buildSubmit() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                return states.contains(WidgetState.disabled)
                    ? _UIColors.color50337eff
                    : _UIColors.color337eff;
              }),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                      color: canSubmit()
                          ? _UIColors.color337eff
                          : _UIColors.color50337eff,
                      width: 0),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              )),
          onPressed: canSubmit() ? commitFeedbackResult : null,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Text(
              localizations.globalSubmit,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }

  void hideKeyboard() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  bool canSubmit() {
    if (otherQuestions.any((element) =>
        element.selected &&
        element.needQuestionDetail &&
        _textController.text.isEmpty)) {
      return false;
    }

    return audioQuestions.any((element) => element.selected) ||
        videoQuestions.any((element) => element.selected) ||
        otherQuestions.any((element) => element.selected) ||
        _textController.text.isNotEmpty;
  }

  Future<void> commitFeedbackResult() async {
    if (!await ConnectivityManager().isConnected()) {
      ToastUtils.showToast(
          context, localizations.globalNetworkUnavailableCheck);
      return;
    }

    hideKeyboard();

    final audioProblems = audioQuestions
        .where((element) => element.selected)
        .map((e) => e.name)
        .toList();
    final videoProblems = videoQuestions
        .where((element) => element.selected)
        .map((e) => e.name)
        .toList();
    final otherProblems = otherQuestions
        .where((element) => element.selected)
        .map((e) => e.name)
        .toList();
    widget.onFeedback(
      _FeedbackResult(
        audioProblems,
        videoProblems,
        otherProblems,
        _textController.text.trim(),
        feedbackDate,
        imagePathList,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
