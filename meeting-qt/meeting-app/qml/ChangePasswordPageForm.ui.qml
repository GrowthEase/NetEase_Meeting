import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "components/"

Item {
    property bool verified: false
    property alias header: header
    property alias textPhoneNumber: textPhoneNumber
    property alias textCode: textCode
    property alias textPassword: textPassword
    property alias textConfirmPassword: textConfirmPassword
    property alias buttonSubmit: buttonSubmit

    anchors.fill: parent

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: columnLayout.width
        height: columnLayout.height

        ColumnLayout {
            id: columnLayout

            PageHeader {
                id: header
                Layout.preferredHeight: 36
                Layout.preferredWidth: 330
                title: qsTr("Verify phone number")
            }

            PhoneNumberField {
                id: textPhoneNumber
                placeholderText: qsTr("Phone number")
                KeyNavigation.tab: textCode
                Layout.preferredWidth: 330
                Layout.topMargin: 20
                visible: !verified
            }

            AuthCodeField {
                id: textCode
                enableSendButton: textPhoneNumber.length === 13
                visible: !verified
                Layout.topMargin: 12
                Layout.preferredWidth: 330
            }

            PasswordField {
                id: textPassword
                placeholderText: qsTr("New password")
                visible: verified
                KeyNavigation.tab: textConfirmPassword
                Layout.preferredWidth: 330
                Layout.topMargin: 20
            }

            PasswordField {
                id: textConfirmPassword
                placeholderText: qsTr("Confirm password")
                visible: verified
                Layout.preferredWidth: 330
                Layout.topMargin: 20
            }

            Label {
                id: labelPassword
                font.pixelSize: 12
                color: "#337EFF"
                text: qsTr("8~16 characters, supports letters and numbers")
                Layout.topMargin: -8
                visible: verified
            }

            CustomButton {
                id: buttonSubmit
                enabled: verified
                         ? (textPassword.text.length >= 8 && textPassword.text.length <= 16) &&
                           (textConfirmPassword.text.length >= 8 && textConfirmPassword.text.length <= 16)
                         : textPhoneNumber.length === 13 && textCode.length > 0
                highlighted: true
                text: qsTr("Next")
                font.pixelSize: 16
                Layout.preferredHeight: 50
                Layout.preferredWidth: 320
                Layout.topMargin: 45
                Layout.bottomMargin: 10
            }
        }
    }
}
