QT += core quick quickcontrols2 svg
QTPLUGIN += qsvg

CONFIG += c++11 qtquickcompiler precompile_header

RESOURCES   += qml.qrc
DESTDIR     = $$PWD/../bin
TARGET      = NetEaseMeeting
#MOC_DIR     = $$PWD/../tmp/moc
#OBJECTS_DIR = $$PWD/../tmp/obj
#UI_DIR      = $$PWD/../tmp/ui
#RCC_DIR     = $$PWD/../tmp/rcc

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES +=  QT_DEPRECATED_WARNINGS \
            GLOG_NO_ABBREVIATED_SEVERITIES \
            GOOGLE_GLOG_DLL_DECL=

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

#INCLUDEPATH += $$PWD/third_party/meeting-sdk-desktop/meeting-ui-sdk \
#               $$PWD/third_party/meeting-sdk-desktop/meeting-ui-sdk/include

win32 {
    INCLUDEPATH += $$PWD/../ \
                   $$PWD/modules/ \
                   $$PWD/../third_party_libs/glog/include \
                   $$PWD/../third_party_libs/alog/include \
                   $$PWD/../meeting-ipc/ \
                   $$PWD/../meeting-ipc/nem_sdk_interface/
    CONFIG(debug, debug|release) {
        LIBS += -L$$PWD/../third_party_libs/glog/libs/win32/Debug -lglogd \
                -L$$PWD/../third_party_libs/alog/lib/x86/Debug -lyx_alog \
                -L$$PWD/../meeting-ipc/output/nem_hosting_module/Debug -lnem_hosting_moduled
        DEPENDPATH += $$PWD/../meeting-ipc/output/nem_hosting_module/Debug
    } else {
        LIBS += -L$$PWD/../third_party_libs/glog/libs/win32/Release -lglog \
                -L$$PWD/../third_party_libs/alog/lib/x86/Release -lyx_alog \
                -L$$PWD/../meeting-ipc/output/nem_hosting_module/Release -lnem_hosting_module
        DEPENDPATH += $$PWD/../meeting-ipc/output/nem_hosting_module/Release
    }
}

macx {
    INCLUDEPATH += $$PWD/../ \
                   $$PWD/modules/ \
                   $$PWD/../third_party_libs/glog/include/mac \
                   $$PWD/../third_party_libs/glog/src \
                   $$PWD/../third_party_libs/alog/yx_alog.framework/Headers \
                   $$PWD/../meeting-ipc/output_mac/nem_hosting_module/Release/nem_hosting_module.framework/Headers

    LIBS += -ObjC \
            -L$$PWD/../third_party_libs/glog/libs/mac -lglog \
            -F$$PWD/../third_party_libs/alog -framework yx_alog \
            -F$$PWD/../meeting-ipc/output_mac/nem_hosting_module/Release -framework nem_hosting_module

    CONFIG(debug, debug|release) {
        QMAKE_POST_LINK += rm -rf $$PWD/../bin/NetEaseMeeting.app/Contents/Frameworks &&
        QMAKE_POST_LINK += mkdir $$PWD/../bin/NetEaseMeeting.app/Contents/Frameworks &&
        QMAKE_POST_LINK += ln -s -f $$PWD/../bin/NetEaseMeetingClient.app $$PWD/../bin/NetEaseMeeting.app/Contents/Frameworks/NetEaseMeetingClient.app &&
        QMAKE_POST_LINK += ln -s -f $$PWD/../third_party_libs/FaceUnity-SDK/libs/mac/* $$PWD/../bin/NetEaseMeeting.app/Contents/Frameworks/ &&
        QMAKE_POST_LINK += ln -s -f $$PWD/../third_party_libs/alog/yx_alog.framework $$PWD/../bin/NetEaseMeeting.app/Contents/Frameworks/

        QMAKE_RPATHDIR += $$PWD/../meeting-ipc/output_mac/nem_hosting_module/Release
    } else {
        IPC_SERVER_SDK_FRAMEWORK.files = $$PWD/../meeting-ipc/output_mac/nem_hosting_module/Release/nem_hosting_module.framework
        IPC_SERVER_SDK_FRAMEWORK.path = /Contents/Frameworks

        NEM_UI_SDK_APP.files = $$PWD/../bin/NetEaseMeetingClient.app
        NEM_UI_SDK_APP.path = /Contents/Frameworks

        YXLOG_FRAMEWORK.files = $$PWD/../third_party_libs/alog/yx_alog.framework
        YXLOG_FRAMEWORK.path = /Contents/Frameworks

        QMAKE_BUNDLE_DATA += IPC_SERVER_SDK_FRAMEWORK \
                             YXLOG_FRAMEWORK \
                             NEM_UI_SDK_APP

        QMAKE_RPATHDIR += @executable_path/../Frameworks/NetEaseMeetingClient.app/Contents/Frameworks
    }
}

HEADERS += \
    app_dump.h \
    base/log_instance.h \
    meeting_app.h \
    modules/auth_manager.h \
    modules/base/http_manager.h \
    modules/base/http_request.h \
    modules/base/nem_auth_requests.h \
    modules/client_updator.h \
    modules/commandline_parser.h \
    modules/config_manager.h \
    modules/event_track/event_track_statistic.h \
    modules/event_track/nemeeting_event_track_static_strings.h \
    modules/event_track/nemetting_event_track_statistic.h \
    modules/event_track/string_converter.h \
    modules/feedback_manager.h \
    modules/local_socket.h \
    modules/nemeeting_sdk_manager.h \
    modules/statistics_manager.h \
    modules/sys_info.h \
    stable.h \
    utils/clipboard.h \
    utils/invoker.h \
    utils/miniz/miniz.h \
    utils/miniz/zip.h \
    utils/zipper.h \
    version.h

SOURCES += \
    base/log_instance.cpp \
    main.cpp \
    meeting_app.cpp \
    modules/auth_manager.cpp \
    modules/base/http_manager.cpp \
    modules/base/http_request.cpp \
    modules/base/nem_auth_requests.cpp \
    modules/client_updator.cpp \
    modules/commandline_parser.cpp \
    modules/config_manager.cpp \
    modules/event_track/nemetting_event_track_statistic.cpp \
    modules/event_track/string_converter.cpp \
    modules/feedback_manager.cpp \
    modules/local_socket.cpp \
    modules/nemeeting_sdk_manager.cpp \
    modules/statistics_manager.cpp \
    modules/sys_info.cpp \
    utils/clipboard.cpp \
    utils/miniz/zip.cpp \
    utils/zipper.cpp
macx {
    HEADERS += components/macxhelper.h
    SOURCES += components/macxhelper.mm
}

PRECOMPILED_HEADER = stable.h

TRANSLATIONS += meeting-app_zh_CN.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Version info
win32 {
    RC_ICONS                 = "meeting-app.ico"
    QMAKE_LFLAGS_RELEASE    += /MAP
    QMAKE_CFLAGS_RELEASE    += /Zi
    QMAKE_LFLAGS_RELEASE    += /debug /opt:ref
    QMAKE_CXXFLAGS_WARN_ON -= -w34100
    QMAKE_CXXFLAGS += -wd4100
    QMAKE_TARGET_COMPANY     = "NetEase"
    QMAKE_TARGET_DESCRIPTION = "NetEase Meeting"
    QMAKE_TARGET_COPYRIGHT   = "Copyright (C) 2015~2021 NetEase. All rights reserved."
    QMAKE_TARGET_PRODUCT     = "NetEase Meeting"
    VERSION = 1.0.0.0
}

macx {
    ICON = macx.icns
    QMAKE_CXXFLAGS_WARN_ON += -Wno-unused-parameter -Wno-unused-function
    QMAKE_TARGET_BUNDLE_PREFIX = com.netease.nmc
    QMAKE_BUNDLE = Meeting
    QMAKE_INFO_PLIST = $$PWD/Info.plist
    DISTFILES += $$PWD/Info.plist
    VERSION = 1.0.0
}
