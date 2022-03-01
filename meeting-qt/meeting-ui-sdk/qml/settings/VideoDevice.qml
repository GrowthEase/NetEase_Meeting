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
    id: root
    anchors.fill: parent
    anchors.margins: 40
    property bool internalRender: (SettingsManager.enableInternalRender && !(MeetingStatus.MEETING_CONNECTED === meetingManager.getRoomStatus() || MeetingStatus.MEETING_RECONNECTED === meetingManager.getRoomStatus()))
    property bool completed: false
    Component.onCompleted: {
        SettingsManager.setEnableInternalRender(SettingsManager.enableInternalRender)
//        if (internalRender) {
//            var point = Window.contentItem.mapFromItem(idVideoRect, 0, 0)
//            idVideoWindow.setVideoGeometry(point.x, point.y, idVideoRect.width, idVideoRect.height)
//            idVideoWindow.frontItem = idRowLayout
//        }

        const currentIndex = deviceManager.currentIndex(DeviceSelector.DeviceType.CaptureType)
        deviceCombobox.currentIndex = currentIndex
        deviceManager.selectDevice(DeviceSelector.DeviceType.CaptureType, currentIndex)
        videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
        videoManager.stopLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
        videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
        completed = true;
    }

    RowLayout {
        id: idRowLayout
        spacing: 40

        Label {
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 12
            font.pixelSize: 16
            font.weight: Font.Medium
            text: qsTr("Cameras")
        }

        ColumnLayout {
            spacing: 20

            ComboBox {
                id: deviceCombobox
                textRole: "deviceName"
                // flat: true
                Layout.preferredWidth: 320
                Layout.preferredHeight: 45
                model: DeviceModel {
                    deviceType: DeviceSelector.DeviceType.CaptureType
                    manager: deviceManager
                }
                background: Rectangle {
                    implicitWidth: 320
                    implicitHeight: 45
                    border.color: "#CCCCCC"
                    border.width: 1
                    radius: 2
                }
                onActivated: {
                    videoManager.stopLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider);
                    deviceManager.selectDevice(model.deviceType, index)
                    videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
                }
                onCountChanged: {
                    if (completed) {
                        const currentIndex = deviceManager.currentIndex(model.deviceType)
                        deviceCombobox.currentIndex = currentIndex
                        videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
                    }
                }
                Component.onCompleted: {
                    //                    const currentIndex = deviceManager.currentIndex(model.deviceType)
                    //                    deviceCombobox.currentIndex = currentIndex
                    //                    videoManager.startLocalVideoPreview(internalRender ? idVideoWindow : frameProvider)
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
                color: !internalRender ? "#1f1f1f" : "transparent" // "#1f1f1f" "transparent"

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
                videoManager.stopLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
            }
        }
    }
}
