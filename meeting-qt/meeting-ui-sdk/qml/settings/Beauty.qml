import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import NetEase.Meeting.FrameProvider 1.0
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.VideoWindow 1.0

import "../components"

Rectangle {
    anchors.fill: parent
    anchors.margins: 40
    property bool internalRender: (SettingsManager.enableInternalRender
                                   && !(MeetingStatus.MEETING_CONNECTED
                                        === meetingManager.getRoomStatus()
                                        || MeetingStatus.MEETING_RECONNECTED
                                        === meetingManager.getRoomStatus()))

    Component.onCompleted: {
        SettingsManager.setEnableInternalRender(
                    SettingsManager.enableInternalRender)
        SettingsManager.initFaceBeautyLevel()
        beautyValue.value = SettingsManager.faceBeautyLevel

        //        if (internalRender) {
        //            var point = Window.contentItem.mapFromItem(idVideoRect, 0, 0)
        //            idVideoWindow.setVideoGeometry(point.x, point.y, idVideoRect.width, idVideoRect.height)
        //        }
        const currentIndex = deviceManager.currentIndex(
                               DeviceSelector.DeviceType.CaptureType)
        deviceManager.selectDevice(DeviceSelector.DeviceType.CaptureType,
                                   currentIndex)
        //videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
        //videoManager.stopLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
        videoManager.startLocalVideoPreview(
                    /*internalRender ? idVideoWindow : */ frameProvider)
    }

    RowLayout {
        id: idRowLayout
        spacing: 40
        Label {
            id: beautyLabel
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 12
            font.pixelSize: 16
            font.weight: Font.Medium
            text: qsTr("Beauty level")
        }

        ColumnLayout {
            spacing: 20
            CustomSlider {
                id: beautyValue
                showValue: true
                Layout.preferredWidth: 320
                Layout.topMargin: beautyLabel.height / 2
                from: 0
                to: 10
                stepSize: 1
                onValueChanged: {
                    SettingsManager.setEnableFaceBeauty(true)
                    SettingsManager.setFaceBeautyLevel(value)
                }
            }

            FrameProvider {
                id: frameProvider
                accountId: authManager.authAccountId
            }

            Rectangle {
                id: idVideoRect
                Layout.preferredWidth: 320
                Layout.preferredHeight: 180
                color: !internalRender ? "#1f1f1f" : "transparent"

                Image {
                    //visible: MeetingStatus.DEVICE_ENABLED !== videoManager.localVideoStatus
                    visible: !internalRender
                    anchors.centerIn: parent
                    source: "qrc:/qml/images/settings/camera_empty.png"
                }

                VideoOutput {
                    anchors.fill: parent
                    visible: !internalRender
                    //visible: MeetingStatus.DEVICE_ENABLED === videoManager.localVideoStatus
                    source: frameProvider
                }
            }
        }
    }

    //    VideoWindow{
    //        id: idVideoWindow
    //        anchors.fill: parent
    //        visible: internalRender && parent.visible
    //        //fillColor: "#1f1f1f"
    //    }
    Connections {
        target: rootWindow
        onVisibilityChanged: {
            if (rootWindow.visibility === Window.Hidden) {
                videoManager.stopLocalVideoPreview(
                            /*internalRender ? idVideoWindow : */ frameProvider)
                SettingsManager.setEnableFaceBeauty(false)
                SettingsManager.setFaceBeautyLevel(beautyValue.value)
                SettingsManager.saveFaceBeautyLevel()
            }
        }
    }
}
