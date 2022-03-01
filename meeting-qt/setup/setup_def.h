/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#pragma once

#include <list>
#include <tchar.h>
#include <xstring>

//参数
#define PRODUCT_PUBLISHER					_T("网易公司")	//公司名称
#define PRODUCT_AUTORUN_KEY					_T("Software\\Microsoft\\Windows\\CurrentVersion\\Run")		//开机自启动相关
#define PRODUCT_UNINST_ROOT_KEY				HKLM
#define UNINSTALL_NAME						_T("uninstall.exe")				//卸载文件
#define CLIENT_TYPE							_T("pc")						//系统类型
#define PRODUCT_NAME						_T("网易会议")
#define PRODUCT_VERSION						_T("1.0.0.0")
#define PRODUCT_DIR_REGKEY					_T("Software\\Microsoft\\Windows\\CurrentVersion\\App Paths\\NetEaseMeeting.exe")
#define PRODUCT_UNINST_KEY					_T("Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\网易会议")
#define PRODUCT_REGKEY						_T("Software\\NetEase\\NIM_MEETING")
#define PRODUCT_DOC							_T("NetEase\\NIM_MEETING\\")
#define PRODUCT_USER_DATA					_T("NetEase\\Meeting\\")
#define RUN_NAME							_T("NetEaseMeeting.exe")
#define PROCESS_NAME						_T("NetEaseMeeting.exe")
#define OLD_SUB_PROCESS_NAME				_T("NetEaseMeetingHost.exe")
#define SUB_PROCESS_NAME					_T("NetEaseMeetingClient.exe")
#define START_CMD_KEY						_T("NEMEETING")

std::list<std::wstring> GetDelFilesList()
{
	std::list<std::wstring> ret_files;
	//ret_files.push_back(_T("*.*"));
	ret_files.push_back(_T("audio\\*.*"));
	ret_files.push_back(_T("audio\\"));
	ret_files.push_back(_T("bearer\\*.*"));
	ret_files.push_back(_T("bearer\\"));
	ret_files.push_back(_T("iconengines\\*.*"));
	ret_files.push_back(_T("iconengines\\"));
	ret_files.push_back(_T("imageformats\\*.*"));
	ret_files.push_back(_T("imageformats\\"));
	ret_files.push_back(_T("mediaservice\\*.*"));
	ret_files.push_back(_T("mediaservice\\"));
	ret_files.push_back(_T("platforms\\*.*"));
	ret_files.push_back(_T("platforms\\"));
	ret_files.push_back(_T("playlistformats\\*.*"));
	ret_files.push_back(_T("playlistformats\\"));
	ret_files.push_back(_T("qmltooling\\*.*"));
	ret_files.push_back(_T("qmltooling\\"));
	ret_files.push_back(_T("Qt\\*.*"));
	ret_files.push_back(_T("Qt\\"));
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
	ret_files.push_back(_T("QtTest\\*.*"));
	ret_files.push_back(_T("QtTest\\"));
	ret_files.push_back(_T("QtWinExtras\\*.*"));
	ret_files.push_back(_T("QtWinExtras\\"));
	ret_files.push_back(_T("scenegraph\\*.*"));
	ret_files.push_back(_T("scenegraph\\"));
	ret_files.push_back(_T("styles\\*.*"));
	ret_files.push_back(_T("styles\\"));
	ret_files.push_back(_T("translations\\*.*"));
	ret_files.push_back(_T("translations\\"));
	ret_files.push_back(_T("d3dcompiler_47.dll"));
	ret_files.push_back(_T("dbghelp.dll"));
	ret_files.push_back(_T("libcrypto-1_1.dll"));
	ret_files.push_back(_T("libEGL.dll"));
	ret_files.push_back(_T("libGLESv2.dll"));
	ret_files.push_back(_T("libssl-1_1.dll"));
	ret_files.push_back(_T("meeting-app_zh_CN.qm"));
	ret_files.push_back(_T("meeting-native-sdk.dll"));
	ret_files.push_back(_T("meeting-ui-sdk_zh_CN.qm"));
	ret_files.push_back(_T("nem_hosting_module.dll"));
	ret_files.push_back(_T("nem_hosting_module_client.dll"));
	ret_files.push_back(_T("nertc_sdk.dll"));
	ret_files.push_back(_T("NetEaseMeeting.exe"));
	ret_files.push_back(_T("NetEaseMeetingHost.exe"));
	ret_files.push_back(_T("NetEaseMeetingClient.exe"));
	ret_files.push_back(_T("nim.dll"));
	ret_files.push_back(_T("nim_chatroom.dll"));
	ret_files.push_back(_T("nim_chatroom_sdk_cpp_wrapper_dll.dll"));
	ret_files.push_back(_T("nim_sdk_cpp_wrapper_dll.dll"));
	ret_files.push_back(_T("nim_tools_http.dll"));
	ret_files.push_back(_T("opengl32sw.dll"));
	ret_files.push_back(_T("Qt5Core.dll"));
	ret_files.push_back(_T("Qt5Gui.dll"));
	ret_files.push_back(_T("Qt5Multimedia.dll"));
	ret_files.push_back(_T("Qt5MultimediaQuick.dll"));
	ret_files.push_back(_T("Qt5Network.dll"));
	ret_files.push_back(_T("Qt5Qml.dll"));
	ret_files.push_back(_T("Qt5QmlModels.dll"));
	ret_files.push_back(_T("Qt5QmlWorkerScript.dll"));
	ret_files.push_back(_T("Qt5Quick.dll"));
	ret_files.push_back(_T("Qt5QuickControls2.dll"));
	ret_files.push_back(_T("Qt5QuickTemplates2.dll"));
	ret_files.push_back(_T("Qt5QuickTest.dll"));
	ret_files.push_back(_T("Qt5RemoteObjects.dll"));
	ret_files.push_back(_T("Qt5Svg.dll"));
	ret_files.push_back(_T("Qt5Test.dll"));
	ret_files.push_back(_T("Qt5Widgets.dll"));
	ret_files.push_back(_T("Qt5WinExtras.dll"));
	ret_files.push_back(_T("rain.mp3"));
	ret_files.push_back(_T("SDL2.dll"));
	ret_files.push_back(_T("uninstall.exe"));
	ret_files.push_back(_T("vc_redist.x86.exe"));
	ret_files.push_back(_T("gl3w.dll"));
	ret_files.push_back(_T("glfw3.dll"));
	ret_files.push_back(_T("opengl32.dll"));
	ret_files.push_back(_T("CNamaSDK.dll"));
	ret_files.push_back(_T("fuai.dll"));
	ret_files.push_back(_T("assert\\*.bundle"));
	// Old version
	ret_files.push_back(_T("meeting_room.exe"));
	ret_files.push_back(_T("meeting_room_en_US.exe"));
	ret_files.push_back(_T("meeting_room_zh_CN.exe"));
	ret_files.push_back(_T("vld.dll"));
	return ret_files;
}