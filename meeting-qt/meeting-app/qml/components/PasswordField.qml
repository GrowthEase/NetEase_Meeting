import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

TextField {
    id: control
    echoMode: TextInput.Password
    selectByMouse: true
    rightPadding: 30
    font.pixelSize: 17
    placeholderTextColor: "#B0B6BE"
    color: "#FF337EFF"
    background: Rectangle {
        y: control.height - height - control.bottomPadding + 8
        implicitWidth: 120
        height: control.activeFocus || 1
        color: control.activeFocus ? control.Material.accentColor : "#DCDFE5"
    }
    validator: RegExpValidator {
        regExp: /[a-zA-Z0-9]{1,16}/
    }

    ToolButton {
        width: 40
        height: 40
        anchors.right: control.right
        anchors.rightMargin: -12
        anchors.bottom: control.bottom
        anchors.bottomMargin: 8
        visible: control.echoMode === TextInput.Password && control.length > 0
        onClicked: {
            control.echoMode = TextInput.Normal
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qml/images/public/button/btn_eye.svg"
        }
    }

    ToolButton {
        width: 40
        height: 40
        anchors.right: control.right
        anchors.rightMargin: -12
        anchors.bottom: control.bottom
        anchors.bottomMargin: 8
        visible: control.echoMode === TextInput.Normal && control.length > 0
        onClicked: {
            control.echoMode = TextInput.Password
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qml/images/public/button/btn_close_eye.svg"
        }
    }
}


