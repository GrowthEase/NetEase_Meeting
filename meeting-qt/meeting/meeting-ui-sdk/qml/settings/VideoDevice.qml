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
            }
        }
        RowLayout {
            Layout.topMargin: 15
            spacing: 5

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 12
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr("Remote resolution")
            }
            ColumnLayout {
                spacing: 0

                RadioButton {
                    id: autoMode
                    checked: !SettingsManager.remoteVideoResolution
                    enabled: selectEnable
                    font.weight: Font.Light
                    text: qsTr("Auto Mode")

                    onClicked: {
                        selectEnable = false;
                        hdMode.checked = false;
                        SettingsManager.setRemoteVideoResolution(false);
                        clickTimer.restart();
                    }
                }
                ColumnLayout {
                    spacing: 0

                    RadioButton {
                        id: hdMode
                        checked: SettingsManager.remoteVideoResolution
                        enabled: selectEnable
                        font.weight: Font.Light
                        text: qsTr("HD Mode")

                        onClicked: {
                            selectEnable = false;
                            autoMode.checked = false;
                            SettingsManager.setRemoteVideoResolution(true);
                            clickTimer.restart();
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: 35
                        Layout.topMargin: -10
                        font.pixelSize: 12
                        text: qsTr("You can enable this option in professional scenarios that have high requirements on picture quality")
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
        RowLayout {
            Layout.topMargin: 15
            spacing: 5

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 12
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr("Local resolution")
            }
            ColumnLayout {
                spacing: 0
                RadioButton {
                    id: idDefault
                    checked: SettingsStatus.VR_DEFAULT === SettingsManager.localVideoResolution
                    enabled: selectEnable
                    font.weight: Font.Light
                    text: qsTr("Auto Mode")

                    onClicked: {
                        selectEnable = false;
                        SettingsManager.setLocalVideoResolution(SettingsStatus.VR_DEFAULT);
                        clickTimer.restart();
                    }
                }
                RadioButton {
                    id: id480P
                    checked: SettingsStatus.VR_480P === SettingsManager.localVideoResolution
                    enabled: selectEnable
                    font.weight: Font.Light
                    text: qsTr("480P")

                    onClicked: {
                        selectEnable = false;
                        SettingsManager.setLocalVideoResolution(SettingsStatus.VR_480P);
                        clickTimer.restart();
                    }
                }
                RadioButton {
                    id: id720P
                    checked: SettingsStatus.VR_720P === SettingsManager.localVideoResolution
                    enabled: selectEnable
                    font.weight: Font.Light
                    text: qsTr("720P")

                    onClicked: {
                        selectEnable = false;
                        SettingsManager.setLocalVideoResolution(SettingsStatus.VR_720P);
                        clickTimer.restart();
                    }
                }
                RadioButton {
                    id: id1080P
                    checked: SettingsStatus.VR_1080P === SettingsManager.localVideoResolution
                    enabled: selectEnable
                    font.weight: Font.Light
                    text: qsTr("1080P")

                    onClicked: {
                        selectEnable = false;
                        SettingsManager.setLocalVideoResolution(SettingsStatus.VR_1080P);
                        clickTimer.restart();
                    }
                }
                RadioButton {
                    id: id4K
                    checked: SettingsStatus.VR_4K === SettingsManager.localVideoResolution
                    enabled: selectEnable
                    font.weight: Font.Light
                    text: qsTr("4K")
                    visible: false

                    onClicked: {
                        selectEnable = false;
                        SettingsManager.setLocalVideoResolution(SettingsStatus.VR_4K);
                        clickTimer.restart();
                    }
                }
                RadioButton {
                    id: id8K
                    checked: SettingsStatus.VR_8K === SettingsManager.localVideoResolution
                    enabled: selectEnable
                    font.weight: Font.Light
                    text: qsTr("8K")
                    visible: false

                    onClicked: {
                        selectEnable = false;
                        SettingsManager.setLocalVideoResolution(SettingsStatus.VR_8K);
                        clickTimer.restart();
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
