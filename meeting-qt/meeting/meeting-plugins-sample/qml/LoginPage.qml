import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.1
import NEMeeting 1.0

Item {
    anchors.fill: parent

    Settings {
        id: settings
        property alias cachedUsername: textUsername.text
        property alias cachedPassword: textPassword.text
    }

    ColumnLayout {
        anchors.centerIn: parent
        TextField {
            id: textUsername
            text: settings.cachedUsername
            selectByMouse: true
            enabled: auth.state === NEMAuthenticate.AUTH_STATE_IDLE
            placeholderText: qsTr('Your username')
            Layout.fillWidth: true
        }
        TextField {
            id: textPassword
            text: settings.cachedPassword
            selectByMouse: true
            enabled: auth.state === NEMAuthenticate.AUTH_STATE_IDLE
            placeholderText: qsTr('Your password')
            echoMode: TextField.Password
            Layout.fillWidth: true
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Button {
                id: btnLogin
                text: qsTr('Sign in')
                enabled: auth.state === NEMAuthenticate.AUTH_STATE_IDLE
                highlighted: true
                Layout.preferredWidth: 220
                onClicked: {
                    auth.authByPassword(textUsername.text, textPassword.text)
                }
            }
        }
    }
}
