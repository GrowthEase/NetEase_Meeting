import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.14
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material 2.12
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.MessageModel 1.0
import QtQuick.Dialogs
import QtCore

import "../components"

Window {
    id: chatWindow
    visible: false
    width: Qt.platform.os === 'windows' ? 417 : 417 + 20
    height: Qt.platform.os === 'windows' ? 520 : 520 + 20
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    color: "#00000000"
    title: qsTr("chatroom")
    flags: Qt.Window | Qt.FramelessWindowHint
    Material.theme: Material.Light

    signal newMsgNotity(int msgCount, string sender, string text)

    property point movePos: "0,0"
    property var msgtimeGap: undefined
    property var nickname: meetingManager.nickname
    property int msgCount: 0
    property MessageModel messageModel

    ToastManager {
        id: operator
    }

    Component.onCompleted: {
        messageModel.clearMessage()
        chatroom.msglistView.positionViewAtEnd()
        msgtimeGap = new Date()
    }

    Component.onDestruction: {
        messageModel.clearMessage()
        nickname = ""
        close()
    }

    onVisibleChanged: {
        if (visible) {
            newMsgNotity(0, "", "")
            msgCount = 0
            chatroom.msglistView.positionViewAtEnd()
            if (msgTipBtn.visible) {
                msgTipBtn.visible = false
            }

            GlobalChatManager.noNewMsgNotity()
        } else {
            messageField.focus = false
        }
    }

    onVisibilityChanged: {
        if (mainWindow.visibility === Window.Minimized) {
            messageField.focus = false
        }
    }

    Rectangle {
        id: chatbusyContainer
        anchors.fill: parent
        color: "#99000000"
        z: 999
        visible: false
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
            font.pixelSize: 16
            color: "#FFFFFF"
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
            width: parent.width
            title: qsTr('Chatroom')
            onCloseClicked: Window.window.hide()
        }
        ColumnLayout {
            anchors.top: idDragArea.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0
            Rectangle {
                id: listviewlayout
                Layout.preferredWidth: parent.width
                Layout.fillHeight: true

                ChatListView {
                    id: chatroom
                    messageModel: chatWindow.messageModel
                    Rectangle {
                        id: msgTipBtn
                        width: 74
                        height: 28
                        anchors.right: chatroom.right
                        anchors.bottom: chatroom.bottom
                        anchors.rightMargin: 15
                        anchors.bottomMargin: 5
                        visible: false
                        color: "#337EFF"
                        radius: 14
                        z: 2

                        RowLayout {
                            spacing: 4
                            anchors.centerIn: parent
                            Image {
                                id: btnImage
                                Layout.preferredWidth: 8
                                Layout.preferredHeight: 8
                                mipmap: true
                                source: "qrc:/qml/images/chatroom/messagedown.png"
                            }

                            Label {
                                id: tipLabel
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 17
                                font.pixelSize: 12
                                color: "#FFFFFF"
                                text: qsTr("new message")
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                chatroom.msglistView.positionViewAtEnd()
                                msgTipBtn.visible = false
                                chatroom.msglistView.msgTimeTip = false
                                newMsgNotity(0, "", "")
                            }
                        }
                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: "#EBEDF0"
            }
            Rectangle {
                id: input
                Layout.preferredHeight: 78
                Layout.preferredWidth: parent.width
                Flickable {
                    id: scView
                    width: !idTool.visible ? parent.width : parent.width - idTool.width -14
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: parent.left
                    ScrollBar.vertical: ScrollBar {
                        width: 5
                        onActiveChanged: {
                            if (active) {
                                messageField.focus = false
                            }
                        }
                    }

                    TextArea.flickable: TextArea {
                        id: messageField
                        font.pixelSize: 14
                        selectByMouse: true
                        selectByKeyboard: true
                        leftPadding: 12
                        rightPadding: leftPadding
                        topPadding: 8
                        bottomPadding: topPadding
                        placeholderText: qsTr("Input a message and press Enter to send it...")
                        wrapMode: TextArea.Wrap
                        textFormat: Text.AutoText
                        property int inputImageHeight: 38

                        background: Rectangle {
                            //hide the focus line
                            height: 0
                        }

                        DropArea {
                            id: dropArea
                            anchors.fill: parent
                            onEntered: (drop)=>{
                                           // console.log("drop hasUrls:", drop.hasUrls)
                                           if (drop.hasUrls) {
                                               // console.log("drop hasUrls[0]:", drop.urls[0])
                                               let path = drop.urls[0].toLowerCase()
                                               if (path.endsWith(".jpg") || path.endsWith(".png") || path.endsWith(".jpeg") || path.endsWith(".bmp")) {
                                               } else {
                                                   drop.accepted = false
                                                   return false
                                               }
                                           }
                                       }
                            onDropped: (drop)=>{
                                           // console.log("drop hasUrls:", drop.hasUrls)
                                           if (drop.hasUrls) {
                                               // console.log("drop hasUrls[0]:", drop.urls[0])
                                               let url = drop.urls[0]
                                               if (Qt.platform.os === 'osx') {
                                                   url = url.substring(0, 5) + '/' + url.substring(5);
                                               }
                                               messageField.insert(messageField.cursorPosition, "<img src=\"" + url + "\"" + ", height=" + messageField.inputImageHeight + "\>")
                                           }
                                       }
                        }

                        Keys.onReturnPressed: {
                            sendMsg()
                        }

                        Keys.onEnterPressed: {
                            sendMsg()
                        }

                        Keys.onPressed: {
                            if (event.modifiers & Qt.ControlModifier) {
                                if (event.key === Qt.Key_C) {
                                    // Ctrl+C复制
                                    // console.log("ctrl + c", messageField.text, "CCCCCCCC", messageField.getFormattedText(0, messageField.length))
                                    if (messageField.text !== messageField.getFormattedText(0, messageField.length)) {
                                        event.accepted = true
                                    }
                                } else if(event.key === Qt.Key_V) {
                                    // Ctrl+V复制
                                    let imagePath = clipboard.getImage()
                                    // console.log("ctrl + v, getImage:", imagePath)
                                    if (imagePath.length !== 0) {
                                        let path = imagePath.toLowerCase()
                                        if (path.endsWith(".jpg") || path.endsWith(".png") || path.endsWith(".jpeg") || path.endsWith(".bmp")) {
                                            if (Qt.platform.os === 'osx' && path.startsWith("file:///")) {
                                                imagePath = imagePath.substring(0, 5) + '/' + imagePath.substring(5);
                                            }
                                            imagePath = imagePath.replace("file:///", "")
                                            messageField.insert(messageField.cursorPosition, "<img src=\"" + "file:///" + imagePath + "\"" + ", height=" + messageField.inputImageHeight + "\>")
                                        }
                                        event.accepted = true
                                    } else {
                                        // console.log("ctrl + v, getText:", clipboard.getText())
                                        if (clipboard.getText().length === 0)
                                            event.accepted = true
                                    }
                                }
                            }
                        }

                        function sendMsg() {
                            if (messageField.text.match(/^[ ]*$/) || messageField.getText(0, messageField.length) === '') {
                                operator.show(qsTr("can not send empty message"), 1500)
                                return;
                            }

                            let startFragment = "<!--StartFragment-->"
                            let endFragment = "<!--EndFragment-->"
                            let startImage = "<img src=\"file:///"
                            let endImage = "\" height=\"" + messageField.inputImageHeight + "\" />"

                            let formattedText = messageField.getFormattedText(0, messageField.length)
                            // console.log("formattedText:", formattedText)
                            let path = formattedText.toLowerCase()
                            if (formattedText.toLowerCase().includes(startFragment.toLowerCase()) && !messageField.text.toLowerCase().includes(startFragment.toLowerCase())) {
                                formattedText = formattedText.substr(formattedText.indexOf(startFragment)).replace(startFragment, "")
                                formattedText = formattedText.substring(0, formattedText.indexOf(endFragment))
                                // console.log("formattedTextEx:", formattedText)
                                while(0 !== formattedText.length) {
                                    let pos = formattedText.indexOf(startImage)
                                    let pos2 = formattedText.indexOf(endImage)
                                    if (-1 === pos || -1 === pos2) {
                                        // console.log("text:", formattedText)
                                        chatManager.sendMsg(1, formattedText);
                                        break
                                    }
                                    if (0 !== pos) {
                                        // console.log("text:", formattedText.substring(0, pos))
                                        chatManager.sendMsg(1, formattedText.substring(0, pos))
                                    }
                                    // console.log("image:", formattedText.substring(pos + startImage.length, pos2))
                                    chatManager.sendMsg(3, formattedText.substring(pos + startImage.length, pos2))
                                    formattedText = formattedText.substr(pos2).replace(endImage, "")
                                }
                            } else {
                                chatManager.sendTextMsg(messageField.text)
                            }
                            messageField.text = ""
                            messageField.focus = true
                            atEndTimer.restart()
                        }
                        Timer {
                            id: atEndTimer
                            interval: 100
                            repeat: false
                            onTriggered: {
                                chatroom.msglistView.positionViewAtEnd()
                            }
                        }
                    }
                }

                Rectangle {
                    id: idTool
                    visible: meetingManager.enableImageMessage || meetingManager.enableFileMessage
                    width: (meetingManager.enableImageMessage && meetingManager.enableFileMessage) ? 48 : 16
                    height: 16
                    anchors.top: scView.top
                    anchors.topMargin: 13
                    anchors.right: parent.right
                    anchors.rightMargin: 14

                    RowLayout {
                        spacing: 16
                        anchors.fill: parent
                        Layout.alignment: Qt.AlignRight
                        ImageButton {
                            id: idImage
                            visible: meetingManager.enableImageMessage
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 16
                            normalImage: 'qrc:/qml/images/chatroom/image.svg'
                            hoveredImage: 'qrc:/qml/images/chatroom/image.svg'
                            pushedImage: 'qrc:/qml/images/chatroom/image.svg'
                            onClicked: {
                                fileDialog.selectedFile = 'file:///'
                                fileDialog.imageType = true
                                fileDialog.open()
                            }
                        }

                        ImageButton {
                            id: idFile
                            visible: meetingManager.enableFileMessage
                            Layout.preferredWidth: 17
                            Layout.preferredHeight: 16
                            normalImage: 'qrc:/qml/images/chatroom/file.svg'
                            hoveredImage: 'qrc:/qml/images/chatroom/file.svg'
                            pushedImage: 'qrc:/qml/images/chatroom/file.svg'
                            onClicked: {
                                fileDialog.selectedFile = 'file:///'
                                fileDialog.imageType = false
                                fileDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        samples: 16
        source: mainLayout
        color: "#3217171A"
        visible: Qt.platform.os === 'windows'
        Behavior on radius {
            PropertyAnimation {
                duration: 100
            }
        }
    }

    FileDialog {
        id: fileDialog
        property bool imageType: true
        nameFilters: imageType ? ["%1 (*.jpg *.png *.jpeg *.bmp)".arg(qsTr("image files"))] :
                     ["%1 (*.mp3 *.aac *.wav *.pcm *.mp4 *.flv *.mov *.doc *.docx *.xls *.xlsx *.ppt *.pptx *.jpg *.png *.jpeg *.bmp *.pdf *.zip *.7z *.biz *.tar *.txt *.apk *.ipa)".arg(qsTr("all files")),
                      "%1 (*.mp3 *.aac *.wav *.pcm)".arg(qsTr("audio files")),
                      "%1 (*.mp4 *.flv *.mov)".arg(qsTr("video files")),
                      "%1 (*.doc *.docx *.xls *.xlsx *.ppt *.pptx)".arg(qsTr("office files")),
                      "%1 (*.jpg *.png *.jpeg *.bmp)".arg(qsTr("image files")),
                      "%1 (*.zip *.7z *.biz *.tar)".arg(qsTr("zip files")),
                      "%1 (*.pdf)".arg(qsTr("pdf files")),
                      "%1 (*.txt)".arg(qsTr("text files")),
                      "%1 (*.apk *.ipa)".arg(qsTr("pack files"))]
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        onAccepted: {
            console.log("sendFileMsg image: " + fileDialog.selectedFile)
            var filePath = ""
            filePath = fileDialog.selectedFile.toString()
            if(Qt.platform.os === 'osx') {
                filePath = filePath.replace("file://", "")
            } else {
                filePath = filePath.replace("file:///", "")
            }

            if(imageType) {
                chatManager.sendFileMsg(3, filePath)
            } else {
                chatManager.sendFileMsg(2, filePath)
            }
        }
    }

    Connections {
        target: GlobalChatManager
        onNoNewMsgNotity: {
            msgCount = 0
            chatroom.msglistView.positionViewAtEnd()
            if (msgTipBtn.visible) {
                msgTipBtn.visible = false
            }
        }
    }

    Connections {
        target: chatManager
        onMsgTipSignal: {
            ++msgCount
            if (chatWindow.visible){
                if (chatroom.msglistView.atYEnd) {
                    chatroom.msglistView.positionViewAtEnd()
                    newMsgNotity(0, "", "")
                    GlobalChatManager.noNewMsgNotity()
                    msgCount = 0
                } else {
                    newMsgNotity(msgCount, nickname, tip)
                    if (!msgTipBtn.visible) {
                        msgTipBtn.visible = true
                    }
                }
            } else{
                newMsgNotity(msgCount, nickname, tip)
            }
        }

        onMsgSendSignal: {
            chatroom.msglistView.positionViewAtEnd()
            // messageField.text = ""
            GlobalChatManager.noNewMsgNotity()
        }

        onError: {
            operator.show(text)
        }

        onDisconnect: {
            switch (code) {
            case 0:
                if (chatbusyContainer.visible) {
                    chatbusyContainer.visible = false
                    messageField.focus = true
                }
                break
            case 1:
            case 2:
                if (!chatbusyContainer.visible) {
                    busyNotice.text = qsTr("Connection is disconnect!")
                    chatbusyContainer.visible = true
                    messageField.focus = false
                }
                break
            default:
                if (chatbusyContainer.visible) {
                    chatbusyContainer.visible = false
                    messageField.focus = true
                    break
                }
            }
        }
    }

    Connections {
        target: meetingManager
        onMeetingStatusChanged: {
            switch (status) {
            case MeetingStatus.MEETING_CONNECTED:
                nickname = meetingManager.nickname
                chatbusyContainer.visible = false
                break
            case MeetingStatus.MEETING_CONNECT_FAILED:
            case MeetingStatus.MEETING_RECONNECT_FAILED:
                messageModel.clearMessage()
                messageField.text = ""
                nickname = ""
                if (!chatbusyContainer.visible) {
                    busyNotice.text = qsTr("Connection is disconnect!")
                    chatbusyContainer.visible = true
                    messageField.focus = false
                }
                break
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_MULTI_SPOT_LOGIN:
            case MeetingStatus.MEETING_ENDED:
                messageField.text = ""
                messageModel.clearMessage()
                nickname = ""
                chatbusyContainer.visible = false
                GlobalChatManager.noNewMsgNotity()
                close()
                break
            default:

                break
            }
        }
    }

    Connections {
        target: chatroom.verScrollBar
        onPositionChanged: {
            if (chatWindow.visible) {
                if (chatroom.msglistView.atYEnd) {
                    chatroom.msglistView.positionViewAtEnd()
                    newMsgNotity(0, "", "")
                    GlobalChatManager.noNewMsgNotity()
                }
            }
        }
    }

    function getShowedNickname(name) {
        if (name.length <= 2) {
            return name
        } else if (name.length >= 3) {
            return name.substring(name.length - 2)
        }
        return name
    }
}
