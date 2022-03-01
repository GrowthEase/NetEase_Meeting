import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../components"

CustomPopup {
    id: popupForgotPassword
    width: 400
    height: contentContainer.height
    x: (parent.width - width) / 2
    y: (mainWindow.height - height) / 2
    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0
    padding: 0
    margins: 0

    property bool verified: false

    Component.onCompleted: {
        verified = false
        btnPopupClose.title = qsTr("Verify Phone Number")
        buttonResetPassword.text = qsTr("Next")

        textCode.clear()
        textPassword.clear()
        confirmPassword.clear()
    }

    onClosed: {
        popupForgotPassword.destroy()
    }

    function bindingFunction() {
        return verified
                ? (textPassword.length >= 8 && textPassword.length <= 16) &&
                  (confirmPassword.length >= 8 && confirmPassword.length <= 16)
                : textPhoneNumber.length === 13 && textCode.length > 0
    }

    ColumnLayout {
        id: contentContainer
        width: parent.width
        spacing: 0

        DragArea {
            id: btnPopupClose
            title: qsTr("Verify Phone Number")
            windowMode: false
            titleFontSize: 18
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            onCloseClicked: {
                onClicked: popupForgotPassword.close()
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 320
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            Layout.bottomMargin: 20
            spacing: 10

            PhoneNumberField {
                id: textPhoneNumber
                placeholderText: qsTr("Phone number")
                KeyNavigation.tab: textCode
                Layout.preferredWidth: 320
                Layout.topMargin: 10
                visible: !verified
                enabled: false
                text: authManager.phoneNumber.substring(0, 3) + "-" +
                      authManager.phoneNumber.substring(3, 7) + "-" +
                      authManager.phoneNumber.substring(7)
            }

            AuthCodeField {
                id: textCode
                enableSendButton: textPhoneNumber.length === 13
                visible: !verified
                Layout.preferredWidth: 320
                onGetAuthCode: {
                    authManager.getAuthCode(textPhoneNumber.phonePrefix(),
                                            textPhoneNumber.phoneNumber(),
                                            3)
                }
            }

            PasswordField {
                id: textPassword
                placeholderText: qsTr("New password")
                visible: verified
                KeyNavigation.tab: confirmPassword
                Layout.preferredWidth: 320
            }

            PasswordField {
                id: confirmPassword
                placeholderText: qsTr("Confirm password")
                visible: verified
                Layout.preferredWidth: 320
            }

            Label {
                id: labelPassword
                font.pixelSize: 12
                color: "#337EFF"
                text: qsTr("8~16 characters, supports letters and numbers")
                Layout.topMargin: -8
                Layout.leftMargin: 1
                visible: verified
            }
        }

        Rectangle {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: '#EBEDF0'
        }

        CustomButton {
            id: buttonResetPassword
            Layout.preferredWidth: 92
            Layout.preferredHeight: 36
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.alignment: Qt.AlignHCenter
            enabled: bindingFunction()
            highlighted: true
            text: qsTr("Next")
            font.pixelSize: 16
            onClicked: {
                if (verified) {
                    if (textPassword.text !== confirmPassword.text) {
                        message.warning(qsTr("The new passwords entered twice are not the same, please try again."))
                        textPassword.text = ""
                        confirmPassword.text = ""
                        return
                    }
                    authManager.resetPasswordFlag = true
                    authManager.resetPassword(textPhoneNumber.phonePrefix(),
                                              textPhoneNumber.phoneNumber(),
                                              confirmPassword.text)
                    buttonResetPassword.enabled = false
                } else {
                    authManager.verifyAuthCode(textPhoneNumber.phonePrefix(),
                                               textPhoneNumber.phoneNumber(),
                                               textCode.text,
                                               3)
                }
            }
        }
    }

    Connections {
        target: authManager
        onVerifiedAuthCode: {
            verified = true
            btnPopupClose.title = qsTr("Change Password")
            buttonResetPassword.text = qsTr("Finished")
        }
        onResetPasswordSig: {
            if (popupForgotPassword.visible) {
                message.info(qsTr("Password changed successfully."))
                authManager.logout(false)
            }
        }
        onError: {
            authManager.resetPasswordFlag = false
            buttonResetPassword.enabled = Qt.binding(bindingFunction)
        }
    }
}
