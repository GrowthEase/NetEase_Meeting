pragma Singleton
import QtQuick
import QtQuick.Window 2.12
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root

    property string content: ""
    readonly property real defaultTime: 3000
    readonly property real fadeTime: 300
    property real time: defaultTime

    function displayText(text, screen) {
        if (screen !== undefined) {
            root.screen = screen;
            root.x = Qt.binding(function () {
                    return (screen.width - width) / 2 + screen.virtualX;
                });
            root.y = Qt.binding(function () {
                    return (screen.height - height) / 2 + screen.virtualY;
                });
        }
        content = text;
        root.show();
        anim.restart();
    }

    color: "transparent"
    flags: {
        if (Qt.platform.os === 'windows')
            return Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowDoesNotAcceptFocus;
        else
            return Qt.FramelessWindowHint | Qt.Tool | Qt.WindowDoesNotAcceptFocus;
    }
    height: toastContainer.height
    title: qsTr("NetEase Meeting Global Toast")
    visible: true
    width: toastContainer.width + 60
    x: (Screen.width - width) / 2 + Screen.virtualX
    y: (Screen.height - height) / 2 + Screen.virtualY

    SequentialAnimation on opacity  {
        id: anim

        running: false

        onRunningChanged: {
            if (!running)
                root.hide();
            else
                root.show();
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

    onVisibleChanged: {
        if (Qt.platform.os === 'windows') {
            visible ? shareManager.addExcludeShareWindow(root) : shareManager.removeExcludeShareWindow(root);
        }
    }

    Rectangle {
        color: "#CC1E1E1E"
        height: childrenRect.height
        radius: 4
        width: childrenRect.width

        RowLayout {
            spacing: 0

            Item {
                Layout.preferredWidth: 30
            }
            ColumnLayout {
                id: toastContainer

                spacing: 0

                Item {
                    Layout.preferredHeight: 20
                }
                Label {
                    color: "#FFFFFF"
                    font.pixelSize: 18
                    text: content
                }
                Item {
                    Layout.preferredHeight: 20
                }
            }
            Item {
                Layout.preferredWidth: 30
            }
        }
    }
}
