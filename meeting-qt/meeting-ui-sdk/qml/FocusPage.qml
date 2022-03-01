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

    property var currentSpeaker: undefined
    property point mousePoint: "0,0"
    property var currentprimaryMember:undefined
    Component.onCompleted: {
        viewMode = MainPanel.ViewMode.FocusViewMode
        membersManager.isGalleryView = false
        membersManager.isWhiteboardView = false
        currentPage = 1
        pageSize = 4
        membersManager.getMembersPaging(pageSize, currentPage)
    }

    ColumnLayout {
        anchors.fill: parent
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
                        id: secondaryModel
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
            id: primaryContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#000000"

            RowLayout {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 8
                anchors.topMargin: 8
                spacing: 10
                z: 1
                visible: authManager.authAccountId === membersManager.hostAccountId && videoManager.focusAccountId.length !== 0 && shareManager.shareAccountId === 0
                Rectangle {
                    width: 90
                    height: 22
                    color: "#771E1E1E"
                    Label {
                        anchors.centerIn: parent
                        text: qsTr('Unset Focus')
                        font.pixelSize: 12
                        color: "#FFFFFF"
                    }
                    MouseArea {
                        id: unsetFocus
                        anchors.fill: parent
                        cursorShape: Qt.ClosedHandCursor
                        onClicked: membersManager.setAsFocus(videoManager.focusAccountId, false)
                    }
                }
            }
        }
    }

    Connections {
        target: footerBar
        onScreenShare: {
            if (hasRecordPermission) {
                shareSelector.open()
            } else {
                requestPermission.open()
            }
        }
        onSwitchView: {
            if (shareManager.shareAccountId.length !== 0) {
                toast.show(qsTr("Someone is screen sharing currently, you can't switch the view mode"))
                return
            }

            if (whiteboardManager.whiteboardSharing && whiteboardManager.whiteboardSharerAccountId.length !== 0) {
                toast.show(qsTr("Someone is whiteboard sharing currently, you can't switch the view mode"))
                return
            }

            if (secondaryModel.count !== 0)
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/GalleryPage.qml'))
        }
        onShowMembers: {
            membersBar.show = !membersBar.show
        }
        onShowChatroom: {
            chatBar.show = !chatBar.show
        }
    }

    Connections {
        target: membersManager
        onMembersChanged: {
            if (!visible || shareManager.shareAccountId === authManager.authAccountId) {
                return
            }
            console.info('Members info changed:', JSON.stringify(primaryMember),
                         JSON.stringify(secondaryMembers),
                         realPage,
                         realCount)
            if (currentPage !== realPage) {
                secondaryModel.clear()
                currentPage = realPage;
            }
            currentprimaryMember = primaryMember
            MeetingHelpers.arrangeSpeakerLayout(primaryMember, secondaryMembers, realPage, realCount, primaryContainer, secondaryModel)
            console.info('Secondary members count: ', secondaryModel.count)
            buttonNextPage.visible = currentPage * pageSize < realCount
            buttonPrePage.visible = currentPage > 1
        }
        onNicknameChanged:{
            var rowCount = secondaryModel.count;
            var found = false
            for( var i = 0;i < rowCount;i++ ) {
                var model = secondaryModel.get(i);
                if(model.accountId === accountId){
                    model.nickname = nickname
                    found = true
                }
            }

            if(found === false){
                if(accountId === currentSpeaker.accountId){
                    currentSpeaker.nickname = nickname;
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
