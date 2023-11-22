import QtQuick
import QtQuick.Window 2.12
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia 5.12
import NetEase.Meeting.FrameProvider 1.0
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.VideoWindow 1.0
import QtMultimedia
import Qt5Compat.GraphicalEffects

import "../components"

Rectangle {
    anchors.fill: parent
    anchors.margins: 40
    property bool internalRender: (SettingsManager.enableInternalRender
                                   && !(MeetingStatus.MEETING_CONNECTED === meetingManager.getRoomStatus()
                                        || MeetingStatus.MEETING_RECONNECTED === meetingManager.getRoomStatus()))

    Component.onCompleted: {
        SettingsManager.setEnableInternalRender(SettingsManager.enableInternalRender)
        SettingsManager.initFaceBeautyLevel()
        beautyValue.value = SettingsManager.faceBeautyLevel
        const currentIndex = deviceManager.currentIndex(
                               DeviceSelector.DeviceType.CaptureType)
        deviceManager.selectDevice(DeviceSelector.DeviceType.CaptureType,
                                   currentIndex)
        videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
    }

    Component.onDestruction: {
        SettingsManager.saveFaceBeautyLevel()
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
                    SettingsManager.setFaceBeautyLevel(value)
                }
                Accessible.name: beautyLabel.text
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
                    mipmap: true
                    source: "qrc:/qml/images/settings/camera_empty.png"
                }

                FrameProvider {
                    id: frameProvider
                    videoSink: videoContainer.videoSink
                    accountId: authManager.authAccountId
                }

                VideoOutput {
                    id: videoContainer
                    anchors.fill: parent
                    transform: Rotation {
                        origin.x: videoContainer.width / 2
                        origin.y: videoContainer.height / 2
                        axis { x: 0; y: 1; z: 0 }
                        angle: SettingsManager.mirror ? 180 : 0
                    }
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
                SettingsManager.setFaceBeautyLevel(beautyValue.value)
                SettingsManager.saveFaceBeautyLevel()
                if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                    //videoManager.removeVideoCanvas(authManager.authAccountId, frameProvider)
                } else {
                    videoManager.stopLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
                }
            } else {
                if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                    videoManager.setupVideoCanvas(authManager.authAccountId, frameProvider, SettingsManager.remoteVideoResolution, frameProvider.uuid);
                }
            }
        }
    }
}
