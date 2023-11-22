import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property alias description: description.text
    property bool enableCancel: true
    property alias text: title.text

    signal cancel
    signal end
    signal leave

    Accessible.name: title.text
    bottomInset: 0
    dim: false
    height: 169
    leftInset: 0
    margins: 0
    modal: true
    padding: 0
    rightInset: 0
    topInset: 0
    width: 320
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    background: Rectangle {
        radius: 8
    }

    onClosed: {
        // When created dynamically, is called when the dialog is closed only but the parent object is not destroyed
        root.destroy();
    }

    ColumnLayout {
        anchors.bottom: layoutButtons.top
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 0

        Label {
            id: title
            Layout.alignment: Qt.AlignHCenter
            color: "#222222"
            font.bold: true
            font.pixelSize: 18
            text: ""
        }
        Label {
            id: description
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width
            Layout.topMargin: 0
            color: "#222222"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            text: ""
            wrapMode: Text.WrapAnywhere
        }
    }
    CustomToolSeparator {
        anchors.bottom: layoutButtons.top
        width: parent.width
    }
    RowLayout {
        id: layoutButtons
        anchors.bottom: parent.bottom
        spacing: 0
        width: parent.width

        CustomButton {
            Layout.preferredHeight: 48
            Layout.preferredWidth: 105
            borderSize: 0
            buttonRadius: 8
            normalTextColor: "#FE3B30"
            text: qsTr("End")

            onClicked: {
                end();
                close();
            }
        }
        ToolSeparator {
            bottomInset: 0
            horizontalPadding: 0
            leftInset: 0
            padding: 0
            rightInset: 0
            topInset: 0
            verticalPadding: 0

            contentItem: Rectangle {
                color: "#EBEDF0"
                implicitHeight: 48
                implicitWidth: 1
            }
        }
        CustomButton {
            Layout.preferredHeight: 48
            Layout.preferredWidth: 105
            borderSize: 0
            buttonRadius: 8
            normalTextColor: "#337EFF"
            text: qsTr("Leave")

            onClicked: {
                leave();
                close();
            }
        }
        ToolSeparator {
            bottomInset: 0
            horizontalPadding: 0
            leftInset: 0
            padding: 0
            rightInset: 0
            topInset: 0
            verticalPadding: 0
            visible: enableCancel

            contentItem: Rectangle {
                color: "#EBEDF0"
                implicitHeight: 48
                implicitWidth: 1
            }
        }
        CustomButton {
            Layout.preferredHeight: 48
            Layout.preferredWidth: 105
            borderSize: 0
            buttonRadius: 8
            normalTextColor: "#333333"
            text: qsTr("Cancel")
            visible: enableCancel

            onClicked: {
                cancel();
                close();
            }
        }
    }
}
