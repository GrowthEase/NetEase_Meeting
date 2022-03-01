// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeState extends BaseState{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'uikit/assets/images/icon_yunxin.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            Text(
              '网易云信视频会议',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w700),
            ),
            Container(
              margin: EdgeInsets.only(left: 0, top: 40),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: 50,
              width: 300,
              //边框设置
              decoration: BoxDecoration(
                //背景
                color: Colors.blue,
                //设置四周圆角 角度 这里的角度应该为 父Container height 的一半
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //设置四周边框
//                  border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text(
                '加入会议',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 0, top: 20),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: 50,
              width: 300,
              //边框设置
              decoration: BoxDecoration(
                //背景
                color: Colors.white,
                //设置四周圆角 角度 这里的角度应该为 父Container height 的一半
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //设置四周边框
                border: Border.all(width: 1, color: Colors.red),
              ),
              child: TextButton(
                child: Text(
                  '登录',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
                onPressed: () => Navigator.of(context).pushNamed('login'),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 0, top: 20),
              child: Text(
                '立即注册',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}