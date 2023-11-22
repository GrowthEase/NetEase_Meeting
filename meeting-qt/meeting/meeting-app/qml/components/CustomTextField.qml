import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

TextField {
    id: control

    property var buttonRightPadding: -12

    Accessible.name: placeholderText
    placeholderTextColor: "#B0B6BE"
    rightPadding: 35
    selectByMouse: true

    background: Rectangle {
        color: control.activeFocus ? control.Material.accentColor : "#DCDFE5"
        height: control.activeFocus || 1
        implicitWidth: 120
        y: control.height - height - control.bottomPadding + 8
    }

    onFocusChanged: {
        focus ? color = "#337EFF" : color = "#333333";
    }

    ToolButton {
        Accessible.name: "clear"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.right: control.right
        anchors.rightMargin: buttonRightPadding
        height: 40
        visible: control.length && control.enabled && control.hovered
        width: 40

        onClicked: {
            control.clear();
        }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            mipmap: true
            source: "qrc:/qml/images/public/button/btn_clear.svg"
        }
    }
}
