import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "components/"

Item {
    anchors.fill: parent

    property alias textPhoneNumber: textPhoneNumber
    property alias textCode: textCode
    property alias buttonSubmit: buttonSubmit
    property alias header: header
    property alias buttonLoginWithPassword: buttonLoginWithPassword
    property string rememberPhoneNumber: ''

    Rectangle {
        anchors.top: parent.top
        anchors.topMargin:45
        anchors.horizontalCenter: parent.horizontalCenter
        width: childrenRect.width
        height: childrenRect.height

        ColumnLayout {
            id: columnLayout

            PageHeader {
                id: header
                Layout.preferredHeight: 36
                Layout.preferredWidth: 330
                title: qsTr("Login with Phone")
            }

            PhoneNumberField {
                id: textPhoneNumber
                placeholderText: qsTr("Phone number")
                text: rememberPhoneNumber
                KeyNavigation.tab: textCode
                Layout.preferredWidth: 330
                Layout.topMargin: 20
            }

            AuthCodeField {
                id: textCode
                enableSendButton: textPhoneNumber.length === 13
                Layout.topMargin: 12
                Layout.preferredWidth: 330
            }

            Rectangle {
                width: 330
                height: buttonLoginWithPassword.height
                Layout.topMargin: -11
                LabelButton {
                    id: buttonLoginWithPassword
                    height: 30
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    text: qsTr("Login with password")
                    font.pixelSize: 14
                }
            }

            CustomButton {
                id: buttonSubmit
                enabled: textPhoneNumber.length === 13 && textCode.length > 0
                highlighted: true
                font.pixelSize: 16
                text: qsTr("Login")
                Layout.preferredHeight: 50
                Layout.preferredWidth: 320
                Layout.topMargin: 45
                Layout.bottomMargin: 10
            }
        }
    }
}

