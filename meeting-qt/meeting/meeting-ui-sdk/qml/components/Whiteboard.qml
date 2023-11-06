import QtQuick
import QtQuick.Window 2.2
// import QtQuick.Controls 1.4
import QtWebChannel 1.0
import QtWebEngine 1.1
import WhiteboardJsBridge 1.0

Item {
    id: root

    property alias jsBridge: jsBridge
    property string whiteboardAccount: ""
    property string whiteboardDefaultDownloadPath: ""
    property bool whiteboardIsJoinFinished: false
    property bool whiteboardIsOpen: false
    property string whiteboardUrl: ""

    signal createWriteBoardFailed(string errorMessage)
    signal createWriteBoardSucceed
    signal downloadFinished(string path)
    signal joinWriteBoardFailed(int errorCode, string errorMessage)
    signal joinWriteBoardSucceed
    signal leaveWriteBoard
    signal webLoadFinished
    signal whiteboardGetAuth
    signal whiteboardLoadFinished
    signal writeBoardError(string errorMessage)

    function sendMessageToWeb(jsonParam) {
        console.log("jsonParam", jsonParam);
        webview.runJavaScript(jsonParam);
    }

    visible: true

    WhiteboardJsBridge {
        id: jsBridge
        WebChannel.id: "qJsBridge"

        onWebCreateWriteBoardFailed: {
            whiteboardIsJoinFinished = false;
            createWriteBoardFailed(errorMessage);
        }
        onWebCreateWriteBoardSucceed: {
            createWriteBoardSucceed();
        }
        onWebError: {
            writeBoardError(errorMessage);
        }
        onWebGetAuth: {
            whiteboardGetAuth();
        }
        onWebJoinWriteBoardFailed: {
            whiteboardIsJoinFinished = false;
            joinWriteBoardFailed(errorCode, errorMessage);
        }
        onWebJoinWriteBoardSucceed: {
            whiteboardIsJoinFinished = true;
            joinWriteBoardSucceed();
        }
        onWebJsError: {
            writeBoardError(errorMessage);
        }
        onWebLeaveWriteBoard: {
            whiteboardIsOpen = false;
            whiteboardIsJoinFinished = false;
            leaveWriteBoard();
        }
        onWebPageLoadFinished: {
            webLoadFinished();
        }
    }
    WebEngineView {
        id: webview
        property var downloads
        anchors.fill: parent
        url: whiteboardUrl
        webChannel: channel
        onLoadingChanged:{}
        profile.onDownloadFinished: {
            // https://doc.qt.io/qt-6/qwebenginedownloadrequest.html
            const localFile = `${download.downloadDirectory}/${download.downloadFileName}`;
            console.info("Download finished: ", localFile);
            downloadFinished(localFile);
        }
        profile.onDownloadRequested: {
            download.accept();
        }
    }
    WebChannel {
        id: channel
        registeredObjects: [jsBridge]
    }
}
