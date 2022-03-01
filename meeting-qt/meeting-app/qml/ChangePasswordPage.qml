import QtQuick 2.15

ChangePasswordPageForm {
    Component.onCompleted: {
    }

    textCode.onGetAuthCode: {
        authManager.getAuthCode(textPhoneNumber.phonePrefix(),
                                textPhoneNumber.phoneNumber(),
                                3)
    }

    header.onPrevious: {
        if (verified) {
            verified = false
            header.title = qsTr("Verify Phone Number")
            buttonSubmit.text = qsTr("Next")
        } else {
            pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/LoginWithPassword.qml"))
        }
    }

    buttonSubmit.onClicked: {
        if (verified) {
            if (textPassword.text !== textConfirmPassword.text) {
                message.warning(qsTr("The new passwords entered twice are not the same, please try again."))
                textPassword.text = ""
                textConfirmPassword.text = ""
                return
            }
            authManager.resetPasswordByVerifyCode(textPhoneNumber.phoneNumber(),
                                                  textCode.text,
                                                  textPassword.text)
            buttonSubmit.enabled = false
        } else {
            authManager.verifyAuthCode(textPhoneNumber.phonePrefix(),
                                       textPhoneNumber.phoneNumber(),
                                       textCode.text,
                                       3)
        }
    }

    Connections {
        target: authManager
        onVerifiedAuthCode: {
            verified = true
            header.title = qsTr("Change Password")
            buttonSubmit.text = qsTr("Finished")
        }
        onResetPasswordSig: {
            message.info(qsTr("Password changed successfully."))
            pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/LoginWithPassword.qml"))
        }
        onError: {
            buttonSubmit.enabled = Qt.binding(function() {
                return verified
                        ? (textPassword.text.length >= 8 && textPassword.text.length <= 16) &&
                          (textConfirmPassword.text.length >= 8 && textConfirmPassword.text.length <= 16)
                        : textPhoneNumber.length === 13 && textCode.length > 0
            })
            message.error(result.msg)
        }
    }
}
