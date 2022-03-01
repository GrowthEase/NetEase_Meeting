// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.foregroundservice;

import android.text.TextUtils;

import java.util.Map;

import androidx.annotation.DrawableRes;

/**
 * 视频会议在会议过程中，如果退到后台，会被系统杀死，因此需要开启前台服务
 * 当前在会议开始之前开启前台，在回去结束后关闭前台服务
 * <p>
 * Created by hzsunyj on 2020/9/25.
 */
class ForegroundServiceConfig {

    public static final String DEFAULT_CONTENT_TITLE = "视频会议";

    public static final String DEFAULT_CONTENT_TEXT = "视频会议正在进行中";

    public static final String DEFAULT_CONTENT_TICKER = "视频会议";

    public static final String DEFAULT_CHANNEL_ID = "ne_meeting_channel";

    public static final String DEFAULT_CHANNEL_NAME = "视频会议通知";

    public static final String DEFAULT_CHANNEL_DESC = "视频会议通知";

    /**
     * 前台服务通知标题
     */
    public String contentTitle = DEFAULT_CONTENT_TITLE;

    /**
     * 前台服务通知內容
     */
    public String contentText = DEFAULT_CONTENT_TEXT;

    /**
     * 前台服务通知图标，如果不设置默认显示应用图标
     */
    @DrawableRes public int smallIcon;


    /**
     * 入口页面
     */
    public String launchActivityName;

    /**
     * 前台服务通知提示
     */
    public String ticker = DEFAULT_CONTENT_TICKER;

    /**
     * 前台服务通知通道id
     */
    public String channelId = DEFAULT_CHANNEL_ID;

    /**
     * 前台服务通知通道名称
     */
    public String channelName = DEFAULT_CHANNEL_NAME;

    /**
     * 前台服务通知通道描述
     */
    public String channelDesc = DEFAULT_CHANNEL_DESC;


    public static ForegroundServiceConfig fromMap(Map config) {
        if (config == null) {
            return null;
        }
        ForegroundServiceConfig fsc = new ForegroundServiceConfig();
        String contentTitle = (String) config.get("contentTitle");
        String contentText = (String) config.get("contentText");
        Integer smallIcon = (Integer) config.get("smallIcon");
        String launchClassName = (String) config.get("launchClassName");
        String ticker = (String) config.get("ticker");
        String channelId = (String) config.get("channelId");
        String channelName = (String) config.get("channelName");
        String channelDesc = (String) config.get("channelDesc");
        fsc.contentTitle = TextUtils.isEmpty(
                contentTitle) ? ForegroundServiceConfig.DEFAULT_CONTENT_TITLE : contentTitle;
        fsc.contentText = TextUtils.isEmpty(contentText) ? ForegroundServiceConfig.DEFAULT_CONTENT_TEXT : contentText;
        fsc.smallIcon = smallIcon==null? 0 : smallIcon;
        fsc.launchActivityName = launchClassName;
        fsc.ticker = TextUtils.isEmpty(ticker) ? ForegroundServiceConfig.DEFAULT_CONTENT_TICKER : ticker;
        fsc.channelId = TextUtils.isEmpty(channelId) ? ForegroundServiceConfig.DEFAULT_CHANNEL_ID : channelId;
        fsc.channelName = TextUtils.isEmpty(channelName) ? ForegroundServiceConfig.DEFAULT_CHANNEL_NAME : channelName;
        fsc.channelDesc = TextUtils.isEmpty(channelDesc) ? ForegroundServiceConfig.DEFAULT_CHANNEL_DESC : channelDesc;
        return fsc;
    }
    ;

}
