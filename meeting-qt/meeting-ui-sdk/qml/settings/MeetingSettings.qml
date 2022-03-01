import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0

import "../components"

Rectangle {
    anchors.fill: parent
    anchors.margins: 40
    radius: 10

    Component.onCompleted: {
        videoManager.stopLocalVideoPreview()
    }

    Settings {
        property alias localCameraStatusEx: checkCamera.checked
        property alias localMicStatusEx: checkMicrophone.checked
        property alias localShowtime: checkShowtime.checked
    }

    ColumnLayout {
        anchors.left: parent.left
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
            id: checkInternalRender
            font.weight: Font.Light
            text: qsTr("Internal Render")
            checked: SettingsManager.enableInternalRender
            visible: false //!SettingsManager.mainWindowVisible
            Layout.topMargin: 8
            onClicked: SettingsManager.setEnableInternalRender(checked)
        }
    }
}
