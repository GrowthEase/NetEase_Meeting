import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.14
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12
import NetEase.Meeting.GlobalChatManager 1.0
import "../components"

Rectangle {

    property alias  listmodel   : listmodel
    property alias  msglistView : msglistView
    property int    maxMsgUintWidth: 302
    property int    avatarSize: 24
    property alias  verScrollBar :verScrollBar
    property var    listBarPos: 0.0
    id:root
    width: parent.width
    height:parent.height
    color: "#00000000"

    Component.onCompleted: {
        listmodel.clear()
        msglistView.positionViewAtEnd()
    }

    Component.onDestruction:{
        listmodel.clear()
    }


    function getShowedNickname(name){ 
           return name.substring(0,1)
    }

    onHeightChanged: {
        verScrollBar.setPosition(listBarPos)
    }

    Rectangle {
        id:listviewlayout
        anchors.fill: parent
        ListView {
            property bool   msgTimeTip  : false
            property bool   appendByme  : false
            id: msglistView
            anchors.fill: parent
            anchors.bottomMargin: 15
            header: Rectangle { height: 20 }
            clip: true
            displayMarginBeginning: 40
            displayMarginEnd: 40
            verticalLayoutDirection:ListView.TopToBottom
            spacing: 6


            model: ListModel{
                id:listmodel
            }
            delegate:Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin:5
                anchors.leftMargin:5
                height: msgUintLayout.height

                ColumnLayout {
                    id:msgUintLayout
                    width: parent.width
                    spacing:0
                    Rectangle {
                        id:timetiper
                        Layout.fillWidth: true
                        Layout.preferredWidth: msgTip.width + 24
                        Layout.preferredHeight: msgTip.implicitHeight + 8
                        Layout.alignment: Qt.Horizontal
                        visible: msgType === "time"
                        color: "transparent"
                        border.color:"transparent"
                        Label {
                            id: msgTip
                            color: "#999999"
                            text: qsTr(content)
                            font.pixelSize:12
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Rectangle {
                        id: userInfo
                        Layout.preferredHeight: 32
                        Layout.fillWidth: true

                        Avatar {
                            id: avatarLeft
                            height: avatarSize
                            width: height
                            visible: !sentByMe && msgType === "msg"
                            nickname: qsTr(getShowedNickname(model.nickName))
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            id: leftnickname
                            visible: avatarLeft.visible
                            font.pixelSize:12
                            color: "#333333"
                            anchors.top: parent.top
                            anchors.topMargin: 4
                            anchors.leftMargin: 5
                            anchors.left: avatarLeft.right
                            text: qsTr(model.nickName)
                        }

                        Label {
                            id: rightnickname
                            visible: sentByMe
                            font.pixelSize: 12
                            color: "#333333"
                            anchors.top: parent.top
                            anchors.topMargin: 4
                            text: qsTr(model.nickName)
                            anchors.right: avatarRight.left
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                        }

                        Avatar {
                            id: avatarRight
                            height: avatarSize
                            width: height
                            visible: sentByMe
                            nickname: qsTr(getShowedNickname(model.nickName))
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: sentByMe ? parent.right : undefined
                        }
                    }

                    Rectangle {
                        id: messageInfo
                        visible: msgType === "msg"
                        Layout.leftMargin: avatarLeft.width + 3
                        Layout.rightMargin: avatarRight.width + 3
                        Layout.topMargin: -7
                        Layout.preferredWidth:Math.min(messageText.implicitWidth+24, maxMsgUintWidth)
                        Layout.preferredHeight: messageText.implicitHeight+20
                        Layout.alignment: sentByMe ? Qt.AlignRight : Qt.AlignLeft
                        radius: 8
                        color: sentByMe ? "#CCE1FF" : "#F2F3F5"
                        border.color: "white"

                        Label {
                            id: messageText
                            text: content
                            font.pixelSize:14
                            anchors.fill: parent
                            anchors.margins: 12
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10
                            wrapMode: Label.Wrap
                            color: "#222222"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: {
                                if (mouse.button == Qt.RightButton) { // right menu
                                    const point = parent.mapToItem(messageInfo, mouse.x, mouse.y)
                                    var delta = messageInfo.width - point.x + 30;

                                    if(delta > contentMenu.width){
                                        contentMenu.x = mouse.x
                                        contentMenu.y = mouse.y
                                    }
                                    else{
                                        contentMenu.x = mouse.x - contentMenu.width
                                        contentMenu.y = mouse.y
                                    }




                                    contentMenu.open()
                                }
                            }

                        }


                        Menu {
                            id: contentMenu
                            implicitWidth:80
                            implicitHeight: 50

                            Connections{
                                target: msglistView
                                onCountChanged: {
                                   if(contentMenu.visible === true){
                                       contentMenu.close()
                                   }
                                }
                            }

                            MenuItem{
                                id: copyItem
                                width: parent.width
                                height: visible ? 32 : 0

                                Label {
                                    id: copyText
                                    text: qsTr("Copy")
                                    color: copyItem.hovered ? "#337EFF" : "#333333"
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: copyItem.hovered ? "#F2F3F5" : "#FFFFFF"
                                }
                                onClicked: {
                                       clipboard.setText(messageText.text)
                                }
                                Accessible.role: Accessible.Button
                                Accessible.name: copyText.text
                                Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
                            }
                        }
                    }
                }

            }

            ScrollBar.vertical: ScrollBar {
                id: verScrollBar
                width: 5
                onPositionChanged: {
                    listBarPos = verScrollBar.position
                    if (msglistView.atYEnd){
                        listBarPos = 1.0
                    }

                }
            }

        }
    }

}







