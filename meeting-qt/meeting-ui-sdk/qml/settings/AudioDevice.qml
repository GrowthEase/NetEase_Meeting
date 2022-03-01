import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Styles 1.4
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.Settings 1.0
import "../components"

Rectangle {
    property int deviceTestMode: AudioDevice.TestMode.UnknownMode

    anchors.fill: parent
    anchors.margins: 35

    enum TestMode {
        UnknownMode,
        SpeakerTestMode,
        MicrophoneTestMode
    }

    Component.onCompleted: {
        videoManager.stopLocalVideoPreview()
    }

    Component.onDestruction: {
        stopTest()
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

    ColumnLayout {
        RowLayout {
            spacing: 35
            Label {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 12
                Layout.preferredWidth: 70
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
                            const currentIndex = deviceManager.currentIndex(model.deviceType)
                            comboSpeakers.currentIndex = currentIndex
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
                        Layout.preferredWidth: 75
                        text: qsTr("Volume")
                        color: "#333333"
                    }
                    Image {
                        Layout.preferredHeight: 16
                        Layout.preferredWidth: 16
                        source: "qrc:/qml/images/settings/speaker_mute.png"
                    }
                    CustomSlider {
                        id: speakerSlider
                        Layout.fillWidth: true
                        to: 255
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
                Layout.preferredWidth: 70
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
                            const currentIndex = deviceManager.currentIndex(model.deviceType)
                            comboMicrophones.currentIndex = currentIndex
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
                        Layout.preferredWidth: 75
                        text: qsTr("Volume")
                        color: "#333333"
                    }
                    Image {
                        Layout.preferredHeight: 16
                        Layout.preferredWidth: 16
                        source: "qrc:/qml/images/settings/speaker_mute.png"
                    }
                    CustomSlider {
                        id: microphoneSlider
                        Layout.fillWidth: true
                        to: 255
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
                        source: "qrc:/qml/images/settings/speaker_unmute.png"
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
}
