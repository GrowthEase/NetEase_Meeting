import QtQuick 2.15
import Qt.labs.settings 1.0

LoginWithAuthCodeForm {
    Component.onCompleted: {
        if (ssoToken !== '' && ssoAppKey !== '') {
            meetingManager.loginBySSOToken(ssoAppKey, ssoToken)
            return
        }
        meetingManager.tryAutoLogin()
    }

    Settings {
        id: settings
    }

    Connections {
        target: authManager
        onLoggedIn: {
            console.info('Login to application server successful.')
            meetingManager.login(authManager.aPaasAppKey, authManager.aPaasAccountId, authManager.aPaasAccountToken)
        }
        onError: {
            message.error(result.msg)
            if (resCode !== 200) {
                pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/HomePage.qml"))
            }
        }
    }

    Connections {
        target: meetingManager
        onTryAutoLoginSignal: {
            updateEnable = true
            if (errorCode !== 0) {
                pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/HomePage.qml"))
            } else {
                pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/FrontPage.qml"))
            }
        }
        onLoginSignal: {
            if (errorCode === 0) {
                updateEnable = true
                pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/FrontPage.qml"))
            } else {
                message.error(errorMessage)
                pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/HomePage.qml"))
            }
        }
    }
}
