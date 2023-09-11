import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.VideoWindow 1.0
import NetEase.Settings.SettingsStatus 1.0
import NetEase.Meeting.FrameProvider 1.0
import QtMultimedia
import Qt5Compat.GraphicalEffects
import "../components"
import "../utils/dialogManager.js" as DialogManager

Rectangle {
    id: root

    property bool completed: false
    property bool internalRender: (SettingsManager.enableInternalRender && !(MeetingStatus.MEETING_CONNECTED === meetingManager.getRoomStatus() || MeetingStatus.MEETING_RECONNECTED === meetingManager.getRoomStatus()))
    property bool selectEnable: true

    anchors.fill: parent
    anchors.margins: 40

    Component.onCompleted: {
        SettingsManager.setEnableInternalRender(SettingsManager.enableInternalRender);
        const currentIndex = deviceManager.currentIndex(DeviceSelector.DeviceType.CaptureType);
        deviceCombobox.currentIndex = currentIndex;
        deviceManager.selectDevice(DeviceSelector.DeviceType.CaptureType, currentIndex);
        videoManager.startLocalVideoPreview/*internalRender ? idVideoWindow : */(frameProvider);
        completed = true;
        selectEnable = true;
    }

    Timer {
        id: clickTimer
        interval: 500
        repeat: false

        onTriggered: {
            selectEnable = true;
        }
    }
    ToastManager {
        id: toast
    }
    ColumnLayout {
        width: root.width

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

                Rectangle {
                    id: idVideoRect
                    Layout.preferredHeight: 180
                    Layout.preferredWidth: 320
                    color: !internalRender ? "#1f1f1f" : "transparent" // "#1f1f1f" "transparent"

                    Image {
                        anchors.centerIn: parent
                        mipmap: true
                        source: "qrc:/qml/images/settings/camera_empty.png"
                        //visible: MeetingStatus.DEVICE_ENABLED !== videoManager.localVideoStatus
                        visible: !internalRender
                    }
                    FrameProvider {
                        id: frameProvider
                        accountId: authManager.authAccountId
                        videoSink: videoContainer.videoSink
                    }
                    VideoOutput {
                        id: videoContainer
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectFit

                        transform: Rotation {
                            angle: SettingsManager.mirror ? 180 : 0
                            origin.x: videoContainer.width / 2
                            origin.y: videoContainer.height / 2

                            axis {
                                x: 0
                                y: 1
                                z: 0
                            }
                        }
                    }
                }
                ComboBox {
                    id: deviceCombobox
                    Layout.preferredHeight: 45
                    // flat: true
                    Layout.preferredWidth: 320
                    textRole: "deviceName"

                    background: Rectangle {
                        border.color: "#CCCCCC"
                        border.width: 1
                        implicitHeight: 45
                        implicitWidth: 320
                        radius: 2
                    }
                    model: DeviceModel {
                        deviceType: DeviceSelector.DeviceType.CaptureType
                        manager: deviceManager
                    }

                    Component.onCompleted: {
                    }
                    onActivated: {
                        videoManager.stopLocalVideoPreview/*internalRender ? idVideoWindow : */(frameProvider);
                        deviceManager.selectDevice(model.deviceType, index);
                        videoManager.startLocalVideoPreview/*internalRender ? idVideoWindow : */(frameProvider);
                    }
                    onCountChanged: {
                        if (completed) {
                            const currentIndex = deviceManager.currentIndex(model.deviceType);
                            deviceCombobox.currentIndex = currentIndex;
                            videoManager.startLocalVideoPreview/*internalRender ? idVideoWindow : */(frameProvider);
                        }
                    }
                }
                CustomCheckBox {
                    id: checkEnableMirror
                    checked: SettingsManager.mirror
                    font.weight: Font.Light
                    text: qsTr("Video Mirror")

                    onClicked: {
                        SettingsManager.mirror = checkEnableMirror.checked;
                    }
                }
                CustomCheckBox {
                    checked: SettingsStatus.VR_MAX === SettingsManager.localVideoResolution
                    enabled: selectEnable
                    font.weight: Font.Light
                    text: qsTr("HD mode")

                    onClicked: {
                        if (checked)
                            SettingsManager.setLocalVideoResolution(SettingsStatus.VR_MAX);
                        else
                            SettingsManager.setLocalVideoResolution(SettingsStatus.VR_DEFAULT);
                    }
                }
            }
        }
    }
    Connections {
        target: rootWindow

        onVisibilityChanged: {
            if (rootWindow.visibility === Window.Hidden) {
                if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus)
                //videoManager.removeVideoCanvas(authManager.authAccountId, frameProvider)
                {
                } else {
                    videoManager.stopLocalVideoPreview/*internalRender ? idVideoWindow : */(frameProvider);
                }
            } else {
                if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                    videoManager.setupVideoCanvas(authManager.authAccountId, frameProvider, SettingsManager.remoteVideoResolution, frameProvider.uuid);
                }
            }
            selectEnable = true;
        }
    }
}
