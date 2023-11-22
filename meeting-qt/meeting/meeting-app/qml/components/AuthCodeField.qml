import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

TextField {
    id: control

    property bool enableSendButton: false
    property var resend: false
    property int timerSeconds: 60

    signal getAuthCode

    font.pixelSize: 17
    maximumLength: 6
    placeholderText: qsTr("Auth code")
    placeholderTextColor: "#B0B6BE"
    rightPadding: 0
    leftPadding: 0
    selectByMouse: true

    background: Rectangle {
    }
    validator: RegularExpressionValidator {
        regularExpression: /\d+/
    }

    onEnableSendButtonChanged: {
        buttonSendMsg.enabled = enableSendButton;
    }
    onFocusChanged: {
        focus ? color = "#337EFF" : color = "#333333";
    }

    Rectangle {
        color: control.activeFocus ? control.Material.accentColor : "#DCDFE5"
        height: 1
        width: control.width
        y: control.height - height - control.bottomPadding + 8
    }
    ToolButton {
        anchors.verticalCenter: control.verticalCenter
        anchors.right: labelTimer.visible ? labelTimer.left : buttonSendMsg.left
        anchors.rightMargin: 0
        height: 40
        visible: control.length && control.hovered
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
    LabelButton {
        id: buttonSendMsg
        anchors.right: control.right
        anchors.verticalCenter: control.verticalCenter
        enabled: enableSendButton
        font.pixelSize: 14
        height: control.height
        text: resend ? qsTr("Reacquire") : qsTr("Get code")

        onClicked: {
            enabled = false;
            visible = false;
            getAuthCode();
        }
    }
    Label {
        id: labelTimer

        anchors.verticalCenter: control.verticalCenter
        anchors.right: staticLabel.left
        anchors.rightMargin: 3
        color: "#337EFF"
        font.pixelSize: 14
        text: timerSeconds + qsTr("s")
        visible: false
    }
    Label {
        id: staticLabel

        anchors.verticalCenter: control.verticalCenter
        anchors.right: control.right
        font.pixelSize: 14
        text: qsTr("to resend")
        visible: false
    }
    Timer {
        id: messageTimer

        interval: 1000
        repeat: true

        onTriggered: {
            if (timerSeconds === 0) {
                messageTimer.stop();
                labelTimer.visible = false;
                staticLabel.visible = false;
                buttonSendMsg.visible = true;
                buttonSendMsg.enabled = enableSendButton;
                timerSeconds = 60;
            } else {
                timerSeconds -= 1;
                buttonSendMsg.visible = false;
                buttonSendMsg.enabled = false;
                if (timerSeconds > 0)
                    labelTimer.text = timerSeconds + qsTr("s");
            }
        }
    }
    Connections {
        target: authManager

        onError: {
            if (resCode === 203) {
                buttonSendMsg.visible = true;
                buttonSendMsg.enabled = enableSendButton;
            }
        }
        onGotAuthCode: {
            timerSeconds = 60;
            labelTimer.text = timerSeconds + qsTr("s");
            labelTimer.visible = true;
            staticLabel.visible = true;
            buttonSendMsg.visible = false;
            buttonSendMsg.enabled = false;
            messageTimer.start();
        }
    }
}
