import QtQuick
import Qt.labs.platform 1.1
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings 1.0

import "../components"

Rectangle {
    anchors.fill: parent
    anchors.margins: 40
    radius: 10

    Component.onCompleted: {
        videoManager.stopLocalVideoPreview()
        meetingSettings.sync()
        const cameraStatus = meetingSettings.value("localCameraStatusEx")
        const microphoneStatus = meetingSettings.value("localMicStatusEx")
        checkCamera.checked = cameraStatus === undefined ? false : cameraStatus === true || cameraStatus === "true"
        checkMicrophone.checked = microphoneStatus === undefined ? false : microphoneStatus === true || microphoneStatus === "true"
    }

    Settings {
        id: meetingSettings
        property alias localCameraStatusEx: checkCamera.checked
        property alias localMicStatusEx: checkMicrophone.checked
        property alias localShowtime: checkShowtime.checked
    }

    FolderDialog {
        id: folderDialog
        onAccepted: {
            var filePath = folderDialog.currentFolder.toString()
            if(Qt.platform.os === 'osx') {
                filePath = filePath.replace("file://", "")
            } else {
                filePath = filePath.replace("file:///", "")
            }
            SettingsManager.cacheDir = filePath
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        width: parent.width
        spacing: 11

        CustomCheckBox {
            id: checkCamera
            font.weight: Font.Light
            text: qsTr("Open camera")
            checked: false
            onClicked:{
                SettingsManager.setEnableVideoAfterJoin(checked)
            }
        }

        CustomCheckBox {
            id: checkMicrophone
            font.weight: Font.Light
            text: qsTr("Open microphone")
            checked: false
            Layout.topMargin: 8
            onClicked:{
                SettingsManager.setEnableAudioAfterJoin(checked)
            }
        }

        CustomCheckBox {
            id: checkShowtime
            font.weight: Font.Light
            text: qsTr("Show time")
            checked: false
            Layout.topMargin: 8
            onClicked: meetingManager.showMeetingDuration = checked
        }

        CustomCheckBox {
            id: checkShowSpeakers
            font.weight: Font.Light
            text: qsTr("Show Speaker")
            Layout.topMargin: 8
            checked: SettingsManager.showSpeaker
            onClicked: SettingsManager.setShowSpeaker(checked)
        }

        CustomCheckBox {
            id: checkInternalRender
            font.weight: Font.Light
            text: qsTr("Internal Render")
            checked: SettingsManager.enableInternalRender
            visible: false //!SettingsManager.mainWindowVisible
            Layout.topMargin: 8
            onClicked: SettingsManager.setEnableInternalRender(checked)
        }

        Rectangle {
            Layout.preferredHeight: 62
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                RowLayout {
                    spacing: 14
                    Label {
                        text: qsTr("file save path")
                        color: "#5d5d5d"
                    }
                    CustomButton {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 26
                        Layout.alignment: Qt.AlignHCenter
                        buttonRadius: 4
                        text: qsTr("select dir")
                        font.pixelSize: 12

                        onClicked: {
                            folderDialog.folder = "file:///" + SettingsManager.cacheDir
                            folderDialog.open()
                        }
                    }
                }

                Label {
                    text: SettingsManager.cacheDir
                    elide: Label.ElideRight
                    Layout.fillWidth: true
                    color: "#999999"
                }
            }
        }
    }

    Connections {
        target: SettingsManager
        function onEnableAudioAfterJoinChanged() {
            checkMicrophone.checked = SettingsManager.enableAudioAfterJoin
        }
        function onEnableVideoAfterJoinChanged() {
            checkCamera.checked = SettingsManager.enableVideoAfterJoin
        }
    }
}
