pragma Singleton

import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Window {
    id: root
    visible: true
    width: toastContainer.width + 14
    height: toastContainer.height
    x: (Screen.width - width) / 2 + Screen.virtualX
    y: Screen.height - 200 + screen.virtualY
    title: qsTr("Hello World")
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    property string content: ""
    property real time: defaultTime
    readonly property real defaultTime: 3000
    readonly property real fadeTime: 300

    Component.onCompleted: {

    }

    function displayText(text, screen) {
        if (screen !== undefined) {
            root.screen = screen
            root.x = Qt.binding(function () { return (screen.width - width) / 2 + screen.virtualX })
            root.y = Qt.binding(function () { return (screen.height - 200) + screen.virtualY })
        }
        content = text
        root.show()
        anim.start()
    }

    Rectangle {
        width: childrenRect.width
        height: childrenRect.height
        color: "#BB1E1E1E"
        radius: 4
        RowLayout {
            spacing: 0
            Item { Layout.preferredWidth: 7 }
            ColumnLayout {
                id: toastContainer
                spacing: 0
                Item { Layout.preferredHeight: 5 }
                Label {
                    color: "#FFFFFF"
                    text: content
                    font.pixelSize: 14
                }
                Item { Layout.preferredHeight: 5 }
            }
            Item { Layout.preferredWidth: 7 }
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
            duration: time - 2*fadeTime
        }
        NumberAnimation {
            to: 0
            duration: fadeTime
        }
        onRunningChanged: {
            if (!running)
                root.hide();
        }
    }
}
