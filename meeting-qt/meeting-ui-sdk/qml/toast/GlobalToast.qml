pragma Singleton

import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Window {
    id: root
    visible: true
    width: toastContainer.width + 60
    height: toastContainer.height
    x: (Screen.width - width) / 2 + Screen.virtualX
    y: (Screen.height - height) / 2 + Screen.virtualY
    title: qsTr("NetEase Meeting Global Toast")
    color: "transparent"
    flags: {
        if (Qt.platform.os === 'windows')
            Qt.Popup | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        else
            Qt.Popup | Qt.FramelessWindowHint
    }

    property string content: ""
    property real time: defaultTime
    readonly property real defaultTime: 3000
    readonly property real fadeTime: 300

    function displayText(text, screen) {
        if (screen !== undefined) {
            root.screen = screen
            root.x = Qt.binding(function () { return (screen.width - width) / 2 + screen.virtualX })
            root.y = Qt.binding(function () { return (screen.height - height) / 2 + screen.virtualY })
        }
        content = text
        root.show()
        anim.restart()
    }

    Rectangle {
        width: childrenRect.width
        height: childrenRect.height
        color: "#CC1E1E1E"
        radius: 4
        RowLayout {
            spacing: 0
            Item { Layout.preferredWidth: 30 }
            ColumnLayout {
                id: toastContainer
                spacing: 0
                Item { Layout.preferredHeight: 20 }
                Label {
                    color: "#FFFFFF"
                    text: content
                    font.pixelSize: 18
                }
                Item { Layout.preferredHeight: 20 }
            }
            Item { Layout.preferredWidth: 30 }
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
