pragma Singleton
import QtQuick
import QtQuick.Window 2.12
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Window {
    id: root

    property string content: ""
    readonly property real defaultTime: 5000
    readonly property real fadeTime: 300
    property var msgSender: ""
    property bool shareScreen: false
    property real time: defaultTime

    signal messageBubbleClick

    function toastChatMessage(sender, text, bshareScreen = false) {
        msgSender = sender;
        content = text;
        shareScreen = bshareScreen;
        root.show();
        anim.restart();
    }

    color: "transparent"
    flags: {
        if (Qt.platform.os === 'windows')
            return Qt.SubWindow | Qt.FramelessWindowHint;
        else
            return Qt.FramelessWindowHint | Qt.Popup;
    }
    height: 60
    visible: false
    width: 240

    SequentialAnimation on opacity  {
        id: anim
        running: false

        onRunningChanged: {
            if (!running) {
                root.hide();
            } else {
                root.show();
            }
        }

        NumberAnimation {
            duration: fadeTime
            to: 1
        }
        PauseAnimation {
            duration: time - 2 * fadeTime
        }
        NumberAnimation {
            duration: fadeTime
            to: 0
        }
    }

    Component.onCompleted: {
    }
    onVisibleChanged: {
        if (Qt.platform.os === 'windows') {
            visible ? shareManager.addExcludeShareWindow(root) : shareManager.removeExcludeShareWindow(root);
        }
    }

    Rectangle {
        id: msgBubble
        anchors.fill: parent
        clip: true
        radius: 8

        gradient: Gradient {
            GradientStop {
                color: "#292933"
                position: 0.0
            }
            GradientStop {
                color: "#212129"
                position: 1.0
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.hide();
                messageBubbleClick();
            }
        }
        Label {
            id: measure
            text: content
            visible: false
        }
        RowLayout {
            id: mainLayout
            anchors.bottomMargin: 13
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 16
            anchors.topMargin: 13
            clip: true
            spacing: 8

            Avatar {
                id: avatar
                Layout.alignment: Qt.AlignVCenter
                nickname: msgSender.substring(0, 1)
            }
            ColumnLayout {
                id: subLayout
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumHeight: parent.height
                Layout.preferredWidth: 200
                spacing: 0

                Label {
                    id: nicknamesay
                    Layout.maximumWidth: 200
                    color: "white"
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    text: msgSender + qsTr(" say:")
                }
                Label {
                    id: currentMsg
                    Layout.maximumWidth: 180
                    color: "white"
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    text: content.trim()
                }
            }
        }
    }
}
