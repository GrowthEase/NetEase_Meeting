import QtQuick

LoginWithPasswordForm {
    Component.onCompleted: {
    }

    header.onPrevious: {
        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/LoginWithCode.qml"))
    }

    textPhoneNumber.onTextChanged: {

    }

    textPhoneNumber.onAccepted: {
        buttonSubmit.clicked()
    }

    textPassword.onAccepted: {
        buttonSubmit.clicked()
    }

    buttonForgotPwd.onClicked: {
        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/ChangePasswordPage.qml"))
    }

    buttonLoginWithCode.onClicked: {
        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/LoginWithCode.qml")/*, { rememberPhoneNumber: textPhoneNumber.text }*/)
    }

    buttonSubmit.onClicked: {
        statisticsManager.meetingStatistics("login", "we_meeting", { value: 1 })
        /*
        authManager.loginToHttp(1,   // login type password
                                textPhoneNumber.phonePrefix(),
                                textPhoneNumber.phoneNumber(),
                                textPassword.text)
        */

        meetingManager.loginByPassword(authManager.aPaasAppKey, textPhoneNumber.text, textPassword.text);
        buttonSubmit.enabled = false
    }

    Connections {
        target: authManager
        onLoggedIn: {
            console.info('Login to application server successful.')
        }
        onError: {
            buttonSubmit.enabled = Qt.binding(function() {
                return textPhoneNumber.length > 0 && textPassword.length > 0
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
                buttonSubmit.enabled = Qt.binding(function() { return textPhoneNumber.length > 0 && textPassword.length > 0 })
            }
        }
    }
}
