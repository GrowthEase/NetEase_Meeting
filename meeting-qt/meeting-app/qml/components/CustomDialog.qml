import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Dialog {
    id: root
    width: 330
    height: 160
    modal: true
    dim: false
    padding: 0
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    margins: 0
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    background: Rectangle {
        id: backgroundRect
        radius: Qt.platform.os === 'windows' ? 0 : 10
        border.width: 1
        border.color: "#EBEDF0"
        layer.enabled: true
        layer.effect: DropShadow {
            width: backgroundRect.width
            height: backgroundRect.height
            x: backgroundRect.x
            y: backgroundRect.y
            visible: backgroundRect.visible
            source: backgroundRect
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: "#1917171a"
        }
    }

    property alias text: title.text
    property alias description: description.text
    property string confirmText: qsTr('OK')
    property string cancelText: qsTr('Cancel')
    property bool showCancel: true

    signal confirm
    signal cancel

    onClosed: {
        // When created dynamically, is called when the dialog is closed only but the parent object is not destroyed
        //root.destroy()
    }

    Label {
        id: title
        width: parent.width
        font.pixelSize: 18
        wrapMode: Text.WrapAnywhere
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Label {
        id: description
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
        anchors.leftMargin: showCancel ? 1 : (parent.width / 2 - confirm.width / 2)
        anchors.bottom: parent.bottom
        width: showCancel ? (parent.width / 2 - 2) : parent.width
        height: 44
        text: confirmText
        buttonRadius: Qt.platform.os === 'windows' ? 1 : 8
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
        visible: showCancel
        anchors.right: parent.right
        anchors.rightMargin: 1
        anchors.bottom: parent.bottom
        width: parent.width / 2 - 2
        height: 44
        text: cancelText
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
