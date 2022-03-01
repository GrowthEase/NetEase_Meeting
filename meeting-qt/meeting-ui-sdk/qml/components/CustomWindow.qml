import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12


Window {
    id: rootWindow
    property int customWidth: 400
    property int customHeight: 214
    property alias title: idDragArea.title
    property alias loader: idLoader
    property alias submitText: idSubmit.text
    property alias submitEnabled: idSubmit.enabled

    signal submitClicked
    signal closeClicked

    width: customWidth + 20 // shadow size
    height: customHeight + 20
    color: "#00000000"
    Material.theme: Material.Light
    flags: Qt.Window | Qt.FramelessWindowHint

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        color: "#3217171A"
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    Connections {
        target: rootWindow
        onClosing: {
            rootWindow.hide()
            close.accepted = false
            closeClicked()
        }
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        border.width: 1
        border.color: '#FFFFFF'
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            spacing: 0
            anchors.fill: parent
            anchors.margins: 1

            DragArea {
                id: idDragArea
                Layout.preferredHeight: 52
                Layout.fillWidth: true
                onCloseClicked: {
                    Window.window.hide()
                    rootWindow.closeClicked()
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                radius: 10

                Loader {
                    id: idLoader
                    anchors.fill: parent
                    anchors.margins: 36
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                radius: 10
                CustomToolSeparator {
                    width: parent.width
                    anchors.left: parent.left
                    anchors.bottom: idSubmit.top
                    anchors.bottomMargin: idSubmit.anchors.bottomMargin
                }

                CustomButton {
                    id: idSubmit
                    height: 36
                    width: 120
                    highlighted: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12

                    onClicked: submitClicked()
                }
            }
        }
    }
}
