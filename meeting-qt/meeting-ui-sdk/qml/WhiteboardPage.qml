import QtQuick 2.15
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12

import NetEase.Meeting.MembersModel 1.0
import NetEase.Meeting.GlobalChatManager 1.0

import "components"
import "share"
import "utils/dialogManager.js" as DialogManager
import "utils/meetingHelpers.js" as MeetingHelpers

Rectangle {
    id: root
    anchors.fill: parent

    Component.onCompleted: {
        viewMode = MainPanel.ViewMode.WhiteboardMode
        membersManager.isWhiteboardView = true
        currentPage = 1
        pageSize = 4
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: parent.height - footerBar.height

        spacing: 0

        Rectangle {
            Layout.preferredHeight: 98
            Layout.fillWidth: true
            color: "#18181F"
            visible: secondaryView.count > 0

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignVCenter
                    color: "#00000000"
                    CustomToolButton {
                        id: buttonPrePage
                        anchors.fill: parent
                        direction: CustomToolButton.Direction.Left
                        onClicked: membersManager.getMembersPaging(pageSize, currentPage - 1)
                    }
                }

                ListView {
                    id: secondaryView
                    Layout.preferredWidth: count * 160 + ((count - 1) * 4)
                    Layout.preferredHeight: 90
                    Layout.topMargin: 4
                    spacing: 4
                    orientation: Qt.Horizontal
                    model: ListModel {
                        id: memberModel
                    }
                    delegate: VideoDelegate {
                        width: 160
                        height: 90
                        accountId: model.accountId
                        nickname: model.nickname
                        videoStatus: model.videoStatus
                        audioStatus: model.audioStatus
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignVCenter
                    color: "#00000000"
                    CustomToolButton {
                        id: buttonNextPage
                        anchors.fill: parent
                        direction: CustomToolButton.Direction.Right
                        onClicked: membersManager.getMembersPaging(pageSize, currentPage + 1)
                    }
                }
            }
        }

        Rectangle {
            id: whiteboardContainer
            Layout.fillHeight: parent.height - 68
            Layout.fillWidth: true
            color: "#000000"

            Whiteboard {
                id: idWhiteboard
                anchors.fill: parent
                whiteboardUrl: whiteboardManager.getWhiteboardUrl()
                onWebLoadFinished: {
                    sendMessageToWeb(whiteboardManager.getWhiteboardLoginMessage())
                    membersManager.getMembersPaging(pageSize, currentPage)
                }

                onLeaveWriteBoard: {
                    console.log("onLeaveWriteBoard")
                    if(membersManager.isGalleryView){
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/GalleryPage.qml'))
                    }else{
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'))
                    }

                    //白板内部错误自动退出
                    if(whiteboardManager.whiteboardSharing
                            && (whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId)){
                        whiteboardManager.closeWhiteboard(authManager.authAccountId)
                    }
                }

                onJoinWriteBoardSucceed: {
                    var enable = whiteboardManager.whiteboardDrawEnable || idWhiteboard.whiteboardAccount === idWhiteboard.whiteboardOwnerAccount
                    sendMessageToWeb(whiteboardManager.getWhiteboardDrawPrivilegeMessage())
                    sendMessageToWeb(whiteboardManager.getWhiteboardToolConfigMessage())
                }

                onJoinWriteBoardFailed: {
                    console.log("onJoinWriteBoardFailed errorCode: " +  errorCode + " errorMessage: " + errorMessage)

                    if(errorCode == 403) {
                        //白板内部错误自动退出
                        if(whiteboardManager.whiteboardSharing
                                && (whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId)){
                            whiteboardManager.closeWhiteboard(authManager.authAccountId)
                        }

                        toast.show(qsTr("Whiteboard permission has not yet been activated, please contact sales for activation"))
                    }
                }

                onDownloadFinished: {
                    console.log("onDownloadFinished", path)
                    whiteboardManager.showFileInFolder(path)
                }
            }

        }
    }

    Connections {
        target: footerBar
        onShowMembers: {
            membersBar.show = !membersBar.show
        }
        onShowChatroom: {
            chatBar.show = !chatBar.show
        }
    }

    Connections {
        target: whiteboardManager

        onWhiteboardSharingChanged: {
            if(!whiteboardManager.whiteboardSharing){
                if(idWhiteboard.whiteboardIsJoinFinished){
                    idWhiteboard.sendMessageToWeb(whiteboardManager.getWhiteboardLogoutMessage())
                }else{
                    if(membersManager.isGalleryView){
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/GalleryPage.qml'))
                    }else{
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'))
                    }
                }
            }
        }

        onWhiteboardDrawEnableChanged: {
            if(sharedAccountId === authManager.authAccountId){
                idWhiteboard.sendMessageToWeb(whiteboardManager.getWhiteboardDrawPrivilegeMessage())
                idWhiteboard.sendMessageToWeb(whiteboardManager.getWhiteboardToolConfigMessage())

                if(enable){
                    toast.show(qsTr("You have been granted permission to interact with the whiteboard"))
                }else{
                    toast.show(qsTr("You have been reclaimed the whiteboard interactive permission"))
                }

            }
        }
    }

    Connections {
        target: membersManager
        onMembersChanged: {
            console.info('Members info changed:', JSON.stringify(primaryMember),
                         JSON.stringify(secondaryMembers),
                         realPage,
                         realCount)
            if (currentPage !== realPage) {
                memberModel.clear()
                currentPage = realPage;
            }

            MeetingHelpers.arrangeWhiteboardMemberLayout(secondaryMembers, realPage, realCount, memberModel)
            buttonNextPage.visible = currentPage * pageSize < realCount
            buttonPrePage.visible = currentPage > 1
        }


        onNicknameChanged:{
            var rowCount = memberModel.count;
            var found = false
            for( var i = 0;i < rowCount;i++ ) {
                var model = memberModel.get(i);
                if(model.accountId === accountId){
                    model.nickname = nickname
                    found = true
                }
            }

        }
    }

    Connections {
        target: chatBar
        onVisibleChanged: {
            if (visible){
                GlobalChatManager.noNewMsgNotity()
            }
        }
    }
}
