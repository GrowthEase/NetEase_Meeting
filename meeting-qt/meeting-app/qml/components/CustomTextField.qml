import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

TextField {
    id: control
    rightPadding: 35
    selectByMouse: true
    placeholderTextColor: "#B0B6BE"
    background: Rectangle {
        y: control.height - height - control.bottomPadding + 8
        implicitWidth: 120
        height: control.activeFocus || 1
        color: control.activeFocus ? control.Material.accentColor : "#DCDFE5"
    }

    property var buttonRightPadding: -12

    ToolButton {
        width: 40
        height: 40
        anchors.right: control.right
        anchors.rightMargin: buttonRightPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        visible: control.length && control.enabled && control.hovered
        onClicked: {
            control.clear()
        }
        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qml/images/public/button/btn_clear.svg"
        }
    }

    onFocusChanged: {
        focus ? color = "#337EFF" : color = "#333333"
    }
}
