import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.14
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12
import NetEase.Meeting.MeetingStatus 1.0

import "../components"

Window {
    id:chatWindow
    visible: false
    width: Qt.platform.os === 'windows' ? 417 : 417 + 20
    height: Qt.platform.os === 'windows' ? 520 : 520 + 20
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    color: "#00000000"
    title:qsTr("chatroom")
    flags:  Qt.Window | Qt.FramelessWindowHint
    Material.theme: Material.Light

    signal newMsgNotity(int msgCount, string sender, string text)

    property point  movePos    : "0,0"
    property var    msgtimeGap : undefined
    property var    nickname   : meetingManager.nickname
    property int    msgCount   : 0

    ToastManager{
        id:operator
    }

    Component.onCompleted: {
        chatroom.listmodel.clear()
        chatroom.msglistView.positionViewAtEnd()
        msgtimeGap = new Date()
    }

    Component.onDestruction:{
        chatroom.listmodel.clear()
        nickname = ""
        close()
    }

    onVisibleChanged: {
        if (visible){
            newMsgNotity(0,"","")
            msgCount = 0
            chatroom.msglistView.positionViewAtEnd()
            if (msgTipBtn.visible){
                msgTipBtn.visible = false
            }

            GlobalChatManager.noNewMsgNotity()
        }
        else{
            messageField.focus = false
        }

    }

    onVisibilityChanged:{
        if (mainWindow.visibility === Window.Minimized) {
            messageField.focus = false;
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
                id:listviewlayout
                Layout.preferredWidth: parent.width
                Layout.fillHeight: true

                ChatListView {
                    id:chatroom
                    Rectangle {
                        id:msgTipBtn
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

                        RowLayout{
                            spacing: 4
                            anchors.centerIn: parent
                            Image {
                                id: btnImage
                                Layout.preferredWidth:8
                                Layout.preferredHeight:8
                                source: "qrc:/qml/images/chatroom/messagedown.png"
                            }

                            Label {
                                id:tipLabel
                                Layout.preferredWidth:36
                                Layout.preferredHeight:17
                                font.pixelSize: 12
                                color: "#FFFFFF"
                                text: qsTr("new message")

                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                chatroom.msglistView.positionViewAtEnd();
                                msgTipBtn.visible = false
                                chatroom.msglistView.msgTimeTip = false;
                                newMsgNotity(0,"","")
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
            Rectangle{
                id: input
                Layout.preferredHeight: 78
                Layout.preferredWidth: parent.width
                Flickable  {
                    id: scView
                    anchors.fill: parent
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
                        font.pixelSize:14
                        selectByMouse:true
                        selectByKeyboard:true
                        leftPadding: 12
                        rightPadding: leftPadding
                        topPadding: 8
                        bottomPadding:topPadding
                        placeholderText: qsTr("Input a message and press Enter to send it...")
                        wrapMode: TextArea.Wrap
                        background: Rectangle {
                            //hide the focus line
                            height: 0
                        }

                        Keys.onReturnPressed: {
                            if(text.match(/^[ ]*$/)){
                                operator.show(qsTr("can not send empty message"), 1500)
                                return;
                            }

                            //addToList("msg", messageField.text, nickname, true)
                            chatManager.sendIMTextMsg(messageField.text,"share")
                            messageField.text = "";
                            messageField.focus = true;
                        }

                        Keys.onEnterPressed: {
                            if(text.match(/^[ ]*$/)){
                                operator.show(qsTr("can not send empty message"), 1500)
                                return;
                            }
                            //addToList("msg", messageField.text, nickname, true)
                            chatManager.sendIMTextMsg(messageField.text,"share")
                            messageField.text = "";
                            messageField.focus = true;
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
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    Connections {
        target:GlobalChatManager
        onNoNewMsgNotity:{
            msgCount = 0
            chatroom.msglistView.positionViewAtEnd()
            if (msgTipBtn.visible){
                msgTipBtn.visible = false
            }
        }
    }

    Connections {
        target: chatManager
        onRecvMsgSiganl:{
            if(status != 200){
                operator.show(qsTr("send message fail"))
                return
            }
            else{
                if( msg.sendFlag === "share"  || msg.sendFlag === "main")
                    addToList(msg.msgType, msg.content, msg.nickName, true)
                else
                    addToList(msg.msgType, msg.content, msg.nickName, msg.sendByme)
            }
        }

        onError : {

        }
        onDisconnect:{
            switch(code) {
            case 0:
                if(chatbusyContainer.visible){
                    chatbusyContainer.visible = false
                    messageField.focus = true
                }
                break;
            case 1:
            case 2:
                if(!chatbusyContainer.visible){
                    busyNotice.text = qsTr("Connection is disconnect!")
                    chatbusyContainer.visible = true;
                    messageField.focus = false
                }
                break;
            default:
                if(chatbusyContainer.visible){
                    chatbusyContainer.visible = false
                    messageField.focus = true
                    break;
                }
            }

        }
    }

    Connections {
        target:meetingManager
        onMeetingStatusChanged: {
            switch (status) {
            case MeetingStatus.MEETING_CONNECTED:
                nickname = meetingManager.nickname
                break
            case MeetingStatus.MEETING_CONNECT_FAILED:
            case MeetingStatus.MEETING_RECONNECT_FAILED:
                chatroom.listmodel.clear()
                messageField.text = "";
                nickname = ""
                if(!chatbusyContainer.visible){
                    busyNotice.text = qsTr("Connection is disconnect!")
                    chatbusyContainer.visible = true;
                    messageField.focus = false
                }
                break
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_MULTI_SPOT_LOGIN:
            case MeetingStatus.MEETING_ENDED:
                messageField.text = "";
                chatroom.listmodel.clear()
                nickname = ""
                chatbusyContainer.visible = false
                GlobalChatManager.noNewMsgNotity()
                close()
                break

            default:

                break;
            }
        }
    }

    Connections {
        target: chatroom.verScrollBar
        onPositionChanged: {
            if(shareManager.shareAccountId === authManager.authAccountId && chatWindow.visible === true){
                if (chatroom.msglistView.atYEnd){
                    chatroom.msglistView.positionViewAtEnd()
                    newMsgNotity(0,"","")
                    GlobalChatManager.noNewMsgNotity()

                }
            }
        }
    }

    function addToList(type, text, nickName, me) {
        if(text.length <= 0 || text.match(/^[ ]*$/))
        {
            return;
        }
        if( me === false && type === "msg"){
            ++msgCount;
        }

        var current = new Date().getTime()
        var startTime = chatWindow.msgtimeGap.getTime()

        var gap = (current-startTime)
        var oneday = parseInt(gap/1000/3600/24)
        //update time
        chatWindow.msgtimeGap = new Date()


        //in one day  insert time
        if (oneday === 0){

            if (gap/1000 >= 300 && chatroom.listmodel.count >= 1){
                //append one timestamp
                chatroom.msglistView.msgTimeTip = true
                chatroom.msglistView.model.append({"msgType":"time","content": Qt.formatDateTime(new Date(), "hh:mm"), "sentByMe": false,"nickName":""});
            }
            else{
                chatroom.msglistView.msgTimeTip = false
            }
        }
        else if(oneday === 1 && chatroom.listmodel.count >= 1){
            chatroom.msglistView.msgTimeTip = true
            chatroom.msglistView.model.append({"msgType":"time","content": Qt.formatDateTime(new Date(), "hh:mm"), "sentByMe": false,"nickName":""});
        }

        //console.log("msgtype = " + type)
        chatroom.msglistView.appendByme = me

        chatroom.msglistView.model.append({"msgType":type,"content": text, "sentByMe": me,"nickName":nickName});
        //var scollbar = Math.abs(verScrollBar.position + verScrollBar.visualSize)

        if(me) {
            chatroom.msglistView.positionViewAtEnd()
            GlobalChatManager.noNewMsgNotity()
        }
        else{
            if(chatWindow.visible){       
                if (chatroom.msglistView.atYEnd){
                    chatroom.msglistView.positionViewAtEnd()
                    newMsgNotity(0,"","")
                    GlobalChatManager.noNewMsgNotity()
                    msgCount = 0;
                }
                else{
                    newMsgNotity(msgCount,nickName,text)
                    if(!msgTipBtn.visible){
                        msgTipBtn.visible = true
                    }
                }

            }
            else{
                newMsgNotity(msgCount,nickName,text)
                //msglistView.positionViewAtEnd()
            }

        }


    }


    function getShowedNickname(name){
        if(name.length <= 2){
            return name
        }
        else if( name.length >=3 ) {
            return name.substring(name.length - 2)
        }
        return name;

    }
}






