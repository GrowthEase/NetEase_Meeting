TEMPLATE = lib
TARGET = meeting-plugins
QT += qml quick multimedia
CONFIG += plugin c++11 qmltypes
TARGET = $$qtLibraryTarget($$TARGET)
uri = NEMeeting

QML_IMPORT_NAME = NEMeeting
QML_IMPORT_MAJOR_VERSION = 1

INCLUDEPATH += $$PWD/../meeting-native-sdk/include \
            += $$PWD/../meeting-native-sdk/include/meeting
DESTDIR = $$PWD/../bin/$$QML_IMPORT_NAME

win32 {
    INCLUDEPATH += $$PWD/../third_party/libyuv/include

    CONFIG(debug, debug|release) {
        LIBS += -L$$PWD/../bin -lmeeting-native-sdk \
                -L$$PWD/../third_party/libyuv/output/Debug -lyuv
    } else {
        LIBS += -L$$PWD/../bin -lmeeting-native-sdk \
                -L$$PWD/../third_party/libyuv/output/Release -lyuv
    }
}

# Input
SOURCES += \
        components/auth/nem_account.cpp \
        components/auth/nem_authenticate.cpp \
        components/devices/nem_devices.cpp \
        components/meeting/nem_audio_controller.cpp \
        components/meeting/nem_members_controller.cpp \
        components/meeting/nem_mine.cpp \
        components/meeting/nem_session.cpp \
        components/meeting/nem_share_controller.cpp \
        components/meeting/nem_video_controller.cpp \
        models/nem_devices_model.cpp \
        models/nem_members_model.cpp \
        models/nem_schedule_model.cpp \
        nem_engine.cpp \
        nemeeting_plugin.cpp \
        providers/nem_frame_provider.cpp \
        components/schedules/nem_schedules.cpp

HEADERS += \
        components/auth/nem_account.h \
        components/auth/nem_authenticate.h \
        components/devices/nem_devices.h \
        components/meeting/nem_audio_controller.h \
        components/meeting/nem_members_controller.h \
        components/meeting/nem_mine.h \
        components/meeting/nem_session.h \
        components/meeting/nem_share_controller.h \
        components/meeting/nem_video_controller.h \
        models/nem_devices_model.h \
        models/nem_members_model.h \
        models/nem_schedule_model.h \
        nem_engine.h \
        nemeeting_plugin.h \
        providers/nem_frame_provider.h \
        components/schedules/nem_schedules.h \
        utils/invoker.h

pluginfiles.target += $$PWD/../bin/$$QML_IMPORT_NAME
pluginfiles.path = $$PWD/../bin/$$QML_IMPORT_NAME
pluginfiles.files += \
    imports/$$QML_IMPORT_NAME/qmldir \
    imports/$$QML_IMPORT_NAME/components/NEMVideoOutput.qml

INSTALLS += pluginfiles

# Cpplint
QMAKE_PRE_LINK += cpplint --exclude=$$PWD/include --exclude=$$PWD/release --exclude=$$PWD/debug --recursive $$PWD
