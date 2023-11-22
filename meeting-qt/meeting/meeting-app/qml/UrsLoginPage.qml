import QtQuick
import QtQuick.Window 2.2
import QtQuick.Controls
import QtWebChannel 1.0
import QtWebEngine 1.10
import URSJsBridge 1.0

Item {
    id: root
    visible: true

    property bool isLoadSuccess: false

    onVisibleChanged: {
        if(visible && !isLoadSuccess) {
            webview.reload()
        }
    }

    Component.onCompleted: {
        isLoadSuccess = false
    }

    URSJsBridge {
        id: jsBridge
        WebChannel.id: "qJsBridge"

        onUrsLoginFinished: {
            var appkey = object.appKey
            var accountId = object.accountId
            var accountToken = object.accountToken
            var autoRegistered = object.autoRegistered
            console.log("onUrsLoginFinished autoRegistered:", autoRegistered)
            authManager.autoRegistered = autoRegistered
            backButton.visible = false
            meetingManager.login(appkey, accountId, accountToken)
        }

        onUrsRenderFinished: {
            console.log("onUrsRenderFinished")
            backButton.visible = true
            isLoadSuccess = true
            timer.stop()
        }

        onUrsLoginClicked: {
            backButton.visible = false
        }

        onUrsLoginError: {
            timer.stop()
            isLoadSuccess = false
            backButton.visible = false
            if(ursPage.visible) {
                message.error(qsTr("login error, please try later"))
                ursPage.visible = false
            }
        }
    }

    Timer {
        id: timer
        interval: configManager.isDebugModel() ? 30000 : 10000
        repeat: false
        running: false
        triggeredOnStart: false
        onTriggered: {
             console.log("onTriggered")
            if(visible && !isLoadSuccess) {
                if(ursPage.visible) {
                    message.error(qsTr("login timeout, please try later"))
                    ursPage.visible = false
                }
            }
        }
    }

    ToolButton {
        id: backButton
        visible: false
        anchors.left: parent.left
        anchors.leftMargin: 165
        anchors.top: parent.top
        anchors.topMargin: 10

        z: 9999

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qml/images/public/button/btn_left.svg"
        }

        onClicked: {
            ursPage.visible = false
            backButton.visible = false
            webview.reload()
        }
    }

    //add temp webview to fix Qt bug
    WebEngineView {
        id: tempView
        visible: false
    }

    WebEngineView {
        id: webview
        anchors.fill: parent
        url: "https://meeting-static.netease.im/website-urs/"
        webChannel: channel
        settings.showScrollBars: false
        settings.localStorageEnabled: false

        onNewViewRequested: {
            request.openIn(tempView)
            Qt.openUrlExternally(request.requestedUrl)
        }

        onLoadingChanged: {
            console.log("loadRequest.status", loadRequest.status)
            console.log("loadRequest.errorDomain", loadRequest.errorDomain)
            console.log("loadRequest.errorCode", loadRequest.errorCode, loadRequest.errorString)

            if(loadRequest.status == WebEngineView.LoadStartedStatus) {
                isLoadSuccess = false
                timer.start()
            } else if(loadRequest.status == WebEngineView.LoadSucceededStatus) {
                Qt.callLater(function () {
                    initURS()
                })
            } else {
                timer.stop()
                isLoadSuccess = false
                if(ursPage.visible) {
                    message.error(qsTr("login error, please try later"))
                    ursPage.visible = false
                }
            }
        }

        onContextMenuRequested: {
            request.accepted = true
        }
    }

    WebChannel {
        id: channel
        registeredObjects: [jsBridge]
    }

    Connections {
        target: meetingManager
        onLoginSignal: {
            if (errorCode === 0) {
                pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/FrontPage.qml"))
            } else {
                message.error(errorMessage)
                ursPage.visible = false
            }

            backButton.visible = false
            webview.reload()
        }
    }

    function initURS(){
        var strParam = JSON.stringify(jsBridge.getHttpRawHeader())
        var webScript = "WebJSBridge(" + strParam + ");"
        console.log("webScript", webScript)
        webview.runJavaScript(webScript)
    }
}
