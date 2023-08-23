// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#pragma once

#include <tchar.h>
#include <list>
#include <xstring>

#define PRODUCT_EXE_X64
// 参数
#define PRODUCT_PUBLISHER _T("网易公司")                                             // 公司名称
#define PRODUCT_AUTORUN_KEY _T("Software\\Microsoft\\Windows\\CurrentVersion\\Run")  // 开机自启动相关
#define PRODUCT_UNINST_ROOT_KEY HKLM
#define UNINSTALL_NAME _T("uninstall.exe")  // 卸载文件
#define CLIENT_TYPE _T("pc")                // 系统类型
#define PRODUCT_NAME _T("网易会议")
#define PRODUCT_VERSION _T("1.0.0.0")
#define PRODUCT_DIR_REGKEY _T("Software\\Microsoft\\Windows\\CurrentVersion\\App Paths\\NetEaseMeeting.exe")
#define PRODUCT_UNINST_KEY _T("Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\网易会议")
#define PRODUCT_REGKEY _T("Software\\NetEase\\NIM_MEETING")
#define PRODUCT_DOC _T("NetEase\\NIM_MEETING\\")
#define PRODUCT_USER_DATA _T("NetEase\\Meeting\\")
#define RUN_NAME _T("NetEaseMeeting.exe")
#define PROCESS_NAME _T("NetEaseMeeting.exe")
#define OLD_SUB_PROCESS_NAME _T("NetEaseMeetingHost.exe")
#define SUB_PROCESS_NAME _T("NetEaseMeetingClient.exe")
#define START_CMD_KEY _T("NEMEETING")

std::list<std::wstring> GetDelFilesList() {
    std::list<std::wstring> ret_files;
    // ret_files.push_back(_T("*.*"));
    ret_files.push_back(_T("assets\\*.*"));
    ret_files.push_back(_T("assets\\"));
    ret_files.push_back(_T("audio\\*.*"));
    ret_files.push_back(_T("audio\\"));
    ret_files.push_back(_T("bearer\\*.*"));
    ret_files.push_back(_T("bearer\\"));
    ret_files.push_back(_T("config\\*.*"));
    ret_files.push_back(_T("config\\"));
    ret_files.push_back(_T("iconengines\\*.*"));
    ret_files.push_back(_T("iconengines\\"));
    ret_files.push_back(_T("image\\*.*"));
    ret_files.push_back(_T("image\\"));
    ret_files.push_back(_T("imageformats\\*.*"));
    ret_files.push_back(_T("imageformats\\"));
    ret_files.push_back(_T("multimedia\\*.*"));
    ret_files.push_back(_T("multimedia\\"));
    ret_files.push_back(_T("mediaservice\\*.*"));
    ret_files.push_back(_T("mediaservice\\"));
    ret_files.push_back(_T("networkinformation\\*.*"));
    ret_files.push_back(_T("networkinformation\\"));
    ret_files.push_back(_T("platforminputcontexts\\*.*"));
    ret_files.push_back(_T("platforminputcontexts\\"));
    ret_files.push_back(_T("platforms\\*.*"));
    ret_files.push_back(_T("platforms\\"));
    ret_files.push_back(_T("playlistformats\\*.*"));
    ret_files.push_back(_T("playlistformats\\"));
    ret_files.push_back(_T("position\\*.*"));
    ret_files.push_back(_T("position\\"));
    ret_files.push_back(_T("Qt5Compat\\*.*"));
    ret_files.push_back(_T("Qt5Compat\\"));
    ret_files.push_back(_T("qmltooling\\*.*"));
    ret_files.push_back(_T("qmltooling\\"));
    ret_files.push_back(_T("Qt\\*.*"));
    ret_files.push_back(_T("Qt\\"));
    ret_files.push_back(_T("QtCore\\*.*"));
    ret_files.push_back(_T("QtCore\\"));
    ret_files.push_back(_T("QtGraphicalEffects\\*.*"));
    ret_files.push_back(_T("QtGraphicalEffects\\"));
    ret_files.push_back(_T("QtMultimedia\\*.*"));
    ret_files.push_back(_T("QtMultimedia\\"));
    ret_files.push_back(_T("QtQml\\*.*"));
    ret_files.push_back(_T("QtQml\\"));
    ret_files.push_back(_T("QtQuick\\*.*"));
    ret_files.push_back(_T("QtQuick\\"));
    ret_files.push_back(_T("QtQuick.2\\*.*"));
    ret_files.push_back(_T("QtQuick.2\\"));
    ret_files.push_back(_T("QtWebChannel\\*.*"));
    ret_files.push_back(_T("QtWebChannel\\"));
    ret_files.push_back(_T("QtWebEngine\\*.*"));
    ret_files.push_back(_T("QtWebEngine\\"));
    ret_files.push_back(_T("QtTest\\*.*"));
    ret_files.push_back(_T("QtTest\\"));
    ret_files.push_back(_T("QtWinExtras\\*.*"));
    ret_files.push_back(_T("QtWinExtras\\"));
    ret_files.push_back(_T("resources\\*.*"));
    ret_files.push_back(_T("resources\\"));
    ret_files.push_back(_T("scenegraph\\*.*"));
    ret_files.push_back(_T("scenegraph\\"));
    ret_files.push_back(_T("sqldrivers\\*.*"));
    ret_files.push_back(_T("sqldrivers\\"));
    ret_files.push_back(_T("styles\\*.*"));
    ret_files.push_back(_T("styles\\"));
    ret_files.push_back(_T("translations\\*.*"));
    ret_files.push_back(_T("translations\\"));
    ret_files.push_back(_T("tls\\*.*"));
    ret_files.push_back(_T("tls\\"));
    ret_files.push_back(_T("virtualkeyboard\\*.*"));
    ret_files.push_back(_T("virtualkeyboard\\"));
    ret_files.push_back(_T("bugrpt.exe"));

    ret_files.push_back(_T("feedback_upload.png"));
    ret_files.push_back(_T("KernelDumpAnalyzer.exe"));
    ret_files.push_back(_T("THIRD_PARTY_COPYRIGHT.txt"));
    ret_files.push_back(_T("meeting-ui-sdk_en.qm"));
    ret_files.push_back(_T("meeting-ui-sdk_ja.qm"));
    ret_files.push_back(_T("meeting-app_en_CN.qm"));
    ret_files.push_back(_T("meeting-app_en_US.qm"));

    // NEP
    ret_files.push_back(_T("NEP2.dll"));
    ret_files.push_back(_T("NEPDaemon.exe"));

    // NERTC
    ret_files.push_back(_T("nertc_sdk.dll"));
    ret_files.push_back(_T("protoopp.dll"));
    ret_files.push_back(_T("NERtcAudio3D.dll"));
    ret_files.push_back(_T("NERtcAiDenoise.dll"));
    ret_files.push_back(_T("NERtcAiHowling.dll"));
    ret_files.push_back(_T("NERtcBeauty.dll"));
    ret_files.push_back(_T("NERtcFaceDetect.dll"));
    ret_files.push_back(_T("NERtcFaceEnhance.dll"));
    ret_files.push_back(_T("NERtcnn.dll"));
    ret_files.push_back(_T("NERtcPersonSegment.dll"));
    ret_files.push_back(_T("NERtcScreenShareEnhance.dll"));
    ret_files.push_back(_T("NERtcSuperResolution.dll"));
    ret_files.push_back(_T("NERtcVideoDenoise.dll"));
    ret_files.push_back(_T("necrashpad.dll"));
    ret_files.push_back(_T("necrashpad_handler.exe"));

    // NIM
    ret_files.push_back(_T("nim_qchat.dll"));
    ret_files.push_back(_T("nrtc.dll"));
    ret_files.push_back(_T("nim.dll"));
    ret_files.push_back(_T("nim_chatroom.dll"));
    ret_files.push_back(_T("nim_audio.dll"));
    ret_files.push_back(_T("nim_audio_hook.dll"));
    ret_files.push_back(_T("nim_chatroom_cpp_wrapper.dll"));
    ret_files.push_back(_T("nim_cpp_wrapper.dll"));
    ret_files.push_back(_T("nim_chatroom_sdk_cpp_wrapper_dll.dll"));
    ret_files.push_back(_T("nim_sdk_cpp_wrapper_dll.dll"));
    ret_files.push_back(_T("nim_tools_http.dll"));
    ret_files.push_back(_T("nrtc_audio_process.dll"));
    ret_files.push_back(_T("h_available.dll"));

    // Qt
    ret_files.push_back(_T("d3dcompiler_47.dll"));
    ret_files.push_back(_T("dbghelp.dll"));
    ret_files.push_back(_T("libcrypto-1_1.dll"));
    ret_files.push_back(_T("libcrypto-1_1-x64.dll"));
    ret_files.push_back(_T("libEGL.dll"));
    ret_files.push_back(_T("libGLESv2.dll"));
    ret_files.push_back(_T("libfreetype-6.dll"));
    ret_files.push_back(_T("libjpeg-9.dll"));
    ret_files.push_back(_T("libpng16-16.dll"));
    ret_files.push_back(_T("libtiff-5.dll"));
    ret_files.push_back(_T("libwebp-7.dll"));
    ret_files.push_back(_T("libssl-1_1.dll"));
    ret_files.push_back(_T("libssl-1_1-x64.dll"));
    ret_files.push_back(_T("meeting-app_zh_CN.qm"));
    ret_files.push_back(_T("meeting-native-sdk.dll"));
    ret_files.push_back(_T("meeting-ui-sdk_zh_CN.qm"));
    ret_files.push_back(_T("nem_hosting_module.dll"));
    ret_files.push_back(_T("nem_hosting_module_client.dll"));
    ret_files.push_back(_T("NetEaseMeeting.exe"));
    ret_files.push_back(_T("NetEaseMeetingHost.exe"));
    ret_files.push_back(_T("NetEaseMeetingClient.exe"));
    ret_files.push_back(_T("opengl32sw.dll"));
    ret_files.push_back(_T("Qt6Core.dll"));
    ret_files.push_back(_T("Qt6Gui.dll"));
    ret_files.push_back(_T("Qt6LabsSettings.dll"));
    ret_files.push_back(_T("Qt6Multimedia.dll"));
    ret_files.push_back(_T("Qt6MultimediaQuick.dll"));
    ret_files.push_back(_T("Qt6Network.dll"));
    ret_files.push_back(_T("Qt6OpenGL.dll"));
    ret_files.push_back(_T("Qt6Positioning.dll"));
    ret_files.push_back(_T("Qt6Qml.dll"));
    ret_files.push_back(_T("Qt6QmlLocalStorage.dll"));
    ret_files.push_back(_T("Qt6QmlModels.dll"));
    ret_files.push_back(_T("Qt6QmlWorkerScript.dll"));
    ret_files.push_back(_T("Qt6QmlXmlListModel.dll"));
    ret_files.push_back(_T("Qt6Quick.dll"));
    ret_files.push_back(_T("Qt6QuickControls2.dll"));
    ret_files.push_back(_T("Qt6QuickControls2Impl.dll"));
    ret_files.push_back(_T("Qt6QuickDialogs2.dll"));
    ret_files.push_back(_T("Qt6QuickDialogs2QuickImpl.dll"));
    ret_files.push_back(_T("Qt6QuickDialogs2Utils.dll"));
    ret_files.push_back(_T("Qt6QuickLayouts.dll"));
    ret_files.push_back(_T("Qt6QuickParticles.dll"));
    ret_files.push_back(_T("Qt6QuickShapes.dll"));
    ret_files.push_back(_T("Qt6QuickTemplates2.dll"));
    ret_files.push_back(_T("Qt6ShaderTools.dll"));
    ret_files.push_back(_T("Qt6Sql.dll"));
    ret_files.push_back(_T("Qt6Svg.dll"));
    ret_files.push_back(_T("Qt6WebChannel.dll"));
    ret_files.push_back(_T("Qt6WebEngineCore.dll"));
    ret_files.push_back(_T("Qt6WebEngineQuick.dll"));
    ret_files.push_back(_T("Qt6WebEngineQuickDelegatesQml.dll"));
    ret_files.push_back(_T("Qt6QmlCore.dll"));
    ret_files.push_back(_T("Qt6Widgets.dll"));
    ret_files.push_back(_T("video_render.fxo"));
    ret_files.push_back(_T("QtWebEngineProcess.exe"));

    // Resources
    ret_files.push_back(_T("rain.mp3"));
    ret_files.push_back(_T("feedback.png"));
    ret_files.push_back(_T("roomkit.dll"));
    ret_files.push_back(_T("SDL2.dll"));
    ret_files.push_back(_T("SDL2_image.dll"));
    ret_files.push_back(_T("SDL2_ttf.dll"));
    ret_files.push_back(_T("uninstall.exe"));
    ret_files.push_back(_T("zlib1.dll"));
    ret_files.push_back(_T("vc_redist.x86.exe"));
    ret_files.push_back(_T("vc_redist.x64.exe"));
    ret_files.push_back(_T("gl3w.dll"));
    ret_files.push_back(_T("glfw3.dll"));
    ret_files.push_back(_T("opengl32.dll"));
    ret_files.push_back(_T("CNamaSDK.dll"));
    ret_files.push_back(_T("fuai.dll"));
    ret_files.push_back(_T("msvcr120.dll"));
    ret_files.push_back(_T("msvcp120.dll"));
    ret_files.push_back(_T("assert\\*.bundle"));
    // Old version
    ret_files.push_back(_T("meeting_room.exe"));
    ret_files.push_back(_T("meeting_room_en_US.exe"));
    ret_files.push_back(_T("meeting_room_zh_CN.exe"));
    ret_files.push_back(_T("vld.dll"));
    return ret_files;
}
