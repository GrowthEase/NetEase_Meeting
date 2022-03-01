import QtQuick 2.15
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NetEase.Meeting.Settings 1.0

import "components/"

Rectangle {
    anchors.fill: parent
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: "#292933"
        }
        GradientStop {
            position: 1.0
            color: "#1E1E25"
        }
    }

    property int retryTimes: 0
    property bool autoJoin: false

    Component.onCompleted: {
        if (mainWindow.visibility === Window.FullScreen) {
            mainWindow.showNormal()
        }

        viewMode = MainPanel.ViewMode.LoadingMode
    }

    ColumnLayout {
        anchors.centerIn: parent

        ColumnLayout {
            id: columnLayout
            spacing: 16

            Image {
                id: backgroundImage
                sourceSize.width: 100
                sourceSize.height: 100
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                source: "qrc:/qml/images/loading/logo.png"
            }

            Label {
                id: loadingText
                color: "#FFFFFF"
                font.pixelSize: 14
                text: qsTr("Entering the %1...").arg(Qt.application.displayName)
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }

        Item {
            Layout.preferredHeight: 40
        }
    }

    /*
    ColumnLayout {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        ImageButton {
            id: hangupButton
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.topMargin: 120
            Layout.alignment: Qt.AlignHCenter
            normalImage: 'qrc:/qml/images/loading/hangup_normal.png'
            hoveredImage: 'qrc:/qml/images/loading/hangup_hovered.png'
            pushedImage: 'qrc:/qml/images/loading/hangup_pushed.png'
            onClicked: {
                // meetingManager.leaveMeeting(false)
            }
        }

        Label {
            text: qsTr("Cancel")
            color: "#FFFFFF"
            font.pixelSize: 16
            Layout.topMargin: 5
            Layout.alignment: Qt.AlignHCenter
        }
    }
    */

    Connections {
        target: authManager
        onAuthInfoExpired: {
            console.log("onAuthInfoExpired")
            passwordWindow.setVisible(false)
            mainWindow.setVisible(false)
        }
    }
}
