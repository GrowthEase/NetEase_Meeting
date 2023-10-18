import QtQuick 2.15
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import WhiteboardJsBridge 1.0
import NetEase.Meeting.MembersModel 1.0
import NetEase.Meeting.GlobalChatManager 1.0
import NetEase.Members.Status 1.0
import "components"
import "share"
import "utils/dialogManager.js" as DialogManager
import "utils/meetingHelpers.js" as MeetingHelpers

Rectangle {
    id: root
    anchors.fill: parent

    Component.onCompleted: {
        viewMode = MainPanel.ViewMode.WhiteboardMode;
        membersManager.isWhiteboardView = true;
        currentPage = 1;
        pageSize = 4;
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        height: parent.height - footerBar.height
        spacing: 0
        width: parent.width

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 98
            color: "#18181F"
            visible: secondaryView.count > 0

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32
                    color: "#00000000"

                    CustomToolButton {
                        id: buttonPrePage
                        anchors.fill: parent
                        direction: CustomToolButton.Direction.Left

                        onClicked: membersManager.getMembersPaging(pageSize, currentPage - 1, MembersStatus.VIEW_MODE_WHITEBOARD)
                    }
                }
                ListView {
                    id: secondaryView
                    Layout.preferredHeight: 90
                    Layout.preferredWidth: count * 160 + ((count - 1) * 4)
                    Layout.topMargin: 4
                    orientation: Qt.Horizontal
                    spacing: 4

                    delegate: VideoDelegate {
                        accountId: model.accountId
                        audioStatus: model.audioStatus
                        createdAt: model.createdAt
                        height: 90
                        highQuality: authManager.authAccountId === model.accountId ? false : SettingsManager.remoteVideoResolution
                        nickname: model.nickname
                        videoStatus: model.videoStatus
                        width: 160
                    }
                    model: ListModel {
                        id: memberModel
                    }
                }
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32
                    color: "#00000000"

                    CustomToolButton {
                        id: buttonNextPage
                        anchors.fill: parent
                        direction: CustomToolButton.Direction.Right

                        onClicked: membersManager.getMembersPaging(pageSize, currentPage + 1, MembersStatus.VIEW_MODE_WHITEBOARD)
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
                whiteboardDefaultDownloadPath: whiteboardManager.getDefaultDownloadPath()
                whiteboardUrl: whiteboardManager.getWhiteboardUrl()

                onDownloadFinished: {
                    console.log("onDownloadFinished", path);
                    whiteboardManager.showFileInFolder(path);
                }
                onJoinWriteBoardFailed: {
                    console.log("onJoinWriteBoardFailed errorCode: " + errorCode + " errorMessage: " + errorMessage);
                    if (errorCode == 403) {
                        //白板内部错误自动退出
                        if (whiteboardManager.whiteboardSharing && (whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId)) {
                            whiteboardManager.closeWhiteboard(authManager.authAccountId);
                        }
                        toast.show(qsTr("Whiteboard permission has not yet been activated, please contact sales for activation"));
                    }
                }
                onJoinWriteBoardSucceed: {
                    whiteboardManager.setEnableDraw(whiteboardManager.hasDrawPrivilege());
                }
                onLeaveWriteBoard: {
                    console.log("onLeaveWriteBoard");
                    if (membersManager.isGalleryView) {
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/GalleryPage.qml'));
                    } else {
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'));
                    }
                    //白板内部错误自动退出
                    if (whiteboardManager.whiteboardSharing && (whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId)) {
                        whiteboardManager.closeWhiteboard(authManager.authAccountId);
                    }
                }
                onWebLoadFinished: {
                    whiteboardManager.login();
                    membersManager.getMembersPaging(pageSize, currentPage, MembersStatus.VIEW_MODE_WHITEBOARD);
                }
                onWhiteboardGetAuth: {
                    console.log("onWhiteboardGetAuth");
                    whiteboardManager.auth();
                }
            }
        }
    }
    Connections {
        target: footerBar

        onShowChatroom: {
            chatBar.show = !chatBar.show;
        }
        onShowMembers: {
            membersBar.show = !membersBar.show;
        }
    }
    Connections {
        target: whiteboardManager

        onSendMessageToWeb: {
            idWhiteboard.sendMessageToWeb(webScript);
        }
        onWhiteboardDrawEnableChanged: {
            if (sharedAccountId === authManager.authAccountId) {
                whiteboardManager.setEnableDraw(enable);
                if (enable) {
                    toast.show(qsTr("You have been granted permission to interact with the whiteboard"));
                } else {
                    toast.show(qsTr("You have been reclaimed the whiteboard interactive permission"));
                }
            }
        }
        onWhiteboardSharingChanged: {
            if (!whiteboardManager.whiteboardSharing) {
                if (idWhiteboard.whiteboardIsJoinFinished) {
                    whiteboardManager.logout();
                } else {
                    if (membersManager.isGalleryView) {
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/GalleryPage.qml'));
                    } else {
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'));
                    }
                }
            }
        }
    }
    Connections {
        target: membersManager

        onMembersChanged: {
            console.info('Members info changed:', JSON.stringify(primaryMember), JSON.stringify(secondaryMembers), realPage, realCount);
            if (currentPage !== realPage) {
                memberModel.clear();
                currentPage = realPage;
            }
            MeetingHelpers.arrangeWhiteboardMemberLayout(secondaryMembers, realPage, realCount, memberModel);
            buttonNextPage.visible = currentPage * pageSize < realCount;
            buttonPrePage.visible = currentPage > 1;
        }
        onNicknameChanged: {
            var rowCount = memberModel.count;
            var found = false;
            for (var i = 0; i < rowCount; i++) {
                var model = memberModel.get(i);
                if (model.accountId === accountId) {
                    model.nickname = nickname;
                    found = true;
                }
            }
        }
    }
    Connections {
        target: chatBar

        onVisibleChanged: {
            if (visible) {
                GlobalChatManager.noNewMsgNotity();
            }
        }
    }
}
