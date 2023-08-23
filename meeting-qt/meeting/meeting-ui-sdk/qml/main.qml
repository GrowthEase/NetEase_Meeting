import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import Clipboard 1.0
import Qt.labs.settings 1.0
import NetEase.Meeting.MessageModel 1.0
import "components"
import "chattingroom"
import "share"

ApplicationWindow {
    id: mainWindow

    readonly property int defaultSiderbarWidth: 315
    readonly property int defaultWindowHieght: 703
    readonly property int defaultWindowWidth: 1185
    property int displayWidth: Screen.width
    property var messageBubbleFullWindow: undefined
    property var sharedWnd: undefined
    property bool sidebarShown: false
    readonly property int taskbarHeight: Qt.platform.os === 'windows' ? 60 : 0

    signal beforeClose

    function adjustWindow() {
        if (Qt.platform.os === 'windows') {
            return false;
        }
        let adjusted = false;
        if (mainWindow.height > Screen.height - taskbarHeight) {
            if (Screen.height < mainWindow.minimumHeight) {
                mainWindow.height = mainWindow.minimumHeight;
                mainWindow.width = mainWindow.minimumWidth;
            } else {
                mainWindow.height = Screen.height - taskbarHeight;
                mainWindow.width = mainWindow.height * 16 / 9;
            }
            adjusted = true;
        }
        if (mainWindow.width > Screen.width) {
            if (Screen.width < mainWindow.minimumWidth) {
                mainWindow.height = mainWindow.minimumHeight;
                mainWindow.width = mainWindow.minimumWidth;
            } else {
                mainWindow.width = Screen.width - 20;
                mainWindow.height = mainWindow.width * 9 / 16;
            }
            adjusted = true;
        }
        centerInScreen();
        return adjusted;
    }
    function centerInScreen() {
        if (Qt.platform.os === 'windows') {
            return false;
        }
        mainWindow.x = (Screen.width - mainWindow.width) / 2 + Screen.virtualX;
        mainWindow.y = (Screen.height - mainWindow.height) / 2 + Screen.virtualY;
    }
    function raiseOnTop() {
        // mainWindow.width = defaultWindowWidth
        // mainWindow.height = defaultWindowHieght
        adjustWindow();
        mainWindow.showNormal();
        mainWindow.flags = Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint;
        mainWindow.flags = Qt.Window | Qt.FramelessWindowHint;
        if (Qt.platform.os === 'windows') {
            mainWindow.x = (Screen.width - mainWindow.width) / 2 + Screen.virtualX;
            mainWindow.y = (Screen.height - mainWindow.height - taskbarHeight) / 2 + Screen.virtualY;
        }
    }

    color: 'transparent'
    flags: Qt.Window | Qt.FramelessWindowHint
    height: defaultWindowHieght
    minimumHeight: 640
    minimumWidth: sidebarShown ? 960 + defaultSiderbarWidth : 960
    title: Qt.application.displayName
    visible: false
    width: defaultWindowWidth

    Component.onCompleted: {
        pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/MainPanel.qml'));
        x: (Screen.width - width) / 2 + Screen.virtualX;
        y: (Screen.height - height - taskbarHeight) / 2 + Screen.virtualY;
    }
    onDisplayWidthChanged: {
        if (mainWindow.visibility === Window.FullScreen || mainWindow.visibility === Window.Maximized) {
            mainWindow.showNormal();
        }
    }

    Shortcut {
        sequence: "ESC"

        onActivated: {
            if (mainWindow.visibility === Window.FullScreen)
                mainWindow.showNormal();
        }
    }

    Settings {
        id: globalSettings

        property string localLastConferenceId
        property string localLastMeetingPassword
        property string localLastMeetingTopic
        property string localLastMeetingUniqueId
        property string localLastMeetingshortId
        property string localLastNickname
        property string localLastSipId
    }
    Clipboard {
        id: clipboard
    }
    ToastManager {
        id: toast
    }
    Members {
        id: membersWindow
        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(membersWindow) : shareManager.removeExcludeShareWindow(membersWindow);
            }
        }
    }
    MessageModel {
        id: chatMessageModel
    }
    ChattingroomWindow {
        id: chattingWindow
        messageModel: chatMessageModel

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(chattingWindow) : shareManager.removeExcludeShareWindow(chattingWindow);
            }
        }
    }
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 0

        Caption {
            id: caption
            Layout.fillWidth: true
            Layout.preferredHeight: 36
        }
        Loader {
            id: pageLoader
            Layout.fillHeight: true
            Layout.fillWidth: true

            onLoaded: {
                console.log("pageLoader:", source);
            }
        }
    }
    DragDelegate {
        anchors.fill: parent
        enabled: Window.window.visibility !== Window.FullScreen && Window.window.visibility !== Window.Maximized
    }
    Connections {
        target: mainWindow

        onClosing: {
            beforeClose();
            close.accepted = false;
        }
    }
}
