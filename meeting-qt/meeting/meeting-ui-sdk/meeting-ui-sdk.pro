QT += core quick quickcontrols2 multimedia svg webengine webchannel sql
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
            NEM_SDK_INTERFACE_IMPLEMENTATION

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

win32 {
    QT += winextras
    INCLUDEPATH += $$PWD/ \
               $$PWD/../ \
               $$PWD/../third_party_libs/roomkit/include \
               $$PWD/../third_party_libs/alog/include \
               $$PWD/../third_party_libs/libyuv/include \
               $$PWD/../meeting-ipc/ \
               $$PWD/../meeting-ipc/nem_sdk_interface/ \
               $$PWD/../meeting-ipc/nem_sdk_interface_ipc_client/
    CONFIG(debug, debug|release) {
        !contains(QMAKE_TARGET.arch, x86_64) {
            LIBS += -L$$PWD/../third_party_libs/roomkit/libs/x86/Debug/lib -lroomkit_d \
                    -L$$PWD/../third_party_libs/alog/lib/x86/Debug -lyx_alog \
                    -L$$PWD/../third_party_libs/jsoncpp/libs/x86/Debug -ljsoncpp \
                    -L$$PWD/../third_party_libs/libyuv/libs/x86/Debug -lyuv
        } else {
            LIBS += -L$$PWD/../third_party_libs/roomkit/libs/x64/Debug/lib -lroomkit_d \
                    -L$$PWD/../third_party_libs/alog/lib/x64/Debug -lyx_alog \
                    -L$$PWD/../third_party_libs/jsoncpp/libs/x64/Debug -ljsoncpp \
                    -L$$PWD/../third_party_libs/libyuv/libs/x64/Debug -lyuv
        }

        LIBS += -L$$PWD/../meeting-ipc/output/nem_hosting_module_client/Debug -lnem_hosting_module_clientd
        DEPENDPATH += $$PWD/../meeting-ipc/output/nem_hosting_module_client/Debug
    } else {
        !contains(QMAKE_TARGET.arch, x86_64) {
            LIBS += -L$$PWD/../third_party_libs/roomkit/libs/x86/Release/lib -lroomkit \
                    -L$$PWD/../third_party_libs/alog/lib/x86/Release -lyx_alog \
                    -L$$PWD/../third_party_libs/jsoncpp/libs/x86/Release -ljsoncpp \
                    -L$$PWD/../third_party_libs/libyuv/libs/x86/Release -lyuv
        } else {
        LIBS += -L$$PWD/../third_party_libs/roomkit/libs/x64/Release/lib -lroomkit \
                -L$$PWD/../third_party_libs/alog/lib/x64/Release -lyx_alog \
                -L$$PWD/../third_party_libs/jsoncpp/libs/x64/Release -ljsoncpp \
                -L$$PWD/../third_party_libs/libyuv/libs/x64/Release -lyuv
        }

        LIBS += -L$$PWD/../meeting-ipc/output/nem_hosting_module_client/Release -lnem_hosting_module_client
        DEPENDPATH += $$PWD/../meeting-ipc/output/nem_hosting_module_client/Release
    }
}

macx {
    QT += macextras
    INCLUDEPATH += \
            $$PWD/../ \
            $$PWD/../third_party_libs/alog/yx_alog.framework/Headers \
            $$PWD/../third_party_libs/libyuv/include \
            $$PWD/../meeting-ipc/output_mac/nem_hosting_module_client/Release/nem_hosting_module_client.framework/Headers

    LIBS += -ObjC \
            -L$$PWD/../third_party_libs/libyuv/libs/mac -lyuv \
            -F$$PWD/../third_party_libs/alog -framework yx_alog \
            -F$$PWD/../meeting-ipc/output_mac/nem_hosting_module_client/Release -framework nem_hosting_module_client

    CONFIG(debug, debug|release) {
        INCLUDEPATH += $$PWD/../third_party_libs/roomkit/Debug/framework/roomkit.framework/Headers
        LIBS += -F$$PWD/../third_party_libs/roomkit/Debug/framework -framework roomkit -framework nertc_sdk_Mac -framework AVFoundation\
                -L$$PWD/../third_party_libs/roomkit/Debug/lib -lh_available -lnim_chatroom -lnim -lnim_qchat -lnim_tools_http

        QMAKE_POST_LINK += rm -rf $$PWD/../bin/NetEaseMeetingClient.app/Contents/Frameworks &&
        QMAKE_POST_LINK += mkdir $$PWD/../bin/NetEaseMeetingClient.app/Contents/Frameworks &&
        QMAKE_POST_LINK += ln -s -f $$PWD/../third_party_libs/roomkit/Debug/lib/*  $$PWD/../bin/NetEaseMeetingClient.app/Contents/Frameworks/ &&
        QMAKE_POST_LINK += rm -rf $$PWD/../bin/NetEaseMeetingClient.app/Contents/Resources/assets &&
        QMAKE_POST_LINK += mkdir $$PWD/../bin/NetEaseMeetingClient.app/Contents/Resources/assets &&
        QMAKE_POST_LINK += ln -s -f $$PWD/../third_party_libs/roomkit/Debug/assets/* $$PWD/../bin/NetEaseMeetingClient.app/Contents/Resources/assets/
        
        exists($$PWD/../third_party_libs/roomkit/Debug/framework/NEFundation_Mac.framework) {
            LIBS += -F$$PWD/../third_party_libs/roomkit/Debug/framework -framework NEFundation_Mac
        }

        QMAKE_RPATHDIR += $$PWD/../bin \
                          $$PWD/../meeting-ipc/output_mac/nem_hosting_module_client/Release \
                          $$PWD/../third_party_libs/roomkit/Debug/framework \
                          $$PWD/../third_party_libs/roomkit/Debug/lib \
                          $$PWD/../third_party_libs/alog

        exists($PWD/../meeting-ui-sdk/meeting-ui-sdk_zh_CN.qm) {
            QMS.files = $$PWD/../meeting-ui-sdk/meeting-ui-sdk_zh_CN.qm \
                        $$PWD/../meeting-ui-sdk/meeting-ui-sdk_en.qm \
                        $$PWD/../meeting-ui-sdk/meeting-ui-sdk_ja.qm
            QMS.path = /Contents/Resources
            QMAKE_BUNDLE_DATA += QMS
        }
    } else {
        INCLUDEPATH += $$PWD/../third_party_libs/roomkit/Release/framework/roomkit.framework/Headers
        LIBS += -F$$PWD/../third_party_libs/roomkit/Release/framework -framework roomkit -framework nertc_sdk_Mac -framework AVFoundation\
                -L$$PWD/../third_party_libs/roomkit/Release/lib -lh_available -lnim_chatroom -lnim -lnim_qchat -lnim_tools_http

        ROOM_KIT_FRAMEWORK.files = $$PWD/../third_party_libs/roomkit/Release/framework/roomkit.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/nertc_sdk_Mac.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcAiDenoise.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcAiHowling.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcFaceDetect.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcBeauty.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcFaceEnhance.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcnn.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcPersonSegment.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcScreenShareEnhance.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcSuperResolution.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/framework/NERtcVideoDenoise.framework \
                                   $$PWD/../third_party_libs/roomkit/Release/lib/libh_available.dylib \
                                   $$PWD/../third_party_libs/roomkit/Release/lib/libnim_chatroom.dylib \
                                   $$PWD/../third_party_libs/roomkit/Release/lib/libnim_qchat.dylib \
                                   $$PWD/../third_party_libs/roomkit/Release/lib/libnim_tools_http.dylib \
                                   $$PWD/../third_party_libs/roomkit/Release/lib/libnim.dylib
                                   
        exists($$PWD/../third_party_libs/roomkit/Release/framework/NEFundation_Mac.framework) {
            LIBS += -F$$PWD/../third_party_libs/roomkit/Release/framework -framework NEFundation_Mac
            ROOM_KIT_FRAMEWORK.files += $$PWD/../third_party_libs/roomkit/Release/framework/NEFundation_Mac.framework
        }

        ROOM_KIT_FRAMEWORK.path = /Contents/Frameworks

        IPC_CLIENT_SDK_FRAMEWORK.files = $$PWD/../meeting-ipc/output_mac/nem_hosting_module_client/Release/nem_hosting_module_client.framework
        IPC_CLIENT_SDK_FRAMEWORK.path = /Contents/Frameworks

        YXLOG_FRAMEWORK.files = $$PWD/../third_party_libs/alog/yx_alog.framework
        YXLOG_FRAMEWORK.path = /Contents/Frameworks

        MEDIA_PLAYER.files = $$PWD/../bin/rain.mp3
        MEDIA_PLAYER.path = /Contents/Resources

        BEAUTY_BUNDLE.files = $$PWD/../third_party_libs/roomkit/Release/assets
        BEAUTY_BUNDLE.path = /Contents/Resources

        QMAKE_BUNDLE_DATA += ROOM_KIT_FRAMEWORK \
                             IPC_CLIENT_SDK_FRAMEWORK \
                             YXLOG_FRAMEWORK \
                             MEDIA_PLAYER \
                             BEAUTY_BUNDLE
    }

    VIRTUAL_BACKGROUND.files = $$PWD/../bin/image
    VIRTUAL_BACKGROUND.path = /Contents/Resources
    
    CONFIGS.files = $$PWD/../bin/config
    CONFIGS.path = /Contents/Resources

    QMAKE_BUNDLE_DATA += VIRTUAL_BACKGROUND \
                         CONFIGS

    exists($$PWD/../bin/xkit_server.config) {
        XKIT_SERVER.files = $$PWD/../bin/xkit_server.config
        XKIT_SERVER.path = /Contents/MacOS

        QMAKE_BUNDLE_DATA += XKIT_SERVER
    }
}

PRECOMPILED_HEADER = stable.h

HEADERS += \
    app_dump.h \
    models/message_model.h \
    version.h \
    base/log_instance.h \
    components/clipboard.h \
    components/mouse_event_spy.h \
    components/screensaver.h \
    components/whiteboard_jsBridge.h \
    controller/audio_controller.h \
    controller/audio_controller.h \
    controller/auth_controller.h \
    controller/config_controller.h \
    controller/meeting_controller.h \
    controller/premeeting_controller.h \
    controller/screenshare_controller.h \
    controller/sip_controller.h \
    controller/subscribe_helper.h \
    controller/user_controller.h \
    controller/user_controller.h \
    controller/video_controller.h \
    controller/video_controller.h \
    ipc_handlers/account_prochandler.h \
    ipc_handlers/auth_prochandler.h \
    ipc_handlers/feedback_prochandler.h \
    ipc_handlers/hosting_module_client.h \
    ipc_handlers/meeting_prochandler.h \
    ipc_handlers/meeting_sdk_prochandler.h \
    ipc_handlers/premeeting_prochandler.h \
    ipc_handlers/setting_prochandler.h \
    listeners/meeting_service_listener.h \
    manager/auth_manager.h \
    manager/chat_manager.h \
    manager/config_manager.h \
    manager/device_manager.h \
    manager/feedback_manager.h \
    manager/global_manager.h \
    manager/live_manager.h \
    manager/meeting/invite_manager.h \
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
    models/invite_model.h \
    models/live_members_model.h \
    models/members_model.h \
    models/more_item_model.h \
    models/screen_model.h \
    models/virtualbackground_model.h \
    modules/command_parser.h \
    modules/http/http_manager.h \
    modules/http/http_request.h \
    providers/frame_provider.h \
    providers/frame_rate.h \
    providers/screen_provider.h \
    providers/video_window.h \
    providers/video_render.h \
    utils/invoker.h \
    utils/singleton.h \
    utils/miniz/miniz.h \
    utils/miniz/zip.h \
    utils/zipper.h \
    windows/windows_manager.h

SOURCES += \
    base/log_instance.cpp \
    components/clipboard.cpp \
    components/mouse_event_spy.cpp \
    components/whiteboard_jsBridge.cpp \
    controller/audio_controller.cpp \
    controller/auth_controller.cpp \
    controller/config_controller.cpp \
    controller/meeting_controller.cpp \
    controller/premeeting_controller.cpp \
    controller/screenshare_controller.cpp \
    controller/sip_controller.cpp \
    controller/subscribe_helper.cpp \
    controller/user_controller.cpp \
    controller/video_controller.cpp \
    ipc_handlers/account_prochandler.cpp \
    ipc_handlers/auth_prochandler.cpp \
    ipc_handlers/feedback_prochandler.cpp \
    ipc_handlers/hosting_module_client.cpp \
    ipc_handlers/meeting_prochandler.cpp \
    ipc_handlers/meeting_sdk_prochandler.cpp \
    ipc_handlers/premeeting_prochandler.cpp \
    ipc_handlers/setting_prochandler.cpp \
    listeners/meeting_service_listener.cpp \
    main.cpp \
    manager/auth_manager.cpp \
    manager/chat_manager.cpp \
    manager/config_manager.cpp \
    manager/device_manager.cpp \
    manager/feedback_manager.cpp \
    manager/global_manager.cpp \
    manager/live_manager.cpp \
    manager/meeting/invite_manager.cpp \
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
    models/invite_model.cpp \
    models/live_members_model.cpp \
    models/members_model.cpp \
    models/message_model.cpp \
    models/more_item_model.cpp \
    models/screen_model.cpp \
    models/virtualbackground_model.cpp \
    modules/command_parser.cpp \
    modules/http/http_manager.cpp \
    modules/http/http_request.cpp \
    providers/frame_provider.cpp \
    providers/frame_rate.cpp \
    providers/screen_provider.cpp \
    providers/video_window.cpp \
    providers/video_render.cpp \
    windows/windows_manager.cpp \
    utils/miniz/zip.cpp \
    utils/zipper.cpp

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
TRANSLATIONS += meeting-ui-sdk_en.ts
TRANSLATIONS += meeting-ui-sdk_ja.ts

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
    QMAKE_CXXFLAGS += /MP
    QMAKE_LFLAGS += /LARGEADDRESSAWARE
    QMAKE_TARGET_COMPANY     = "NetEase"
    QMAKE_TARGET_DESCRIPTION = "NetEase Meeting"
    QMAKE_TARGET_COPYRIGHT   = "Copyright (C) 2015~2022 NetEase. All rights reserved."
    QMAKE_TARGET_PRODUCT     = "NetEase Meeting"
    VERSION = 1.0.0.0
}

macx {
    ICON = macx.icns
    QMAKE_CXXFLAGS_WARN_ON += -Wno-unused-parameter -Wno-unused-function
    QMAKE_TARGET_BUNDLE_PREFIX = com.netease.nmc
    QMAKE_BUNDLE = MeetingClient
    QMAKE_DEVELOPMENT_TEAM = 569GNZ5392
    QMAKE_PROVISIONING_PROFILE = afe9bf95-033c-4592-abac-e0aab5328ce0
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

