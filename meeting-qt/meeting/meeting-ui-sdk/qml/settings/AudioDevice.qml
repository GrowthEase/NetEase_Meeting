import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.Settings 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Settings.SettingsStatus 1.0
import "../components"

Item {
    id: root
    enum TestMode {
        UnknownMode,
        SpeakerTestMode,
        MicrophoneTestMode
    }

    property int deviceTestMode: AudioDevice.TestMode.UnknownMode
    property bool musicModeSelectEnable: true

    function stopTest() {
        if (deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
            deviceManager.startSpeakerTest(false);
        } else if (deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode) {
            deviceManager.startMicrophoneTest(false);
        }
    }

    anchors.fill: parent
    anchors.margins: 35

    Component.onCompleted: {
        videoManager.stopLocalVideoPreview();
        root.musicModeSelectEnable = true;
    }
    Component.onDestruction: {
        stopTest();
        root.musicModeSelectEnable = true;
    }

    Connections {
        target: deviceManager

        onLocalAudioVolumeIndication: {
            if (deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
                speakerProgress.value = volume;
                microphoneProgress.value = 0;
            } else if (deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode) {
                microphoneProgress.value = volume;
                speakerProgress.value = 0;
            }
        }
    }
    Connections {
        function onVisibleStatus() {
            if (!SettingsWnd.visible) {
                stopTest();
                root.musicModeSelectEnable = true;
            }
        }

        target: SettingsWnd
    }
    Timer {
        id: speakerTestTimer
        interval: 9000

        onTriggered: {
            if (deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
                //btnMicrophoneTest.enabled = true
                //comboSpeakers.enabled = true
                //comboMicrophones.enabled = true
                deviceManager.startSpeakerTest(false);
                deviceTestMode = AudioDevice.TestMode.UnknownMode;
                speakerProgress.value = 0;
            }
        }
    }
    Timer {
        id: clickTimer
        interval: 500
        repeat: false

        onTriggered: {
            musicModeSelectEnable = true;
        }
    }
    ColumnLayout {
        width: root.width

        RowLayout {
            spacing: 35

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage ? 80 : 70
                Layout.topMargin: 12
                color: "#333333"
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr("Speakers")
            }
            ColumnLayout {
                spacing: 22

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    ComboBox {
                        id: comboSpeakers
                        Layout.preferredHeight: 45
                        Layout.preferredWidth: 320
                        enabled: deviceTestMode === AudioDevice.TestMode.UnknownMode
                        textRole: "deviceName"

                        background: Rectangle {
                            border.color: "#CCCCCC"
                            border.width: 1
                            implicitHeight: 45
                            implicitWidth: 320
                            radius: 2
                        }
                        model: DeviceModel {
                            deviceType: DeviceSelector.DeviceType.PlayoutType
                            manager: deviceManager
                        }

                        Component.onCompleted: {
                            if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                                comboSpeakers.currentIndex = deviceManager.currentIndex(model.deviceType);
                            } else {
                                comboSpeakers.currentIndex = 0;
                            }
                        }
                        onActivated: {
                            deviceManager.selectDevice(model.deviceType, index);
                            const volume = deviceManager.getPlayoutDeviceVolume();
                            speakerSlider.value = volume;
                        }
                        onCountChanged: {
                            speakerProgress.value = 0;
                            deviceManager.startSpeakerTest(false);
                            deviceTestMode = AudioDevice.TestMode.UnknownMode;
                            speakerTestTimer.stop();
                            const currentIndex = deviceManager.currentIndex(model.deviceType);
                            comboSpeakers.currentIndex = currentIndex;
                        }
                    }
                    CustomButton {
                        id: btnSpeakerTest
                        Layout.preferredHeight: 35
                        Layout.preferredWidth: 110
                        buttonRadius: 18
                        enabled: comboSpeakers.count > 0 && meetingManager.meetingId.length === 0 && (deviceTestMode === AudioDevice.TestMode.UnknownMode || deviceTestMode === AudioDevice.TestMode.SpeakerTestMode)
                        font.pixelSize: 14
                        highlighted: true
                        text: {
                            if (deviceTestMode === AudioDevice.TestMode.UnknownMode) {
                                return qsTr("Speaker Test");
                            } else if (deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
                                return qsTr("Stop");
                            }
                            return qsTr("Speaker Test");
                        }

                        onClicked: {
                            if (deviceTestMode === AudioDevice.TestMode.UnknownMode) {
                                deviceTestMode = AudioDevice.TestMode.SpeakerTestMode;
                                deviceManager.startSpeakerTest(true);
                                speakerTestTimer.start();
                            } else if (deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
                                speakerProgress.value = 0;
                                deviceManager.startSpeakerTest(false);
                                deviceTestMode = AudioDevice.TestMode.UnknownMode;
                                speakerTestTimer.stop();
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.preferredWidth: 75
                        color: "#333333"
                        text: qsTr("Level")
                    }
                    CustomProgressBar {
                        id: speakerProgress
                        Layout.fillWidth: true
                    }
                }
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.preferredWidth: SettingsStatus.UILanguage_zh !== SettingsManager.uiLanguage ? 100 : 75
                        color: "#333333"
                        text: qsTr("Volume")
                    }
                    Image {
                        Layout.preferredHeight: 16
                        Layout.preferredWidth: 16
                        mipmap: true
                        source: "qrc:/qml/images/settings/speaker_mute.png"
                    }
                    CustomSlider {
                        id: speakerSlider
                        Layout.fillWidth: true
                        to: 255
                        value: 1

                        Component.onCompleted: {
                            const volume = deviceManager.getPlayoutDeviceVolume();
                            value = volume;
                        }
                        onValueChanged: {
                            deviceManager.setPlayoutDeviceVolume(value);
                        }
                    }
                    Image {
                        Layout.preferredHeight: 16
                        Layout.preferredWidth: 16
                        mipmap: true
                        source: "qrc:/qml/images/settings/speaker_unmute.png"
                    }
                }
            }
        }
        RowLayout {
            Layout.topMargin: 30
            spacing: 35

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage ? 80 : 70
                Layout.topMargin: 12
                color: "#333333"
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr("Micros")
            }
            ColumnLayout {
                spacing: 22

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    ComboBox {
                        id: comboMicrophones
                        Layout.preferredHeight: 45
                        Layout.preferredWidth: 320
                        enabled: deviceTestMode === AudioDevice.TestMode.UnknownMode
                        textRole: "deviceName"

                        background: Rectangle {
                            border.color: "#CCCCCC"
                            border.width: 1
                            implicitHeight: 45
                            implicitWidth: 320
                            radius: 2
                        }
                        model: DeviceModel {
                            deviceType: DeviceSelector.DeviceType.RecordType
                            manager: deviceManager
                        }

                        Component.onCompleted: {
                            if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                                comboMicrophones.currentIndex = deviceManager.currentIndex(model.deviceType);
                            } else {
                                comboMicrophones.currentIndex = 0;
                            }
                        }
                        onActivated: {
                            deviceManager.selectDevice(model.deviceType, index);
                            const volume = deviceManager.getRecordDeviceVolume();
                            microphoneSlider.value = volume;
                        }
                        onCountChanged: {
                            microphoneProgress.value = 0;
                            deviceManager.startMicrophoneTest(false);
                            deviceTestMode = AudioDevice.TestMode.UnknownMode;
                            const currentIndex = deviceManager.currentIndex(model.deviceType);
                            comboMicrophones.currentIndex = currentIndex;
                        }
                    }
                    CustomButton {
                        id: btnMicrophoneTest
                        Layout.preferredHeight: 35
                        Layout.preferredWidth: 110
                        buttonRadius: 18
                        enabled: comboMicrophones.count > 0 && meetingManager.meetingId.length === 0 && (deviceTestMode === AudioDevice.TestMode.UnknownMode || deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode)
                        font.pixelSize: 14
                        highlighted: true
                        text: {
                            if (deviceTestMode === AudioDevice.TestMode.UnknownMode) {
                                return qsTr("Mic Test");
                            } else if (deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode) {
                                return qsTr("Stop");
                            }
                            return qsTr("Mic Test");
                        }

                        onClicked: {
                            if (deviceTestMode === AudioDevice.TestMode.UnknownMode) {
                                deviceTestMode = AudioDevice.TestMode.MicrophoneTestMode;
                                deviceManager.startMicrophoneTest(true);
                            } else if (deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode) {
                                microphoneProgress.value = 0;
                                deviceManager.startMicrophoneTest(false);
                                deviceTestMode = AudioDevice.TestMode.UnknownMode;
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.preferredWidth: 75
                        color: "#333333"
                        text: qsTr("Level")
                    }
                    CustomProgressBar {
                        id: microphoneProgress
                        Layout.fillWidth: true
                    }
                }
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.preferredWidth: SettingsStatus.UILanguage_zh !== SettingsManager.uiLanguage ? 100 : 75
                        color: "#333333"
                        text: qsTr("Volume")
                    }
                    Image {
                        Layout.preferredHeight: 16
                        Layout.preferredWidth: 16
                        mipmap: true
                        source: "qrc:/qml/images/settings/speaker_mute.png"
                    }
                    CustomSlider {
                        id: microphoneSlider
                        Layout.fillWidth: true
                        enabled: !checkAutoMicVolume.checked
                        to: 255
                        value: 1

                        Component.onCompleted: {
                            const volume = deviceManager.getRecordDeviceVolume();
                            value = volume;
                        }
                        onValueChanged: {
                            deviceManager.setRecordDeviceVolume(value);
                        }
                    }
                    Image {
                        Layout.preferredHeight: 16
                        Layout.preferredWidth: 16
                        mipmap: true
                        source: "qrc:/qml/images/settings/speaker_unmute.png"
                    }
                }
                CustomCheckBox {
                    id: checkAutoMicVolume
                    Layout.topMargin: 8
                    checked: SettingsManager.enableMicVolumeAutoAdjust
                    font.weight: Font.Light
                    text: qsTr("Automatically adjust microphone volume")

                    onClicked: {
                        SettingsManager.setEnableMicVolumeAutoAdjust(checked);
                        if ((MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) && microphoneSlider.value < 200) {
                            microphoneSlider.value = 200;
                        }
                    }
                }
                CustomCheckBox {
                    id: checkEnableMicBySpace
                    Layout.topMargin: 8
                    checked: SettingsManager.enableUnmuteBySpace
                    font.weight: Font.Light
                    text: qsTr("Long press the space bar to temporarily turn on the microphone")

                    onClicked: {
                        SettingsManager.enableUnmuteBySpace = checkEnableMicBySpace.checked;
                    }
                }
            }
        }
        CustomToolSeparator {
            id: horizontalSep
            Layout.topMargin: 35
            orientation: Qt.Horizontal

            contentItem: Rectangle {
                color: "#EDEEF0"
                implicitHeight: 1
                implicitWidth: root.width
            }
        }
        RowLayout {
            Layout.topMargin: 20
            spacing: 35

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 70
                Layout.topMargin: 12
                color: "#333333"
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr("ANC")
            }
            ColumnLayout {
                spacing: 5

                CustomCheckBox {
                    id: checkAudioAINS
                    Layout.topMargin: 12
                    checked: SettingsManager.enableAudioAINS
                    enabled: talkMode.checked
                    font.weight: Font.Light
                    text: qsTr("Smart noise reduction")

                    onClicked: SettingsManager.enableAudioAINS = checked
                }
                Text {
                    Layout.leftMargin: 25
                    Layout.preferredWidth: 435
                    font.pixelSize: 12
                    text: qsTr("If the environment is noisy or a common meeting is held, you can enable this option")
                    wrapMode: Text.WordWrap
                }
            }
        }
        RowLayout {
            Layout.topMargin: 15
            spacing: 35

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 70
                Layout.topMargin: 12
                color: "#333333"
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr("Audio quality")
            }
            ColumnLayout {
                Layout.leftMargin: -10
                spacing: 0

                RadioButton {
                    id: talkMode
                    checked: 0 === SettingsManager.audioProfile
                    enabled: MeetingStatus.MEETING_IDLE === meetingManager.roomStatus && musicModeSelectEnable
                    font.weight: Font.Light
                    text: qsTr("Talk Mode")

                    onClicked: {
                        musicModeSelectEnable = false;
                        musicMode.checked = false;
                        SettingsManager.setAudioProfile(0);
                        clickTimer.restart();
                    }
                }
                ColumnLayout {
                    spacing: 10

                    ColumnLayout {
                        spacing: 0

                        RadioButton {
                            id: musicMode
                            checked: !talkMode.checked
                            enabled: MeetingStatus.MEETING_IDLE === meetingManager.roomStatus && musicModeSelectEnable
                            font.weight: Font.Light
                            text: qsTr("Music Mode")

                            onClicked: {
                                musicModeSelectEnable = false;
                                talkMode.checked = false;
                                SettingsManager.setAudioProfile(1);
                                clickTimer.restart();
                            }
                        }
                        Text {
                            Layout.leftMargin: 35
                            Layout.preferredWidth: 435
                            Layout.topMargin: -10
                            font.pixelSize: 12
                            text: qsTr("You can enable this option in professional and music scenarios that have high requirements on sound quality")
                            wrapMode: Text.WordWrap
                        }
                    }
                    ColumnLayout {
                        Layout.leftMargin: 35
                        spacing: 20

                        CustomCheckBox {
                            id: echoCanceller
                            checked: SettingsManager.enableAudioEchoCancellation
                            enabled: musicMode.checked
                            font.weight: Font.Light
                            text: qsTr("Echo Canceller")

                            onClicked: {
                                SettingsManager.setEnableAudioEchoCancellation(checked);
                            }
                        }
                        CustomCheckBox {
                            id: enableStereo
                            checked: SettingsManager.enableAudioStereo
                            enabled: musicMode.checked && MeetingStatus.MEETING_IDLE === meetingManager.roomStatus
                            font.weight: Font.Light
                            text: qsTr("Enable Stereo")

                            onClicked: {
                                SettingsManager.setEnableAudioStereo(checked);
                            }
                        }
                    }
                }
            }
        }
    }
    Connections {
        target: meetingManager

        onMeetingStatusChanged: {
            switch (status) {
            case MeetingStatus.MEETING_CONNECTED:
                if (checkAutoMicVolume.checked && microphoneSlider.value < 200) {
                    microphoneSlider.value = 200;
                }
                break;
            case MeetingStatus.MEETING_CONNECT_FAILED:
            case MeetingStatus.MEETING_RECONNECT_FAILED:
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_MULTI_SPOT_LOGIN:
            case MeetingStatus.MEETING_ENDED:
                break;
            default:
                break;
            }
        }
    }
}
