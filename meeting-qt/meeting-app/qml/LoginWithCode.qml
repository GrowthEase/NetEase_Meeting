import QtQuick 2.15

LoginWithCodeForm {
    Component.onCompleted: {
    }

    header.onPrevious: {
        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/HomePage.qml"))
    }

    buttonLoginWithPassword.onClicked: {
        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/LoginWithPassword.qml"), { rememberPhoneNumber: textPhoneNumber.text })
    }

    textCode.onGetAuthCode: {
        authManager.getAuthCode(textPhoneNumber.phonePrefix(),
                                textPhoneNumber.phoneNumber(),
                                1)
    }

    textPhoneNumber.onAccepted: {
        buttonSubmit.clicked()
    }

    textCode.onAccepted: {
        buttonSubmit.clicked()
    }

    buttonSubmit.onClicked: {
        buttonSubmit.enabled = false
        statisticsManager.meetingStatistics("login", "we_meeting", { value: 0 })
        /*
        authManager.loginToHttp(2, textPhoneNumber.phonePrefix(),
                                textPhoneNumber.phoneNumber(),
                                textCode.text)
        */
        authManager.loginByVerifyCode(textPhoneNumber.phoneNumber(), textCode.text)
    }

    Connections {
        target: authManager
        onLoggedIn: {
            console.info('Login to application server successful.')
            meetingManager.login(authManager.aPaasAppKey, authManager.aPaasAccountId, authManager.aPaasAccountToken)
        }
        onError: {
            buttonSubmit.enabled = Qt.binding(function() {
                return textPhoneNumber.length === 13 && textCode.length > 0
            })
            switch (resCode) {
            case 300:
            case 1006:
                message.error(result.msg)
                break;
            default:
                message.error(result.msg)
            }
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
