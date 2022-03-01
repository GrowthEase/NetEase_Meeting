import QtQuick 2.15
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtWebChannel 1.0
import QtWebEngine 1.1
import WhiteboardJsBridge 1.0

Item {
    id: root
    visible: true

    property string whiteboardUrl: ""
    property string whiteboardAccount: ""
    property bool whiteboardIsOpen: false
    property bool whiteboardIsJoinFinished: false
    property string whiteboardDefaultDownloadPath: ""

    signal webLoadFinished();
    signal whiteboardLoadFinished()
    signal createWriteBoardSucceed()
    signal createWriteBoardFailed(string errorMessage)
    signal joinWriteBoardSucceed()
    signal joinWriteBoardFailed(int errorCode, string errorMessage)
    signal leaveWriteBoard()
    signal writeBoardError(string errorMessage)
    signal loginIMSucceed()
    signal loginIMFailed(int errorCode, string errorMessage)
    signal downloadFinished(string path)

    WhiteboardJsBridge {
        id: jsBridge
        WebChannel.id: "qJsBridge"

        onWebPageLoadFinished: {
            webLoadFinished()
        }

        onWebCreateWriteBoardSucceed: {
            createWriteBoardSucceed()
        }

        onWebCreateWriteBoardFailed: {
            whiteboardIsJoinFinished = false
            createWriteBoardFailed(errorMessage)
        }

        onWebJoinWriteBoardSucceed: {
            whiteboardIsJoinFinished = true
            joinWriteBoardSucceed()
        }

        onWebJoinWriteBoardFailed: {
            whiteboardIsJoinFinished = false
            joinWriteBoardFailed(errorCode, errorMessage)
        }

        onWebLeaveWriteBoard: {
            whiteboardIsOpen = false
            whiteboardIsJoinFinished = false
            leaveWriteBoard()
        }

        onWebError: {
            writeBoardError(errorMessage)
        }

        onWebLoginIMSucceed: {
            loginIMSucceed()
        }

        onWebLoginIMFailed: {
            loginIMFailed(errorCode, errorMessage)
        }

        onWebJsError: {
            writeBoardError(errorMessage)
        }
    }

    WebEngineView {
        id: webview
        anchors.fill: parent
        url: whiteboardUrl
        webChannel: channel

        property var downloads;
        profile.onDownloadRequested: {
            console.log("onDownloadRequested")
            var arr = download.path.split('/');
            var name = arr[arr.length-1];
            download.path = whiteboardDefaultDownloadPath + "/" + name;
            webview.downloads = download;
            console.log("download->path=", download.path);
            download.accept();
        }

        profile.onDownloadFinished: {
            console.log("onDownloadFinished")
            downloadFinished(download.path)
        }
    }

    WebChannel {
        id: channel
        registeredObjects: [jsBridge]
    }

    function sendMessageToWeb(jsonParam){
        console.log("jsonParam", jsonParam)
        webview.runJavaScript(jsonParam)
    }
}
