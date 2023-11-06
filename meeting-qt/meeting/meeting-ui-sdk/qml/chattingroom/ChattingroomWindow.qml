import QtQuick
import QtQuick.Window 2.12
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.MessageModel 1.0
import QtQuick.Dialogs
import QtCore
import "../components"

Window {
    id: chatWindow

    property MessageModel messageModel
    property point movePos: "0,0"
    property int msgCount: 0
    property var msgtimeGap: undefined
    property var nickname: meetingManager.nickname

    signal newMsgNotity(int msgCount, string sender, string text)

    function getShowedNickname(name) {
        if (name.length <= 2) {
            return name;
        } else if (name.length >= 3) {
            return name.substring(name.length - 2);
        }
        return name;
    }

    Material.theme: Material.Light
    color: "#00000000"
    flags: Qt.Window | Qt.FramelessWindowHint
    height: Qt.platform.os === 'windows' ? 520 : 520 + 20
    title: qsTr("chatroom")
    visible: false
    width: Qt.platform.os === 'windows' ? 417 : 417 + 20
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2

    Component.onCompleted: {
        messageModel.clearMessage();
        chatroom.msglistView.positionViewAtEnd();
        msgtimeGap = new Date();
    }
    Component.onDestruction: {
        messageModel.clearMessage();
        nickname = "";
        close();
    }
    onVisibilityChanged: {
        if (mainWindow.visibility === Window.Minimized) {
            messageField.focus = false;
        }
    }
    onVisibleChanged: {
        if (visible) {
            newMsgNotity(0, "", "");
            msgCount = 0;
            chatroom.msglistView.positionViewAtEnd();
            if (msgTipBtn.visible) {
                msgTipBtn.visible = false;
            }
            GlobalChatManager.noNewMsgNotity();
        } else {
            messageField.focus = false;
        }
    }

    ToastManager {
        id: operator

    }
    Rectangle {
        id: chatbusyContainer

        anchors.fill: parent
        color: "#99000000"
        visible: false
        z: 999

        BusyIndicator {
            id: busyIndicator

            anchors.centerIn: parent
            running: true
        }
        Label {
            id: busyNotice

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: busyIndicator.bottom
            anchors.topMargin: 8
            color: "#FFFFFF"
            font.pixelSize: 16
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }
    }
    Rectangle {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: Qt.platform.os === 'windows' ? 10 : 0
        radius: Qt.platform.os === 'windows' ? 0 : 10

        DragArea {
            id: idDragArea

            height: 52
            title: qsTr('Chatroom')
            width: parent.width

            onCloseClicked: Window.window.hide()
        }
        ColumnLayout {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: idDragArea.bottom
            spacing: 0

            Rectangle {
                id: listviewlayout

                Layout.fillHeight: true
                Layout.preferredWidth: parent.width

                ChatListView {
                    id: chatroom

                    messageModel: chatWindow.messageModel

                    Rectangle {
                        id: msgTipBtn

                        anchors.bottom: chatroom.bottom
                        anchors.bottomMargin: 5
                        anchors.right: chatroom.right
                        anchors.rightMargin: 15
                        color: "#337EFF"
                        height: 28
                        radius: 14
                        visible: false
                        width: 74
                        z: 2

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Image {
                                id: btnImage

                                Layout.preferredHeight: 8
                                Layout.preferredWidth: 8
                                mipmap: true
                                source: "qrc:/qml/images/chatroom/messagedown.png"
                            }
                            Label {
                                id: tipLabel

                                Layout.preferredHeight: 17
                                Layout.preferredWidth: 36
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                text: qsTr("new message")
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                chatroom.msglistView.positionViewAtEnd();
                                msgTipBtn.visible = false;
                                chatroom.msglistView.msgTimeTip = false;
                                newMsgNotity(0, "", "");
                            }
                        }
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#EBEDF0"
            }
            Rectangle {
                id: input

                Layout.preferredHeight: 78
                Layout.preferredWidth: parent.width

                Flickable {
                    id: scView

                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: parent.height
                    width: !idTool.visible ? parent.width : parent.width - idTool.width - 14

                    ScrollBar.vertical: ScrollBar {
                        width: 5

                        onActiveChanged: {
                            if (active) {
                                messageField.focus = false;
                            }
                        }
                    }
                    TextArea.flickable: TextArea {
                        id: messageField

                        property int inputImageHeight: 38

                        function sendMsg() {
                            if (messageField.text.match(/^[ ]*$/) || messageField.getText(0, messageField.length) === '') {
                                operator.show(qsTr("can not send empty message"), 1500);
                                return;
                            }
                            let startFragment = "<!--StartFragment-->";
                            let endFragment = "<!--EndFragment-->";
                            let startImage = "<img src=\"file:///";
                            let endImage = "\" height=\"" + messageField.inputImageHeight + "\" />";
                            let formattedText = messageField.getFormattedText(0, messageField.length);
                            // console.log("formattedText:", formattedText)
                            let path = formattedText.toLowerCase();
                            if (formattedText.toLowerCase().includes(startFragment.toLowerCase()) && !messageField.text.toLowerCase().includes(startFragment.toLowerCase())) {
                                formattedText = formattedText.substr(formattedText.indexOf(startFragment)).replace(startFragment, "");
                                formattedText = formattedText.substring(0, formattedText.indexOf(endFragment));
                                // console.log("formattedTextEx:", formattedText)
                                while (0 !== formattedText.length) {
                                    let pos = formattedText.indexOf(startImage);
                                    let pos2 = formattedText.indexOf(endImage);
                                    if (-1 === pos || -1 === pos2) {
                                        // console.log("text:", formattedText)
                                        chatManager.sendMsg(1, formattedText);
                                        break;
                                    }
                                    if (0 !== pos) {
                                        // console.log("text:", formattedText.substring(0, pos))
                                        chatManager.sendMsg(1, formattedText.substring(0, pos));
                                    }
                                    // console.log("image:", formattedText.substring(pos + startImage.length, pos2))
                                    chatManager.sendMsg(3, formattedText.substring(pos + startImage.length, pos2));
                                    formattedText = formattedText.substr(pos2).replace(endImage, "");
                                }
                            } else {
                                chatManager.sendTextMsg(messageField.text);
                            }
                            messageField.text = "";
                            messageField.focus = true;
                            atEndTimer.restart();
                        }

                        bottomPadding: topPadding
                        font.pixelSize: 14
                        topInset: 14
                        leftPadding: 8
                        placeholderText: text ? "" : qsTr("Input a message and press Enter to send it...")
                        rightPadding: leftPadding
                        selectByKeyboard: true
                        selectByMouse: true
                        textFormat: Text.AutoText
                        wrapMode: TextArea.Wrap

                        background: Rectangle {
                            height: messageField.height
                        }

                        Keys.onEnterPressed: {
                            sendMsg();
                        }
                        Keys.onPressed: {
                            if (event.modifiers & Qt.ControlModifier) {
                                if (event.key === Qt.Key_C) {
                                    // Ctrl+C复制
                                    // console.log("ctrl + c", messageField.text, "CCCCCCCC", messageField.getFormattedText(0, messageField.length))
                                    if (messageField.text !== messageField.getFormattedText(0, messageField.length)) {
                                        event.accepted = true;
                                    }
                                } else if (event.key === Qt.Key_V) {
                                    // Ctrl+V复制
                                    let imagePath = clipboard.getImage();
                                    // console.log("ctrl + v, getImage:", imagePath)
                                    if (imagePath.length !== 0) {
                                        let path = imagePath.toLowerCase();
                                        if (path.endsWith(".jpg") || path.endsWith(".png") || path.endsWith(".jpeg") || path.endsWith(".bmp")) {
                                            if (Qt.platform.os === 'osx' && path.startsWith("file:///")) {
                                                imagePath = imagePath.substring(0, 5) + '/' + imagePath.substring(5);
                                            }
                                            imagePath = imagePath.replace("file:///", "");
                                            messageField.insert(messageField.cursorPosition, "<img src=\"" + "file:///" + imagePath + "\"" + ", height=" + messageField.inputImageHeight + "\>");
                                        }
                                        event.accepted = true;
                                    } else {
                                        // console.log("ctrl + v, getText:", clipboard.getText())
                                        if (clipboard.getText().length === 0)
                                            event.accepted = true;
                                    }
                                }
                            }
                        }
                        Keys.onReturnPressed: {
                            sendMsg();
                        }

                        DropArea {
                            id: dropArea

                            anchors.fill: parent

                            onDropped: drop => {
                                // console.log("drop hasUrls:", drop.hasUrls)
                                if (drop.hasUrls) {
                                    // console.log("drop hasUrls[0]:", drop.urls[0])
                                    let url = drop.urls[0];
                                    if (Qt.platform.os === 'osx') {
                                        url = url.substring(0, 5) + '/' + url.substring(5);
                                    }
                                    messageField.insert(messageField.cursorPosition, "<img src=\"" + url + "\"" + ", height=" + messageField.inputImageHeight + "\>");
                                }
                            }
                            onEntered: drop => {
                                // console.log("drop hasUrls:", drop.hasUrls)
                                if (drop.hasUrls) {
                                    // console.log("drop hasUrls[0]:", drop.urls[0])
                                    let path = drop.urls[0].toLowerCase();
                                    if (path.endsWith(".jpg") || path.endsWith(".png") || path.endsWith(".jpeg") || path.endsWith(".bmp")) {
                                    } else {
                                        drop.accepted = false;
                                        return false;
                                    }
                                }
                            }
                        }
                        Timer {
                            id: atEndTimer

                            interval: 100
                            repeat: false

                            onTriggered: {
                                chatroom.msglistView.positionViewAtEnd();
                            }
                        }
                    }
                }
                Rectangle {
                    id: idTool

                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.top: scView.top
                    anchors.topMargin: 13
                    height: 16
                    visible: meetingManager.enableImageMessage || meetingManager.enableFileMessage
                    width: (meetingManager.enableImageMessage && meetingManager.enableFileMessage) ? 48 : 16

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        anchors.fill: parent
                        spacing: 16

                        ImageButton {
                            id: idImage

                            Layout.preferredHeight: 16
                            Layout.preferredWidth: 18
                            hoveredImage: 'qrc:/qml/images/chatroom/image.svg'
                            normalImage: 'qrc:/qml/images/chatroom/image.svg'
                            pushedImage: 'qrc:/qml/images/chatroom/image.svg'
                            visible: meetingManager.enableImageMessage

                            onClicked: {
                                fileDialog.selectedFile = 'file:///';
                                fileDialog.imageType = true;
                                fileDialog.open();
                            }
                        }
                        ImageButton {
                            id: idFile

                            Layout.preferredHeight: 16
                            Layout.preferredWidth: 17
                            hoveredImage: 'qrc:/qml/images/chatroom/file.svg'
                            normalImage: 'qrc:/qml/images/chatroom/file.svg'
                            pushedImage: 'qrc:/qml/images/chatroom/file.svg'
                            visible: meetingManager.enableFileMessage

                            onClicked: {
                                fileDialog.selectedFile = 'file:///';
                                fileDialog.imageType = false;
                                fileDialog.open();
                            }
                        }
                    }
                }
            }
        }
    }
    DropShadow {
        anchors.fill: mainLayout
        color: "#3217171A"
        horizontalOffset: 0
        samples: 16
        source: mainLayout
        verticalOffset: 0
        visible: Qt.platform.os === 'windows'

        Behavior on radius  {
            PropertyAnimation {
                duration: 100
            }
        }
    }
    FileDialog {
        id: fileDialog

        property bool imageType: true

        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        nameFilters: imageType ? ["%1 (*.jpg *.png *.jpeg *.bmp)".arg(qsTr("image files"))] : ["%1 (*.mp3 *.aac *.wav *.pcm *.mp4 *.flv *.mov *.doc *.docx *.xls *.xlsx *.ppt *.pptx *.jpg *.png *.jpeg *.bmp *.pdf *.zip *.7z *.biz *.tar *.txt *.apk *.ipa)".arg(qsTr("all files")), "%1 (*.mp3 *.aac *.wav *.pcm)".arg(qsTr("audio files")), "%1 (*.mp4 *.flv *.mov)".arg(qsTr("video files")), "%1 (*.doc *.docx *.xls *.xlsx *.ppt *.pptx)".arg(qsTr("office files")), "%1 (*.jpg *.png *.jpeg *.bmp)".arg(qsTr("image files")), "%1 (*.zip *.7z *.biz *.tar)".arg(qsTr("zip files")), "%1 (*.pdf)".arg(qsTr("pdf files")), "%1 (*.txt)".arg(qsTr("text files")), "%1 (*.apk *.ipa)".arg(qsTr("pack files"))]

        onAccepted: {
            console.log("sendFileMsg image: " + fileDialog.selectedFile);
            var filePath = "";
            filePath = fileDialog.selectedFile.toString();
            if (Qt.platform.os === 'osx') {
                filePath = filePath.replace("file://", "");
            } else {
                filePath = filePath.replace("file:///", "");
            }
            if (imageType) {
                chatManager.sendFileMsg(3, filePath);
            } else {
                chatManager.sendFileMsg(2, filePath);
            }
        }
    }
    Connections {
        target: GlobalChatManager

        onNoNewMsgNotity: {
            msgCount = 0;
            chatroom.msglistView.positionViewAtEnd();
            if (msgTipBtn.visible) {
                msgTipBtn.visible = false;
            }
        }
    }
    Connections {
        target: chatManager

        onDisconnect: {
            switch (code) {
            case 0:
                if (chatbusyContainer.visible) {
                    chatbusyContainer.visible = false;
                    messageField.focus = true;
                }
                break;
            case 1:
            case 2:
                if (!chatbusyContainer.visible) {
                    busyNotice.text = qsTr("Connection is disconnect!");
                    chatbusyContainer.visible = true;
                    messageField.focus = false;
                }
                break;
            default:
                if (chatbusyContainer.visible) {
                    chatbusyContainer.visible = false;
                    messageField.focus = true;
                    break;
                }
            }
        }
        onError: {
            operator.show(text);
        }
        onMsgSendSignal: {
            chatroom.msglistView.positionViewAtEnd();
            // messageField.text = ""
            GlobalChatManager.noNewMsgNotity();
        }
        onMsgTipSignal: {
            ++msgCount;
            if (chatWindow.visible) {
                if (chatroom.msglistView.atYEnd) {
                    chatroom.msglistView.positionViewAtEnd();
                    newMsgNotity(0, "", "");
                    GlobalChatManager.noNewMsgNotity();
                    msgCount = 0;
                } else {
                    newMsgNotity(msgCount, nickname, tip);
                    if (!msgTipBtn.visible) {
                        msgTipBtn.visible = true;
                    }
                }
            } else {
                newMsgNotity(msgCount, nickname, tip);
            }
        }
    }
    Connections {
        target: meetingManager

        onMeetingStatusChanged: {
            switch (status) {
            case MeetingStatus.MEETING_CONNECTED:
                nickname = meetingManager.nickname;
                chatbusyContainer.visible = false;
                break;
            case MeetingStatus.MEETING_CONNECT_FAILED:
            case MeetingStatus.MEETING_RECONNECT_FAILED:
                messageModel.clearMessage();
                messageField.text = "";
                nickname = "";
                if (!chatbusyContainer.visible) {
                    busyNotice.text = qsTr("Connection is disconnect!");
                    chatbusyContainer.visible = true;
                    messageField.focus = false;
                }
                break;
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_MULTI_SPOT_LOGIN:
            case MeetingStatus.MEETING_ENDED:
                messageField.text = "";
                messageModel.clearMessage();
                nickname = "";
                chatbusyContainer.visible = false;
                GlobalChatManager.noNewMsgNotity();
                close();
                break;
            default:
                break;
            }
        }
    }
    Connections {
        target: chatroom.verScrollBar

        onPositionChanged: {
            if (chatWindow.visible) {
                if (chatroom.msglistView.atYEnd) {
                    chatroom.msglistView.positionViewAtEnd();
                    newMsgNotity(0, "", "");
                    GlobalChatManager.noNewMsgNotity();
                }
            }
        }
    }
}
