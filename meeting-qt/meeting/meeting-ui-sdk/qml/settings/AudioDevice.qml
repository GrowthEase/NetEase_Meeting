import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Styles 1.4
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.Settings 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Settings.SettingsStatus 1.0
import "../components"

Item {
    id: root
    property int deviceTestMode: AudioDevice.TestMode.UnknownMode
    property bool musicModeSelectEnable: true

    anchors.fill: parent
    anchors.margins: 35

    enum TestMode {
        UnknownMode,
        SpeakerTestMode,
        MicrophoneTestMode
    }

    Component.onCompleted: {
        videoManager.stopLocalVideoPreview()
        root.musicModeSelectEnable = true
    }

    Component.onDestruction: {
        stopTest()
        root.musicModeSelectEnable = true
    }

    Connections {
        target: deviceManager
        onLocalAudioVolumeIndication: {
            if(deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
                speakerProgress.value = volume;
                microphoneProgress.value = 0;
            } else if(deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode) {
                microphoneProgress.value = volume;
                speakerProgress.value = 0;
            }
        }
    }

    Connections {
        target: SettingsWnd
        function onVisibleStatus() {
            if (!SettingsWnd.visible) {
                stopTest()
                root.musicModeSelectEnable = true
            }
        }
    }

    Timer {
        id: speakerTestTimer
        interval: 9000
        onTriggered: {
            if (deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
                //btnMicrophoneTest.enabled = true
                //comboSpeakers.enabled = true
                //comboMicrophones.enabled = true
                deviceManager.startSpeakerTest(false)
                deviceTestMode = AudioDevice.TestMode.UnknownMode
                speakerProgress.value = 0
            }
        }
    }

    Timer {
        id: clickTimer
        interval: 500
        repeat: false
        onTriggered: {
            musicModeSelectEnable = true
        }
    }

    ColumnLayout {
        width: root.width
        RowLayout {
            spacing: 35
            Label {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 12
                Layout.preferredWidth: SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage ? 80 : 70
                text: qsTr("Speakers")
                color: "#333333"
                font.weight: Font.Medium
                font.pixelSize: 16
            }

            ColumnLayout {
                spacing: 22

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    ComboBox {
                        id: comboSpeakers
                        Layout.preferredWidth: 320
                        Layout.preferredHeight: 45
                        textRole: "deviceName"
                        enabled: deviceTestMode === AudioDevice.TestMode.UnknownMode
                        model: DeviceModel {
                            deviceType: DeviceSelector.DeviceType.PlayoutType
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
                            deviceManager.selectDevice(model.deviceType, index)
                            const volume = deviceManager.getPlayoutDeviceVolume()
                            speakerSlider.value = volume
                        }
                        onCountChanged: {
                            //btnMicrophoneTest.enabled = true
                            //comboSpeakers.enabled = true
                            //comboMicrophones.enabled = true
                            speakerProgress.value = 0
                            deviceManager.startSpeakerTest(false)
                            deviceTestMode = AudioDevice.TestMode.UnknownMode
                            speakerTestTimer.stop()

                            const currentIndex = deviceManager.currentIndex(model.deviceType)
                            comboSpeakers.currentIndex = currentIndex
                        }
                        Component.onCompleted: {
                            if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                                comboSpeakers.currentIndex = deviceManager.currentIndex(model.deviceType)
                            } else {
                                comboSpeakers.currentIndex = 0
                            }
                        }
                    }
                    CustomButton {
                        id: btnSpeakerTest
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 35
                        buttonRadius: 18
                        font.pixelSize: 14
                        highlighted: true
                        enabled: comboSpeakers.count > 0 && meetingManager.meetingId.length === 0 &&
                                 (deviceTestMode === AudioDevice.TestMode.UnknownMode || deviceTestMode === AudioDevice.TestMode.SpeakerTestMode)
                        text: {
                            if (deviceTestMode === AudioDevice.TestMode.UnknownMode) {
                                return qsTr("Speaker Test")
                            } else if (deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
                                return qsTr("Stop")
                            }
                            return qsTr("Speaker Test")
                        }
                        onClicked: {
                            if (deviceTestMode === AudioDevice.TestMode.UnknownMode) {
                                //btnMicrophoneTest.enabled = false
                                //comboSpeakers.enabled = false
                                //comboMicrophones.enabled = false
                                deviceTestMode = AudioDevice.TestMode.SpeakerTestMode
                                deviceManager.startSpeakerTest(true)
                                speakerTestTimer.start()
                            } else if (deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
                                //btnMicrophoneTest.enabled = true
                                //comboSpeakers.enabled = true
                                //comboMicrophones.enabled = true
                                speakerProgress.value = 0
                                deviceManager.startSpeakerTest(false)
                                deviceTestMode = AudioDevice.TestMode.UnknownMode
                                speakerTestTimer.stop()
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        Layout.preferredWidth: 75
                        text: qsTr("Level")
                        color: "#333333"
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
                        text: qsTr("Volume")
                        color: "#333333"
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
                            const volume = deviceManager.getPlayoutDeviceVolume()
                            value = volume
                        }
                        onValueChanged: {
                            deviceManager.setPlayoutDeviceVolume(value)
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
            spacing: 35
            Layout.topMargin: 30

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage ? 80 : 70
                Layout.topMargin: 12
                text: qsTr("Micros")
                color: "#333333"
                font.weight: Font.Medium
                font.pixelSize: 16
            }

            ColumnLayout {
                spacing: 22

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    ComboBox {
                        id: comboMicrophones
                        Layout.preferredWidth: 320
                        Layout.preferredHeight: 45
                        textRole: "deviceName"
                        enabled: deviceTestMode === AudioDevice.TestMode.UnknownMode
                        model: DeviceModel {
                            deviceType: DeviceSelector.DeviceType.RecordType
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
                            deviceManager.selectDevice(model.deviceType, index)
                            const volume = deviceManager.getRecordDeviceVolume()
                            microphoneSlider.value = volume
                        }
                        onCountChanged: {
                            ///btnSpeakerTest.enabled = true
                            ///comboSpeakers.enabled = true
                            ///comboMicrophones.enabled = true
                            microphoneProgress.value = 0
                            deviceManager.startMicrophoneTest(false)
                            deviceTestMode = AudioDevice.TestMode.UnknownMode

                            const currentIndex = deviceManager.currentIndex(model.deviceType)
                            comboMicrophones.currentIndex = currentIndex
                        }
                        Component.onCompleted: {
                            if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                                comboMicrophones.currentIndex = deviceManager.currentIndex(model.deviceType)
                            } else {
                                comboMicrophones.currentIndex = 0
                            }
                        }
                    }

                    CustomButton {
                        id: btnMicrophoneTest
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 35
                        buttonRadius: 18
                        font.pixelSize: 14
                        highlighted: true
                        enabled: comboMicrophones.count > 0 && meetingManager.meetingId.length === 0 &&
                                 (deviceTestMode === AudioDevice.TestMode.UnknownMode || deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode)
                        text: {
                            if (deviceTestMode === AudioDevice.TestMode.UnknownMode) {
                                return qsTr("Mic Test")
                            } else if (deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode) {
                                return qsTr("Stop")
                            }
                            return qsTr("Mic Test")
                        }
                        onClicked: {
                            if (deviceTestMode === AudioDevice.TestMode.UnknownMode) {
                                //btnSpeakerTest.enabled = false
                                //comboSpeakers.enabled = false
                                //comboMicrophones.enabled = false
                                deviceTestMode = AudioDevice.TestMode.MicrophoneTestMode
                                deviceManager.startMicrophoneTest(true)
                            } else if (deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode) {
                                //btnSpeakerTest.enabled = true
                                //comboSpeakers.enabled = true
                                //comboMicrophones.enabled = true
                                microphoneProgress.value = 0
                                deviceManager.startMicrophoneTest(false)
                                deviceTestMode = AudioDevice.TestMode.UnknownMode
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        Layout.preferredWidth: 75
                        text: qsTr("Level")
                        color: "#333333"
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
                        text: qsTr("Volume")
                        color: "#333333"
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
                        to: 255
                        value: 1
                        enabled: !checkAutoMicVolume.checked
                        Component.onCompleted: {
                            const volume = deviceManager.getRecordDeviceVolume()
                            value = volume
                        }
                        onValueChanged: {
                            deviceManager.setRecordDeviceVolume(value)
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
                    font.weight: Font.Light
                    text: qsTr("Automatically adjust microphone volume")
                    checked: SettingsManager.enableMicVolumeAutoAdjust
                    Layout.topMargin: 8
                    onClicked: {
                        SettingsManager.setEnableMicVolumeAutoAdjust(checked)
                        if ((MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) && microphoneSlider.value < 200) {
                            microphoneSlider.value = 200
                        }
                    }
                }

                CustomCheckBox {
                    id: checkEnableMicBySpace
                    font.weight: Font.Light
                    text: qsTr("Long press the space bar to temporarily turn on the microphone")
                    checked: SettingsManager.enableUnmuteBySpace
                    Layout.topMargin: 8
                    onClicked: {
                        SettingsManager.enableUnmuteBySpace = checkEnableMicBySpace.checked
                    }
                }
            }
        }

        CustomToolSeparator {
            id: horizontalSep
            orientation: Qt.Horizontal
            Layout.topMargin: 35
            contentItem: Rectangle {
                implicitWidth: root.width
                implicitHeight: 1
                color: "#EDEEF0"
            }
        }

        RowLayout {
            spacing: 35
            Layout.topMargin: 20

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 70
                Layout.topMargin: 12
                text: qsTr("Audio noise reduction")
                color: "#333333"
                font.weight: Font.Medium
                font.pixelSize: 16
            }

            ColumnLayout {
                spacing: 5
                CustomCheckBox {
                    id: checkAudioAINS
                    font.weight: Font.Light
                    text: qsTr("Smart noise reduction")
                    enabled: talkMode.checked
                    checked: SettingsManager.enableAudioAINS
                    Layout.topMargin: 12
                    onClicked: SettingsManager.enableAudioAINS = checked
                }
                Text {
                    Layout.leftMargin: 25
                    Layout.preferredWidth: 435
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    text: qsTr("If the environment is noisy or a common meeting is held, you can enable this option")
                }
            }
        }

        RowLayout {
            spacing: 35
            Layout.topMargin: 15

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 70
                Layout.topMargin: 12
                text: qsTr("Audio quality")
                color: "#333333"
                font.weight: Font.Medium
                font.pixelSize: 16
            }

            ColumnLayout {
                spacing: 0
                Layout.leftMargin: -10
                RadioButton {
                    id: talkMode
                    font.weight: Font.Light
                    text: qsTr("Talk Mode")
                    enabled: MeetingStatus.MEETING_IDLE === meetingManager.roomStatus && musicModeSelectEnable
                    checked: 0 === SettingsManager.audioProfile
                    onClicked: {
                        musicModeSelectEnable = false
                        musicMode.checked = false
                        SettingsManager.setAudioProfile(0)
                        clickTimer.restart()
                    }
                }

                ColumnLayout {
                    spacing: 10
                    ColumnLayout {
                        spacing: 0
                        RadioButton {
                            id: musicMode
                            font.weight: Font.Light
                            text: qsTr("Music Mode")
                            enabled: MeetingStatus.MEETING_IDLE === meetingManager.roomStatus && musicModeSelectEnable
                            checked: !talkMode.checked
                            onClicked: {
                                musicModeSelectEnable = false
                                talkMode.checked = false
                                SettingsManager.setAudioProfile(1)
                                clickTimer.restart()
                            }
                        }
                        Text {
                            Layout.leftMargin: 35
                            Layout.topMargin: -10
                            Layout.preferredWidth: 435
                            wrapMode: Text.WordWrap
                            font.pixelSize: 12
                            text: qsTr("You can enable this option in professional and music scenarios that have high requirements on sound quality")
                        }
                    }
                    ColumnLayout {
                        spacing: 20
                        Layout.leftMargin: 35
                        CustomCheckBox {
                            id: echoCanceller
                            font.weight: Font.Light
                            enabled: musicMode.checked
                            text: qsTr("Echo Canceller")
                            checked: SettingsManager.enableAudioEchoCancellation
                            onClicked: { SettingsManager.setEnableAudioEchoCancellation(checked) }
                        }

                        CustomCheckBox {
                            id: enableStereo
                            font.weight: Font.Light
                            enabled: musicMode.checked && MeetingStatus.MEETING_IDLE === meetingManager.roomStatus
                            text: qsTr("Enable Stereo")
                            checked: SettingsManager.enableAudioStereo
                            onClicked: { SettingsManager.setEnableAudioStereo(checked) }
                        }
                    }
                }
            }
        }
    }

    function stopTest() {
        if (deviceTestMode === AudioDevice.TestMode.SpeakerTestMode) {
            deviceManager.startSpeakerTest(false)
        } else if (deviceTestMode === AudioDevice.TestMode.MicrophoneTestMode) {
            deviceManager.startMicrophoneTest(false)
        }
    }

    Connections {
        target: meetingManager
        onMeetingStatusChanged: {
            switch (status) {
            case MeetingStatus.MEETING_CONNECTED:
                if (checkAutoMicVolume.checked && microphoneSlider.value < 200) {
                    microphoneSlider.value = 200
                }
                break
            case MeetingStatus.MEETING_CONNECT_FAILED:
            case MeetingStatus.MEETING_RECONNECT_FAILED:
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_MULTI_SPOT_LOGIN:
            case MeetingStatus.MEETING_ENDED:
                break
            default:
                break
            }
        }
    }
}
