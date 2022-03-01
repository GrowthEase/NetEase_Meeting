import QtQuick 2.15

RegisterPageForm {
    Component.onCompleted: {

    }

    header.onPrevious: {
        if (verified) {
            verified = false
            header.title = qsTr("Register new account")
            buttonSubmit.text = qsTr("Next")
        } else {
            pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/HomePage.qml"))
        }
    }

    textNickname.validator: RegExpValidator {
        regExp: /\w{1,20}/
    }

    textNickname.onTextChanged: {
        const currentText = textNickname.text

        if (currentText === lastNicknameText)
            return

        if (getByteLength(currentText) > 20) {
            textNickname.text = lastNicknameText
        } else {
            lastNicknameText = currentText
        }
    }

    labelNickname.text: qsTr("10 Chinese characters, or 20 alphanumeric characters")

    textNickname.onFocusChanged: {
        labelNickname.visible = textNickname.focus
        labelPassword.visible = textPassword.focus
    }

    textPassword.onFocusChanged: {
        labelPassword.visible = textPassword.focus
        labelNickname.visible = textNickname.focus
    }

    privacyCheck.onToggled: {
        isAgreePrivacyPolicy = privacyCheck.checked
        console.log("isAgreePrivacyPolicy  register", isAgreePrivacyPolicy)
    }

    buttonSubmit.onClicked: {
        if(!privacyCheck.checked) {
            toast.show(qsTr('Please check to agree to the privacy policy and user service agreement'))
            return
        }

        submit()
    }

    textCode.onGetAuthCode: {
        authManager.getAuthCode(textPhoneNumber.phonePrefix(),
                                textPhoneNumber.phoneNumber(),
                                2)
    }

    privacyPolicy.onClicked: {
        Qt.openUrlExternally("https://reg.163.com/agreement_mobile_ysbh_wap.shtml?v=20171127")
    }

    userServiceAgreement.onClicked: {
        Qt.openUrlExternally("https://netease.im/meeting/clauses?serviceType=0")
    }

    function submit() {
        if (verified) {
            statisticsManager.meetingStatistics("register", "we_meeting")
            authManager.registerNEAccount(textPhoneNumber.phoneNumber(),
                                          textCode.text,
                                          textNickname.text,
                                          textPassword.text)
            buttonSubmit.enabled = false
        } else {
            authManager.verifyAuthCode(textPhoneNumber.phonePrefix(),
                                       textPhoneNumber.phoneNumber(),
                                       textCode.text,
                                       2)
        }
    }

    Connections {
        target: authManager
        onRegisteredAccount: {
            toast.show(qsTr('Register a new account successfully'))
            meetingManager.login(authManager.aPaasAppKey, authManager.aPaasAccountId, authManager.aPaasAccountToken)
        }
        onVerifiedAuthCode: {
            verified = true
            textNickname.focus = true
            buttonSubmit.text = qsTr('Register')
        }
        onError: {
            buttonSubmit.enabled = Qt.binding(function () {
                return verified
                        ? textNickname.length > 0 && textPassword.length >= 8 && textPassword.length <= 16
                        : textPhoneNumber.length === 13 && textCode.length > 0
            })
            message.error(result.msg)
        }
    }

    Connections {
        target: meetingManager
        onLoginSignal: {
            if (errorCode === 0) {
                updateEnable = true
                pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/FrontPage.qml"))
            } else {
                message.error(errorMessage)
            }
        }
    }
}
