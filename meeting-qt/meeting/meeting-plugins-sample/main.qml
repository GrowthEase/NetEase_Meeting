import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import NEMeeting 1.0

Window {
    id: mainWindow

    property bool afterSignOut: false

    width: 800
    height: 495
    visible: true
    title: qsTr("Hello World")

    Component.onCompleted: {
        nemEngine.initialize()
    }

    Component.onDestruction: {
        nemEngine.unInitialize()
    }

    Dialog {
        id: dialogToast
        x: (parent.width - width) / 2
        y: 120
        onClosed: {
            closeTimer.stop()
        }
        Label {
            id: message
        }
        Timer {
            id: closeTimer
            interval: 2000
            repeat: false
            onTriggered: {
                dialogToast.close()
            }
        }
        function showDialog(text) {
            message.text = text
            dialogToast.open()
            closeTimer.restart()
        }
    }

    NEMEngine {
        id: nemEngine
        appKey: "092dcd94d2c2566d1ed66061891cdf15"
    }

    NEMAuthenticate {
        id: auth
        engine: nemEngine
        account: NEMAccount {
            id: nemAccount
        }
        onStateChanged: {
            console.info('Auth status changed: ', state)
            switch (state) {
            case NEMAuthenticate.AUTH_STATE_LOGGEDIN:
                loader.setSource(Qt.resolvedUrl('qrc:/qml/FrontPage.qml'))
                break;
            case NEMAuthenticate.AUTH_STATE_IDLE:
                loader.setSource(Qt.resolvedUrl('qrc:/qml/LoginPage.qml'))
                if (afterSignOut) {
                    mainWindow.close()
                }
                break;
            }
        }
        onErrorMessageChanged: {
            if (errorMessage !== '') {
                dialogToast.showDialog(`${errorMessage} ${errorCode}`)
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        source: Qt.resolvedUrl('qrc:/qml/LoginPage.qml');
    }

    Connections {
        target: mainWindow
        onClosing: {
            if (auth.state === NEMAuthenticate.AUTH_STATE_LOGGEDIN) {
                close.accepted = false
                afterSignOut = true
                auth.signOut()
            }
        }
    }

    function prettyId(id) {
        return `${id.substring(0, 3)}-${id.substring(3, 6)}-${id.substring(6)}`
    }
}
