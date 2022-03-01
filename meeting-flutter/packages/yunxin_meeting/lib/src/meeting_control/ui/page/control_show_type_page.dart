// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

///更改展示模式：1、演讲者模式 2、画廊模式

class ControlShowTypePage extends StatefulWidget {
  final ControlMeetingArguments arguments;

  ControlShowTypePage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    return _ControlShowTypePageState(arguments);
  }
}

class _ControlShowTypePageState extends BaseState<ControlShowTypePage> {
  static const _tag = 'ControlShowTypePage';
  _ControlShowTypePageState(this.arguments);

  final ControlMeetingArguments arguments;
  late Radius _radius;

  @override
  void initState() {
    super.initState();
    _radius = Radius.circular(8);
    arguments.showTypeListenable!.addListener(() {
      setState(() {});
    });
    Alog.d(tag: _tag, moduleName: _moduleName, content: 'showType = $arguments');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Container(
            height: 404,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.only(topLeft: _radius, topRight: _radius)),
            child: SafeArea(
              top: false,
              child: Column(
                children: <Widget>[
                  _title(),
                  Expanded(
                    child: buildControlArea(),
                  ),
                ],
              ),
            ),
          ),
        ]);
  }

  Widget _title() {
    return Container(
      height: 48,
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: UIColors.globalBg,
              ),
              borderRadius:
                  BorderRadius.only(topLeft: _radius, topRight: _radius))),
      child: Stack(
        children: <Widget>[
          Center(
            child: Text(
              _Strings.showType,
              style: TextStyle(
                  color: UIColors.black_333333,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  decoration: TextDecoration.none),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RawMaterialButton(
              constraints:
                  const BoxConstraints(minWidth: 40.0, minHeight: 48.0),
              child: Icon(
                NEMeetingIconFont.icon_yx_tv_duankaix,
                color: UIColors.color_666666,
                size: 15,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildControlArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        controlBtn(
            NEMeetingIconFont.icon_yx_tv_layout_ax, _Strings.showTypePresenter,
            () {
          changeShowType(showTypePresenter);
        }, isSelected: arguments.showType == showTypePresenter),
        Container(
          margin: EdgeInsets.only(top: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Offstage(
                offstage: arguments.showType != showTypeGallery,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  child:
                      turnPageControlBtn(NEMeetingIconFont.icon_yx_returnx, () {
                    turnPage(false);
                  }),
                ),
              ),
              controlBtn(NEMeetingIconFont.icon_yx_tv_layout_bx,
                  _Strings.showTypeGallery, () {
                changeShowType(showTypeGallery);
              }, isSelected: arguments.showType == showTypeGallery),
              Offstage(
                offstage: arguments.showType != showTypeGallery,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  child:
                      turnPageControlBtn(NEMeetingIconFont.icon_yx_allowx, () {
                    turnPage(true);
                  }),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget controlBtn(IconData iconData, String name, VoidCallback callback,
      {bool isSelected = false}) {
    return Column(children: [
      RawMaterialButton(
        elevation: 0,
        fillColor: isSelected ? UIColors.color_337eff : UIColors.white,
        constraints: BoxConstraints(minWidth: 72.0, minHeight: 72.0),
        child: Icon(
          iconData,
          size: 30,
          color: isSelected ? UIColors.white : UIColors.color_49494D,
        ),
        shape: CircleBorder(
            side: BorderSide(
                color:
                    isSelected ? UIColors.color_337eff : UIColors.colorDCDCE0,
                width: 1)),
        onPressed: callback,
      ),
      Container(
        margin: EdgeInsets.only(top: 4),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: UIColors.primaryText,
              fontWeight: FontWeight.w400,
              fontSize: 13,
              decoration: TextDecoration.none),
        ),
      ),
    ]);
  }

  Widget turnPageControlBtn(IconData iconData, VoidCallback callback,
      {bool isSelected = false}) {
    return Column(children: [
      RawMaterialButton(
        elevation: 0,
        fillColor: isSelected ? UIColors.blue_5996FF : UIColors.blue_5996FF,
        constraints: BoxConstraints(minWidth: 40.0, minHeight: 40.0),
        child: Icon(
          iconData,
          size: 20,
          color: isSelected ? UIColors.white : UIColors.white,
        ),
        shape: CircleBorder(
            side: BorderSide(
                color: isSelected ? UIColors.blue_5996FF : UIColors.blue_5996FF,
                width: 1)),
        onPressed: callback,
      ),
    ]);
  }

  void changeShowType(int showType) {
    ControlInMeetingRepository
        .changeShowType(showType)
        .then((result) {
      if (result.code == ControlCode.success) {
        arguments.showType = showType;
      } else if (result.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      }
    });
  }

  void turnPage(bool isDown) {
    ControlInMeetingRepository.turnPage(isDown).then((result) {
      if (result.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      }
    });
  }
}
