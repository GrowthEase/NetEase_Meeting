import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12


import "../components"

CustomWindow {
    id: root

    width: 330
    height: 180
    title: qsTr('Exit')
    idLoader.sourceComponent: idCom
    flags: Qt.Window | Qt.FramelessWindowHint  | Qt.WindowStaysOnTopHint

    property string text: qsTr('Exit')
    property string description: qsTr('Do you want to exit App?')
    property string confirmText: qsTr('OK')
    property string cancelText: qsTr('Cancel')
    property bool showCancel: true

    signal confirm
    signal cancel

    Component {
        id: idCom
        Item {
            Label {
                id: description
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 20
                height: 30
                anchors.top: parent.top
                anchors.topMargin: 15
                font.pixelSize: 14
                wrapMode: Text.WrapAnywhere
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: root.description
            }

            CustomToolSeparator {
                width: parent.width
                anchors.left: parent.left
                anchors.bottom: confirm.top
            }

            ToolSeparator {
                anchors.top: confirm.top
                anchors.left: confirm.right
                anchors.leftMargin: 1
                orientation: Qt.Vertical
                padding: 0
                bottomInset: 0
                topInset: 0
                leftInset: 0
                rightInset: 0
                spacing: 0
                verticalPadding: 0
                horizontalPadding: 0
                contentItem: Rectangle {
                    implicitWidth: 1
                    implicitHeight: confirm.height
                    color: "#EBEDF0"
                }
            }

            CustomButton {
                id: confirm
                anchors.left: parent.left
                anchors.leftMargin: showCancel ? 1 : (parent.width / 2 - confirm.width / 2)
                anchors.bottom: parent.bottom
                width: showCancel ? (parent.width / 2 - 2) : parent.width
                height: 44
                text: root.confirmText
                buttonRadius: Qt.platform.os === 'windows' ? 1 : 8
                borderColor: "#FFFFFF"
                normalTextColor: "#337EFF"
                borderSize: 0
                onClicked: {
                    root.confirm()
                    root.close()
                    mainWindow.close()
                }
            }

            CustomButton {
                id: cancel
                visible: showCancel
                anchors.right: parent.right
                anchors.rightMargin: 1
                anchors.bottom: parent.bottom
                width: parent.width / 2 - 2
                height: 44
                text: root.cancelText
                buttonRadius: Qt.platform.os === 'windows' ? 1 : 8
                borderColor: "#FFFFFF"
                normalTextColor: "#333333"
                borderSize: 0
                onClicked: {
                    root.cancel()
                    root.close()
                }
            }
        }
    }
}
