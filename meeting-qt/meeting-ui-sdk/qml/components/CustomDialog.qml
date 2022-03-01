import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Dialog {
    id: root
    width: 330
    height: 160
    modal: true
    padding: 0
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    margins: 0
    background: Rectangle {
        radius: 8
    }
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    enter: null
    exit: null

    property alias text: title.text
    property alias description: description.text
    property var   cancelBtnText : qsTr("Cancel")
    property var   confirmBtnText : qsTr("OK")
    signal confirm
    signal cancel

    onClosed: {
        // When created dynamically, is called when the dialog is closed only but the parent object is not destroyed
        //root.destroy()
    }

    Label {
        id: title
        width: parent.width
        color: "#222222"
        font.pixelSize: 18
        wrapMode: Text.WrapAnywhere
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Label {
        id: description
        color: "#222222"
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        height: 30
        anchors.top: title.bottom
        anchors.topMargin: 15
        font.pixelSize: 14
        wrapMode: Text.WrapAnywhere
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
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
        anchors.bottom: parent.bottom
        width: parent.width / 2 - 1
        height: 48
        text: qsTr(confirmBtnText)
        buttonRadius: 8
        borderColor: "#FFFFFF"
        normalTextColor: "#337EFF"
        borderSize: 0
        onClicked: {
            root.confirm()
            root.close()
        }
    }

    CustomButton {
        id: cancel
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: parent.width / 2 - 1
        height: 48
        text: qsTr(cancelBtnText)
        buttonRadius: 8
        borderColor: "#FFFFFF"
        normalTextColor: "#333333"
        borderSize: 0
        onClicked: {
            root.cancel()
            root.close()
        }
    }
}
