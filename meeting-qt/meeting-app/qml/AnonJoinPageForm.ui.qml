import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0
import NetEase.Meeting.Clipboard 1.0

import "./components"
import "./profile"

Item {
    property int lastLengthOfMeetingId: 0
    property bool joinMeeting: false
    property alias clipboard: clipboard
    property alias header: header
    property alias textMeetingId: textMeetingId
    property alias textNickname: textNickname
    property alias checkCamera: checkCamera
    property alias checkMicrophone: checkMicrophone
    property alias buttonJoin: buttonJoin
    property alias feedback: feedback
    property string lastNicknameText: ''

    anchors.fill: parent

    // Save values to "HKEY_CURRENT_USER\Software\Netease\NetEase Meeting" on Windows automatically.
    Settings {
        property alias localUserNickname: textNickname.text
        property alias localCameraStatusEx: checkCamera.checked
        property alias localMicStatusEx: checkMicrophone.checked
    }

    Clipboard {
        id: clipboard
    }

    Feedback {
        id: feedback
    }

    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 45
        anchors.horizontalCenter: parent.horizontalCenter
        width: columnLayout.width
        height: columnLayout.height

        ColumnLayout {
            id: columnLayout
            spacing: 0

            PageHeader {
                id: header
                Layout.preferredHeight: 36
                Layout.preferredWidth: 330
                title: qsTr("Join anonymously")
            }

            CustomTextField {
                id: textMeetingId
                Layout.topMargin: 13
                Layout.preferredHeight: 54
                Layout.preferredWidth: 330
                placeholderText: qsTr("Meeting ID")
                font.pixelSize: 17
                focus: true
            }

            CustomTextField {
                id: textNickname
                Layout.topMargin: 9
                Layout.preferredHeight: 54
                Layout.preferredWidth: 330
                placeholderText: qsTr("Nickname")
                font.pixelSize: 17
            }

            Rectangle {
                width: 220
                height: 80
                Layout.topMargin: 8

                CustomCheckBox {
                    id: checkCamera
                    anchors.top: parent.top
                    font.pixelSize: 14
                    font.weight: Font.Light
                    text: qsTr("Open camera")
                    Layout.preferredWidth: 330
                }

                CustomCheckBox {
                    id: checkMicrophone
                    anchors.top: checkCamera.bottom
                    anchors.topMargin: 8
                    font.pixelSize: 14
                    font.weight: Font.Light
                    text: qsTr("Open microphone")
                    Layout.preferredWidth: 330
                }
            }

            CustomButton {
                id: buttonJoin
                highlighted: true
                text: qsTr("Join")
                enabled: textMeetingId.length >= 1 && textNickname.length > 0
                font.pixelSize: 16
                Layout.topMargin: 20
                Layout.preferredHeight: 50
                Layout.preferredWidth: 320
            }
        }
    }
}
