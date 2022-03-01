pragma Singleton

import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "../components"
Window{
    id:root
    visible: false
    width: 240
    height: 60
    flags:  Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    color: "transparent"

    property var msgSender: ""
    property string content: ""
    property bool shareScreen: false
    property real time: defaultTime
    readonly property real defaultTime: 5000
    readonly property real fadeTime: 300

    signal messageBubbleClick()

    Component.onCompleted: {

    }

    function toastChatMessage(sender, text, bshareScreen = false) {
        msgSender = sender
        content = text
        shareScreen = bshareScreen
        root.show()
        anim.restart()
    }

    Rectangle {
        id: msgBubble
        anchors.fill: parent
        radius: 8
        clip:true
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#292933"
            }
            GradientStop {
                position: 1.0
                color: "#212129"
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.hide()
                messageBubbleClick()
            }
        }

        Label {
            id: measure
            visible: false
            text: content
        }

        RowLayout {
            id:mainLayout
            spacing: 8
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 16
            anchors.topMargin: 13
            anchors.bottomMargin: 13
            clip: true
            Avatar{
                id: avatar
                nickname: msgSender.substring(0,1)
                Layout.alignment: Qt.AlignVCenter
            }
            ColumnLayout {
                id:subLayout
                spacing: 0
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumHeight: parent.height
                Label {
                    id: nicknamesay
                    Layout.maximumWidth: 200
                    font.pixelSize: 12
                    color: "white"
                    text: msgSender + qsTr(" say:")
                }
                Label {
                    id: currentMsg
                    Layout.maximumWidth: 180
                    font.pixelSize: 12
                    color: "white"
                    elide: Label.ElideRight
                    text: content.replace(/[\r\n]/g, '')
                }
            }
        }
    }

    SequentialAnimation on opacity {
        id: anim
        running: false

        NumberAnimation {
            to: 1
            duration: fadeTime
        }
        PauseAnimation {
            duration: time - 2 * fadeTime
        }
        NumberAnimation {
            to: 0
            duration: fadeTime
        }
        onRunningChanged: {
            if (!running)
            root.hide();
            else
            root.show();
        }
    }
}

