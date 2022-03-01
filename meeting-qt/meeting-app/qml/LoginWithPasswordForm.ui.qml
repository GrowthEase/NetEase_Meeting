import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "components/"

Item {
    property alias header: header
    property alias textPhoneNumber: textPhoneNumber
    property alias textPassword: textPassword
    property alias buttonForgotPwd: buttonForgotPwd
    property alias buttonLoginWithCode: buttonLoginWithCode
    property alias buttonSubmit: buttonSubmit
    property string rememberPhoneNumber: ''

    anchors.fill: parent

    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 45
        anchors.horizontalCenter: parent.horizontalCenter
        width: childrenRect.width
        height: childrenRect.height

        ColumnLayout {
            id: columnLayout

            PageHeader {
                id: header
                Layout.preferredHeight: 36
                Layout.preferredWidth: 330
                title: qsTr("Login with Password")
            }

            PhoneNumberField {
                id: textPhoneNumber
                placeholderText: qsTr("Phone number")
                text: rememberPhoneNumber
                KeyNavigation.tab: textPassword
                Layout.preferredWidth: 330
                Layout.topMargin: 20
            }

            PasswordField {
                id: textPassword
                placeholderText: qsTr("Password")
                Layout.preferredWidth: 330
                Layout.topMargin: 12
            }

            Rectangle {
                width: 330
                height: buttonForgotPwd.height
                Layout.topMargin: -8

                LabelButton {
                    id: buttonForgotPwd
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    text: qsTr("Forgot password")
                    height: 25
                    normalColor: "#8a8a8a"
                    pressedColor: "#707070"
                    font.pixelSize: 14
                }

                LabelButton {
                    id: buttonLoginWithCode
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    text: qsTr("Login with Phone")
                    height: 25
                    font.pixelSize: 14
                }
            }

            CustomButton {
                id: buttonSubmit
                enabled: textPhoneNumber.length === 13 && textPassword.length >= 8 && textPassword.length <= 16
                highlighted: true
                text: qsTr("Login")
                font.pixelSize: 16
                Layout.preferredHeight: 50
                Layout.preferredWidth: 320
                Layout.topMargin: 45
                Layout.bottomMargin: 10
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

