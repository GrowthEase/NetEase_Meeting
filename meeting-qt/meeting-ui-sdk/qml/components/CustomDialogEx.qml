import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Popup {
    id: root
    width: 320
    height: 169
    modal: true
    padding: 0
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    margins: 0
    dim: false
    background: Rectangle {
        radius: 8
    }
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property alias text: title.text
    property alias description: description.text

    signal end
    signal leave
    signal cancel

    onClosed: {
        // When created dynamically, is called when the dialog is closed only but the parent object is not destroyed
        root.destroy()
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.bottom: layoutButtons.top
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0
        Label {
            id: title
            text: ""
            color: "#222222"
            font.bold: true
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            id: description
            text: ""
            color: "#222222"
            wrapMode: Text.WrapAnywhere
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            Layout.topMargin: 0
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
        }
    }

    CustomToolSeparator {
        width: parent.width
        anchors.bottom: layoutButtons.top
    }

    RowLayout {
        id: layoutButtons
        width: parent.width
        anchors.bottom: parent.bottom
        spacing: 0
        CustomButton {
            buttonRadius: 8
            Layout.preferredHeight: 48
            Layout.preferredWidth: 105
            borderSize: 0
            normalTextColor: "#FE3B30"
            text: qsTr("End")
            onClicked: {
                end()
                close()
            }
        }
        ToolSeparator {
            padding: 0
            topInset: 0
            bottomInset: 0
            leftInset: 0
            rightInset: 0
            verticalPadding: 0
            horizontalPadding: 0
            contentItem: Rectangle {
                implicitWidth: 1
                implicitHeight: 48
                color: "#EBEDF0"
            }
        }
        CustomButton {
            buttonRadius: 8
            Layout.preferredHeight: 48
            Layout.preferredWidth: 105
            borderSize: 0
            normalTextColor: "#337EFF"
            text: qsTr("Leave")
            onClicked: {
                leave()
                close()
            }
        }
        ToolSeparator {
            padding: 0
            topInset: 0
            bottomInset: 0
            leftInset: 0
            rightInset: 0
            verticalPadding: 0
            horizontalPadding: 0
            contentItem: Rectangle {
                implicitWidth: 1
                implicitHeight: 48
                color: "#EBEDF0"
            }
        }
        CustomButton {
            buttonRadius: 8
            Layout.preferredHeight: 48
            Layout.preferredWidth: 105
            borderSize: 0
            normalTextColor: "#333333"
            text: qsTr("Cancel")
            onClicked: {
                cancel()
                close()
            }
        }
    }
}
