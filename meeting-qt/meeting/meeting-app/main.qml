import QtQuick
import QtQuick.Window 2.12
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.settings 1.0
import NetEase.Meeting.Clipboard 1.0

import "qml/components/"
import "qml/profile/"
import "qml/"

ApplicationWindow {
    id: mainWindow

    property int shadowSize: Qt.platform.os === 'windows' ? 10 : 0
    property int defaultWindowWidth: 681 + shadowSize * 2
    property int defaultWindowHeight: 471 + shadowSize * 2
    property int frontPageWidth: 920 + shadowSize * 2
    property int frontPageHeight: 550 + shadowSize * 2
    property bool isAgreePrivacyPolicy: false
    property bool updateEnable: false
    property int updateIgnore: 0
    property bool hasReadSafeTip: false

    visible: true
    minimumWidth: defaultWindowWidth
    minimumHeight: defaultWindowHeight
    width: defaultWindowWidth
    height: defaultWindowHeight
    title: Qt.application.displayName
    color: 'transparent'
    flags: Qt.Window | Qt.FramelessWindowHint

    Material.theme: Material.Light

    Component.onCompleted: {
        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/LoginWithAuthCode.qml"))
    }

    Component.onDestruction: {

    }

    onVisibilityChanged: {
        if (Window.Windowed == visibility && Qt.platform.os === 'osx') {
            mainWindow.flags = Qt.Window | Qt.FramelessWindowHint
        }
    }

    Shortcut {
        sequence: "Ctrl+V,Ctrl+S"
    }

    Settings {
        id: globalSettings
        property string localUserId
        property string localUserToken
        property string localPaasAppKey
        property string localPaasAccountId
        property string localPaasAccountToken
        property string sharedMeetingId
        property bool localMicStatusEx
        property bool localCameraStatusEx
    }

    MessageManager {
        id: message
    }

    ToastManager {
        id: toast
    }

    CustomWindowEx {
        id: exitWindow
    }

    Clipboard {
        id: clipboard
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: Qt.platform.os === 'windows' ? shadowSize : 0
        radius: Qt.platform.os === 'osx' ? 8 : 0

        Caption {
            id: caption
            height: 60
            width: parent.width
        }

//        UrsLoginPage {
//            id: ursPage
//            anchors.left: parent.left
//            anchors.top: caption.bottom
//            width: defaultWindowWidth - shadowSize * 2
//            anchors.bottom: parent.bottom
//            visible: false
//        }

        Loader {
            id: pageLoader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: caption.bottom
            anchors.bottom: parent.bottom
            //visible: !ursPage.visible
            onSourceChanged: {
                if (source == 'qrc:/qml/FrontPage.qml') {
                    mainWindow.width = frontPageWidth
                    mainWindow.height = frontPageHeight
                    mainWindow.x = (Screen.width - mainWindow.width) / 2 + Screen.virtualX
                    mainWindow.y = (Screen.height - mainWindow.height) / 2 + Screen.virtualY
                    caption.updateSize(frontPageWidth, frontPageHeight)
                } else {
                    mainWindow.width = defaultWindowWidth
                    mainWindow.height = defaultWindowHeight
                    caption.updateSize(defaultWindowWidth, defaultWindowHeight)
                }

                console.info("[PageLoader] Current page changed, new page:", source)
                raiseOnTop()
            }
        }

        Rectangle {
            id: busyContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: caption.bottom
            anchors.bottom: parent.bottom
            visible: false
            color: "#99000000"
            z: 999
            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
            }
            Label {
                id: busyContent
                anchors.top: busyIndicator.bottom
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#FFFFFF"
                text: qsTr('Network has been disconnected.')
                font.pixelSize: 16
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }

    Rectangle {
        color: "#00000000"
        anchors.fill: mainWindow.contentItem
        width: mainWindow.width
        height: mainWindow.height
        visible: windowModifyNickname.visible

        ModifyNicknameWindow {
            id: windowModifyNickname
            screen: mainWindow.screen
            visible: false
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: false
        }
    }

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        color: "#3217171A"
        spread: 0
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    Connections {
        target: authManager
        onLoginWithSSO: {
            if (pageLoader.source != 'qrc:/qml/FrontPage.qml' && mainWindow.visible) {
                //console.info('Login with SSO, argument:', ssoAppKey, ssoUser, ssoToken)
                raiseOnTop()
                pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoginWithAuthCode.qml'), { ssoAppKey: ssoAppKey, ssoUser: ssoUser, ssoToken: ssoToken })
            }
        }
    }

    Connections {
        target: meetingManager
        onInitializeSignal: {
            updateEnable = true
            if (errorCode !== 0) {
                message.error(errorMessage)
                pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/HomePage.qml"))
            }
        }
    }

    function prettyConferenceId(conferenceId) {
        if (conferenceId === undefined) {
            conferenceId = meetingManager.meetingId
        }
        return conferenceId.substring(0, 3) + "-" +
                conferenceId.substring(3, 6) + "-" +
                conferenceId.substring(6)
    }

    function raiseOnTop() {
        mainWindow.show()
        mainWindow.flags = Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        mainWindow.flags = Qt.Window | Qt.FramelessWindowHint
    }

    function macMinimized() {
        flags = Qt.Window | Qt.WindowFullscreenButtonHint | Qt.CustomizeWindowHint | Qt.WindowMinimizeButtonHint
        visibility = Window.Minimized
    }

    function getByteLength(string) {
        var len = 0
        for (var i = 0; i < string.length; i++) {
            var a = string.charAt(i);
            if (a.match(/[^\x00-\xff]/ig) !== null) {
                len += 2
            } else {
                len += 1
            }
        }
        return len
    }
}
