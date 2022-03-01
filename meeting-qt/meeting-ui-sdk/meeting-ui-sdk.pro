QT += core quick quickcontrols2 multimedia svg webengine webchannel
QTPLUGIN += qsvg

CONFIG += c++14 qtquickcompiler precompile_header

RESOURCES   += qml.qrc
TARGET      = NetEaseMeetingClient
DESTDIR     = $$PWD/../bin
#MOC_DIR     = $$PWD/../tmp/moc
#OBJECTS_DIR = $$PWD/../tmp/obj
#UI_DIR      = $$PWD/../tmp/ui
#RCC_DIR     = $$PWD/../tmp/rcc

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES +=  QT_DEPRECATED_WARNINGS \
            NEM_SDK_INTERFACE_COMPONENT_BUILD \
            NEM_SDK_INTERFACE_IMPLEMENTATION \
            GLOG_NO_ABBREVIATED_SEVERITIES \
            GOOGLE_GLOG_DLL_DECL=

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

win32 {
    QT += winextras
    INCLUDEPATH += $$PWD/ \
               $$PWD/../ \
               $$PWD/../third_party_libs/roomkit/include \
               $$PWD/../third_party_libs/glog/include \
               $$PWD/../third_party_libs/alog/include \
               $$PWD/../third_party_libs/libyuv/include \
               $$PWD/../meeting-ipc/ \
               $$PWD/../meeting-ipc/nem_sdk_interface/ \
               $$PWD/../meeting-ipc/nem_sdk_interface_ipc_client/
    CONFIG(debug, debug|release) {
        LIBS += -L$$PWD/../third_party_libs/roomkit/libs/x86/Debug/lib -lroomkit_d \
                -L$$PWD/../third_party_libs/glog/libs/win32/Debug -lglogd \
                -L$$PWD/../third_party_libs/alog/lib/x86/Debug -lyx_alog \
                -L$$PWD/../third_party_libs/jsoncpp/libs/win32/Debug -ljsoncpp \
                -L$$PWD/../third_party_libs/libyuv/libs/win32/Debug -lyuv \
                -L$$PWD/../meeting-ipc/output/nem_hosting_module_client/Debug -lnem_hosting_module_clientd
        DEPENDPATH += $$PWD/../meeting-ipc/output/nem_hosting_module_client/Debug
    } else {
        LIBS += -L$$PWD/../third_party_libs/roomkit/libs/x86/Release/lib -lroomkit \
                -L$$PWD/../third_party_libs/glog/libs/win32/Release -lglog \
                -L$$PWD/../third_party_libs/alog/lib/x86/Release -lyx_alog \
                -L$$PWD/../third_party_libs/jsoncpp/libs/win32/Release -ljsoncpp \
                -L$$PWD/../third_party_libs/libyuv/libs/win32/Release -lyuv \
                -L$$PWD/../meeting-ipc/output/nem_hosting_module_client/Release -lnem_hosting_module_client
        DEPENDPATH += $$PWD/../meeting-ipc/output/nem_hosting_module_client/Release
    }
}

macx {
    QT += macextras
    INCLUDEPATH += \
            $$PWD/../ \
            $$PWD/../third_party_libs/alog/yx_alog.framework/Headers \
            $$PWD/../third_party_libs/glog/include/mac \
            $$PWD/../third_party_libs/glog/src \
            $$PWD/../third_party_libs/libyuv/include \
            $$PWD/../meeting-ipc/output_mac/nem_hosting_module_client/Release/nem_hosting_module_client.framework/Headers

    LIBS += -ObjC \
            -L$$PWD/../third_party_libs/glog/libs/mac -lglog \
            -L$$PWD/../third_party_libs/libyuv/libs/mac -lyuv \
            -F$$PWD/../third_party_libs/alog -framework yx_alog \
            -F$$PWD/../meeting-ipc/output_mac/nem_hosting_module_client/Release -framework nem_hosting_module_client

    CONFIG(debug, debug|release) {
        INCLUDEPATH += $$PWD/../third_party_libs/roomkit/Debug/framework/roomkit.framework/Headers
        LIBS += -F$$PWD/../third_party_libs/roomkit/Debug/framework -framework roomkit -framework NEFundation_Mac -framework nertc_sdk_Mac -framework nim_chatroom -framework nim \
                -L$$PWD/../third_party_libs/roomkit/Debug/lib -lCNamaSDK -lfuai -lh_available

        QMAKE_POST_LINK += rm -rf $$PWD/../bin/NetEaseMeetingClient.app/Contents/Frameworks &&
        QMAKE_POST_LINK += mkdir $$PWD/../bin/NetEaseMeetingClient.app/Contents/Frameworks &&
        QMAKE_POST_LINK += ln -s -f $$PWD/../third_party_libs/roomkit/Debug/lib/*  $$PWD/../bin/NetEaseMeetingClient.app/Contents/Frameworks/ &&

        QMAKE_POST_LINK += rm -rf $$PWD/../bin/NetEaseMeetingClient.app/Contents/Resources/assert &&
        QMAKE_POST_LINK += mkdir $$PWD/../bin/NetEaseMeetingClient.app/Contents/Resources/assert &&
        QMAKE_POST_LINK += ln -s -f $$PWD/../third_party_libs/roomkit/Debug/assert/* $$PWD/../bin/NetEaseMeetingClient.app/Contents/Resources/assert/


        QMAKE_RPATHDIR += $$PWD/../bin \
                          $$PWD/../meeting-ipc/output_mac/nem_hosting_module_client/Release \
                          $$PWD/../third_party_libs/roomkit/Debug/framework \
                          $$PWD/../third_party_libs/roomkit/Debug/lib \
                          $$PWD/../third_party_libs/alog \
    } else {
        INCLUDEPATH += $$PWD/../third_party_libs/roomkit/Release/framework/roomkit.framework/Headers
        LIBS += -F$$PWD/../third_party_libs/roomkit/Release/framework -framework roomkit -framework NEFundation_Mac -framework nertc_sdk_Mac -framework nim_chatroom -framework nim \
                -L$$PWD/../third_party_libs/roomkit/Release/lib -lCNamaSDK -lfuai -lh_available

        ROOM_KIT_FRAMEWORK.files = $$PWD/../third_party_libs/roomkit/Release/framework/roomkit.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NEFundation_Mac.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/nertc_sdk_Mac.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/nim_chatroom.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/nim.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/lib/libfuai.dylib \
                                   $$PWD/../third_party_libs/roomkit/Release/lib/libCNamaSDK.dylib \
                                   $$PWD/../third_party_libs/roomkit/Release/lib/libh_available.dylib
        ROOM_KIT_FRAMEWORK.path = /Contents/Frameworks

        FU_BUNDLE.files = $$PWD/../third_party_libs/roomkit/Release/assert/face_beautification.bundle
        FU_BUNDLE.path = /Contents/Resources/assert

        IPC_CLIENT_SDK_FRAMEWORK.files = $$PWD/../meeting-ipc/output_mac/nem_hosting_module_client/Release/nem_hosting_module_client.framework
        IPC_CLIENT_SDK_FRAMEWORK.path = /Contents/Frameworks

        YXLOG_FRAMEWORK.files = $$PWD/../third_party_libs/alog/yx_alog.framework
        YXLOG_FRAMEWORK.path = /Contents/Frameworks

        MEDIA_PLAYER.files = $$PWD/../bin/rain.mp3
        MEDIA_PLAYER.path = /Contents/Resources

        QMAKE_BUNDLE_DATA += ROOM_KIT_FRAMEWORK \
                             IPC_CLIENT_SDK_FRAMEWORK \
                             YXLOG_FRAMEWORK \
                             MEDIA_PLAYER \
                             FU_BUNDLE
    }
}

PRECOMPILED_HEADER = stable.h

HEADERS += \
    app_dump.h \
    base/log_instance.h \
    components/clipboard.h \
    components/mouse_event_spy.h \
    components/screensaver.h \
    components/whiteboard_jsBridge.h \
    ipc_handlers/account_prochandler.h \
    ipc_handlers/auth_prochandler.h \
    ipc_handlers/feedback_prochandler.h \
    ipc_handlers/hosting_module_client.h \
    ipc_handlers/meeting_prochandler.h \
    ipc_handlers/meeting_sdk_prochandler.h \
    ipc_handlers/premeeting_prochandler.h \
    ipc_handlers/setting_prochandler.h \
    listeners/meeting_service_listener.h \
    listeners/meeting_stats_listener.h \
    manager/auth_manager.h \
    manager/chat_manager.h \
    manager/config_manager.h \
    manager/device_manager.h \
    manager/feedback_manager.h \
    manager/global_manager.h \
    manager/live_manager.h \
    manager/meeting/whiteboard_manager.h \
    manager/more_item_manager.h \
    manager/meeting/audio_manager.h \
    manager/meeting/members_manager.h \
    manager/meeting/share_manager.h \
    manager/meeting/video_manager.h \
    manager/meeting_manager.h \
    manager/pre_meeting_manager.h \
    manager/settings_manager.h \
    models/device_model.h \
    models/live_members_model.h \
    models/members_model.h \
    models/more_item_model.h \
    models/screen_model.h \
    modules/command_parser.h \
    providers/frame_provider.h \
    providers/frame_rate.h \
    providers/screen_provider.h \
    providers/video_window.h \
    utils/invoker.h \
    utils/singleton.h \
    windows/windows_manager.h

SOURCES += \
    base/log_instance.cpp \
    components/clipboard.cpp \
    components/mouse_event_spy.cpp \
    components/whiteboard_jsBridge.cpp \
    ipc_handlers/account_prochandler.cpp \
    ipc_handlers/auth_prochandler.cpp \
    ipc_handlers/feedback_prochandler.cpp \
    ipc_handlers/hosting_module_client.cpp \
    ipc_handlers/meeting_prochandler.cpp \
    ipc_handlers/meeting_sdk_prochandler.cpp \
    ipc_handlers/premeeting_prochandler.cpp \
    ipc_handlers/setting_prochandler.cpp \
    listeners/meeting_service_listener.cpp \
    listeners/meeting_stats_listener.cpp \
    main.cpp \
    manager/auth_manager.cpp \
    manager/chat_manager.cpp \
    manager/config_manager.cpp \
    manager/device_manager.cpp \
    manager/feedback_manager.cpp \
    manager/global_manager.cpp \
    manager/live_manager.cpp \
    manager/meeting/whiteboard_manager.cpp \
    manager/more_item_manager.cpp \
    manager/meeting/audio_manager.cpp \
    manager/meeting/members_manager.cpp \
    manager/meeting/share_manager.cpp \
    manager/meeting/video_manager.cpp \
    manager/meeting_manager.cpp \
    manager/pre_meeting_manager.cpp \
    manager/settings_manager.cpp \
    models/device_model.cpp \
    models/live_members_model.cpp \
    models/members_model.cpp \
    models/more_item_model.cpp \
    models/screen_model.cpp \
    modules/command_parser.cpp \
    providers/frame_provider.cpp \
    providers/frame_rate.cpp \
    providers/screen_provider.cpp \
    providers/video_window.cpp \
    windows/windows_manager.cpp

win32 {
    HEADERS += components/windows_helpers.h

    SOURCES += components/windows_helpers.cpp \
               components/screensaver.cpp
}
macx {
    HEADERS += components/macx_helpers.h \
               components/auth_checker.h

    SOURCES += components/macx_helpers.mm \
               components/auth_checker.mm \
               components/screensaver.mm
}

TRANSLATIONS += meeting-ui-sdk_zh_CN.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
# qnx: target.path = /tmp/$${TARGET}/bin
# else: unix:!android: target.path = /opt/$${TARGET}/bin
# !isEmpty(target.path): INSTALLS += target

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Version info
win32 {
    RC_ICONS                 = "meeting-ui-sdk.ico"
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
    QMAKE_BUNDLE = MeetingClient
    QMAKE_INFO_PLIST = $$PWD/Info.plist
    DISTFILES += $$PWD/Info.plist
    VERSION = 1.0.0
}

# ALL_PWD_QML_FILES = $$files($${_PRO_FILE_PWD_}/*.qml , true)
# a command that creates an empty file with a given name.
# win32 {
#     MY_TOUCH_CMD = copy NUL
# } else {
#     MY_TOUCH_CMD = touch
# }
# qmllint.output = .qmllint/${QMAKE_FILE_BASE}.qmllint
# qmllint.input = ALL_PWD_QML_FILES
# qmllint.commands = qmllint ${QMAKE_FILE_NAME} && $${MY_TOUCH_CMD} ${QMAKE_FILE_OUT}
# qmllint.CONFIG += no_link recursive target_predeps
# QMAKE_EXTRA_COMPILERS += qmllint
