import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

TextField {
    property int timerSeconds: 60
    property var resend: false
    property bool enableSendButton: false

    onEnableSendButtonChanged: {
        buttonSendMsg.enabled = enableSendButton
    }

    id: control
    selectByMouse: true
    font.pixelSize: 17
    maximumLength: 6
    rightPadding: 85
    placeholderText: qsTr("Auth code")
    placeholderTextColor: "#B0B6BE"
    validator: RegExpValidator {
        regExp: /\d+/
    }
    background: Rectangle {
        y: control.height - height - control.bottomPadding + 8
        implicitWidth: 120
        height: control.activeFocus || 1
        color: control.activeFocus ? control.Material.accentColor : "#DCDFE5"
    }
    onFocusChanged: {
        focus ? color = "#337EFF" : color = "#333333"
    }

    signal getAuthCode()

    ToolButton {
        width: 40
        height: 40
        anchors.right: labelTimer.visible ? labelTimer.left : buttonSendMsg.left
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 7
        visible: control.length && control.hovered
        onClicked: {
            control.clear()
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qml/images/public/button/btn_clear.svg"
        }
    }

    LabelButton {
        id: buttonSendMsg
        anchors.right: control.right
        anchors.rightMargin: 4
        anchors.bottom: control.bottom
        anchors.bottomMargin: 10
        enabled: enableSendButton
        font.pixelSize: 14
        height: 35
        text: resend ? qsTr("Reacquire")
                     : qsTr("Get code")
        onClicked: {
            enabled = false
            visible = false
            getAuthCode()
        }
    }

    Label {
        id: labelTimer
        anchors.right: staticLabel.left
        anchors.rightMargin: 3
        anchors.bottom: control.bottom
        anchors.bottomMargin: 17
        text: timerSeconds + qsTr("s")
        color: "#337EFF"
        visible: false
        font.pixelSize: 14
    }

    Label {
        id: staticLabel
        anchors.right: control.right
        anchors.bottom: control.bottom
        anchors.bottomMargin: 17
        text: qsTr("to resend")
        visible: false
        font.pixelSize: 14
    }

    Timer {
        id: messageTimer
        interval: 1000
        repeat: true
        onTriggered: {
            if (timerSeconds === 0) {
                messageTimer.stop()
                labelTimer.visible = false
                staticLabel.visible = false
                buttonSendMsg.visible = true
                buttonSendMsg.enabled = enableSendButton
                timerSeconds = 60
            } else {
                timerSeconds -= 1
                buttonSendMsg.visible = false
                buttonSendMsg.enabled = false
                if (timerSeconds > 0)
                    labelTimer.text = timerSeconds + qsTr("s")
            }
        }
    }

    Connections {
        target: authManager
        onGotAuthCode: {
            timerSeconds = 60
            labelTimer.text = timerSeconds + qsTr("s")
            labelTimer.visible = true
            staticLabel.visible = true
            buttonSendMsg.visible = false
            buttonSendMsg.enabled = false
            messageTimer.start()
        }
        onError: {
            if (resCode === 300 || resCode === 510 || resCode === 1003 || resCode === 1004 || resCode === 1010 || resCode === 1011 || resCode === 1015) {
                buttonSendMsg.visible = true
                buttonSendMsg.enabled = enableSendButton
            }
        }
    }
}




