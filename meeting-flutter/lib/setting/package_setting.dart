// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service/model/account_app_info.dart';
import 'package:uikit/state/meeting_base_state.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';

class PackageVersionSetting extends StatefulWidget {
  final Edition edition;

  PackageVersionSetting(this.edition);

  @override
  State<StatefulWidget> createState() {
    return _PackageVersionSettingState();
  }
}

class _PackageVersionSettingState extends MeetingBaseState<PackageVersionSetting> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget buildBody() {
    return buildContent();
  }

  @override
  String getTitle() {
    return Strings.packageVersion;
  }

  Widget buildContent() {
    return widget.edition.featureList.isEmpty ? Container() : buildList(widget.edition.featureList);
  }

  Widget buildList(List<Feature> items) {
    return Container(
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return buildItem(item: items[index], index: index, isLast: items.length ==index + 1);
            }));
  }

  Widget buildItem({required Feature item, required int index, bool isLast = false}) {
    return Container(
        color: AppColors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Visibility(visible: index == 0, child: line()),
          Visibility(
              visible: index == 0,
              child: Container(
                  padding: EdgeInsets.only(left: 20, top: 24, bottom: 10),
                  child: Text(
                    widget.edition.name,
                    style: TextStyle(fontSize: 16, color: AppColors.color_222222, fontWeight: FontWeight.bold),
                  ))),
          Container(
            color: AppColors.white,
            padding: EdgeInsets.only(left: 20, top: 6, ),
            child: Text(item.description, style: TextStyle(fontSize: 12, color: AppColors.black_333333)),
          ),
          Visibility(
              visible: isLast,
              child: Container(
                color: AppColors.white,
                padding: EdgeInsets.only(left: 20, top: 10, bottom: isLast ? 24 : 0),
                child: Text(widget.edition.extra ?? '', style: TextStyle(fontSize: 12, color: AppColors.black_333333)),
              )),
        ]));
  }

  Widget line() {
    return Container(
        color: AppColors.colorE8E9EB,
        height: 0.5,
      );
  }
}
