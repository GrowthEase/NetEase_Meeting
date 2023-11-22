import QtQuick.Window 2.12
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NetEase.Meeting.MessageBubble 1.0
import NetEase.Meeting.GlobalChatManager 1.0
import NetEase.Meeting.MeetingStatus 1.0
import "../components"
import "../footerbar"
import "../"
import "../utils/dialogManager.js" as DialogManager

Rectangle {
    id: footerContainer
    enum DeviceStatus {
        DeviceEnabled = 1,
        DeviceDisabledBySelf,
        DeviceDisabledByHost,
        DeviceNeedsConfirm
    }

    property var component: undefined
    property alias idMeetingToolBar: idMeetingToolBar
    property var tempDynamicDialogEx: undefined

    signal closeWhiteboard
    signal recvNewChatMsg(int msgCount, string sender, string content)
    signal screenShare(bool hasRecordPermission)
    signal showChatroom
    signal showMembers
    signal switchView

    function finishCreation(sender, content, pos) {
    }

    gradient: Gradient {
        GradientStop {
            color: "#33333F"
            position: 0.0
        }
        GradientStop {
            color: "#292933"
            position: 1.0
        }
    }

    Component.onCompleted: {
        component = Qt.createComponent("qrc:/qml/toast/MessageBubbleEx.qml");
    }
    onHeightChanged: {
        if (undefined === idMeetingToolBar.btnChat || shareManager.shareAccountId === authManager.authAccountId || chatBar.visible === true)
            return;
        if (Qt.platform.os === 'osx' && mainWindow.visibility === Window.FullScreen) {
            if (mainWindow.messageBubbleFullWindow !== undefined && mainWindow.messageBubbleFullWindow.visible) {
                let pos = idMeetingToolBar.btnChat.mapToItem(mainLayout, 0, 0);
                mainWindow.messageBubbleFullWindow.x = Qt.binding(function () {
                        return pos.x + mainWindow.x - MessageBubble.width / 2 + 30;
                    });
                mainWindow.messageBubbleFullWindow.y = Qt.binding(function () {
                        return pos.y + mainWindow.y - MessageBubble.height - 2;
                    });
            }
        } else if (MessageBubble.visible) {
            let pos = idMeetingToolBar.btnChat.mapToItem(mainLayout, 0, 0);
            MessageBubble.x = Qt.binding(function () {
                    return pos.x + mainWindow.x - MessageBubble.width / 2 + 30;
                });
            MessageBubble.y = Qt.binding(function () {
                    return pos.y + mainWindow.y - MessageBubble.height - 2;
                });
        }
    }
    onRecvNewChatMsg: {
        console.info(`Received new chatroom message, message count: ${msgCount}, sender: ${sender}`);
        if (undefined === idMeetingToolBar.btnChat || !idMeetingToolBar.btnChat.visible) {
            console.warn("Chat button is not visible, ignore the message");
            return;
        }
        if (shareManager.shareAccountId === authManager.authAccountId && shareManager.shareAccountId.length !== 0) {
            console.warn("Share screen, ignore the message");
            return;
        }
        GlobalChatManager.chatMsgCount = msgCount;
        if (chatBar.visible || mainWindow.visibility === Window.Minimized) {
            console.warn("Chatroom is visible or window is minimized, ignore the message");
            return;
        }
        if (content.length !== 0) {
            if (shareManager.shareAccountId !== authManager.authAccountId) {
                var pos = idMeetingToolBar.btnChat.mapToItem(mainLayout, 0, 0);
                if (Qt.platform.os === 'osx' && mainWindow.visibility === Window.FullScreen) {
                    if (mainWindow.messageBubbleFullWindow === undefined) {
                        if (component.status === Component.Ready) {
                            mainWindow.messageBubbleFullWindow = component.createObject(mainWindow);
                            if (mainWindow.messageBubbleFullWindow === null) {
                                console.log("mainWindow.messageBubbleFullWindow === null");
                            } else {
                                mainWindow.messageBubbleFullWindow.toastChatMessage(sender, content, true);
                                mainWindow.messageBubbleFullWindow.messageBubbleClick.connect(function () {
                                        mainWindow.messageBubbleFullWindow.hide();
                                        showChatroom();
                                    });
                                mainWindow.messageBubbleFullWindow.x = Qt.binding(function () {
                                        return pos.x + mainWindow.x - MessageBubble.width / 2 + 30;
                                    });
                                mainWindow.messageBubbleFullWindow.y = Qt.binding(function () {
                                        return pos.y + mainWindow.y - MessageBubble.height - 2;
                                    });
                            }
                        } else {
                            console.log("component.status: ", component.status);
                        }
                        return;
                    }
                    if (0 === footerContainer.height) {
                        mainWindow.messageBubbleFullWindow.y = Qt.binding(function () {
                                return pos.y + mainWindow.y - MessageBubble.height - 2;
                            });
                    }
                    mainWindow.messageBubbleFullWindow.toastChatMessage(sender, content, true);
                } else {
                    MessageBubble.x = Qt.binding(function () {
                            return pos.x + mainWindow.x - MessageBubble.width / 2 + 30;
                        });
                    MessageBubble.y = Qt.binding(function () {
                            return pos.y + mainWindow.y - MessageBubble.height - 2;
                        });
                    MessageBubble.toastChatMessage(sender, content, true);
                }
            }
        }
    }

    MToolBar {
        id: idMeetingToolBar
        anchors.horizontalCenter: parent.horizontalCenter
    }
    CustomButton {
        id: btnLeave
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        borderColor: "#292933"
        buttonRadius: 4
        height: 28
        normalBkColor: "#292933"
        normalTextColor: "#FE3B30"
        pushedBkColor: "#000000"
        text: qsTr("Leave")
        visible: authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole && parent.height > height
        width: 76

        onClicked: {
            customDialog.confirmBtnText = qsTr("OK");
            customDialog.cancelBtnText = qsTr("Cancel");
            customDialog.text = qsTr('Exit');
            customDialog.description = qsTr('Do you want to quit this meeting?');
            customDialog.confirm.disconnect(muteLocalAudio);
            customDialog.confirm.disconnect(enableLocalVideo);
            customDialog.confirm.disconnect(endMeeting);
            customDialog.confirm.disconnect(muteHandsDown);
            customDialog.confirm.disconnect(muteHandsUp);
            customDialog.cancel.disconnect(unMuteLoaclAudio);
            customDialog.cancel.disconnect(disableLocalVideo);
            customDialog.confirm.connect(leaveMeeting);
            customDialog.open();
        }
    }
    CustomButton {
        id: btnEnd
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        borderColor: "#292933"
        buttonRadius: 4
        height: 28
        normalBkColor: "#292933"
        normalTextColor: "#FE3B30"
        pushedBkColor: "#000000"
        text: qsTr("End")
        visible: (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) && parent.height > height
        width: 76

        onClicked: {
            tempDynamicDialogEx = DialogManager.dynamicDialogEx(qsTr('End Meeting'), qsTr('Do you want to quit this meeting?'), function () {
                    mainWindow.width = defaultWindowWidth;
                    meetingManager.leaveMeeting(false);
                }, function () {
                    mainWindow.width = defaultWindowWidth;
                    meetingManager.leaveMeeting(true);
                }, function () {});
        }
    }
    Connections {
        target: MessageBubble

        onMessageBubbleClick: {
            MessageBubble.hide();
            showChatroom();
        }
    }
    Connections {
        target: GlobalChatManager

        onNoNewMsgNotity: {
            msgCount = 0;
        }
    }
    Connections {
        target: mainWindow

        onVisibilityChanged: {
            if (mainWindow.visibility === Window.Minimized) {
                if (MessageBubble.visible)
                    MessageBubble.visible = false;
                if (Qt.platform.os === 'osx' && mainWindow.messageBubbleFullWindow !== undefined && mainWindow.messageBubbleFullWindow.visible) {
                    mainWindow.messageBubbleFullWindow.hide();
                }
            }
        }
    }
    Connections {
        target: idMeetingToolBar

        onBtnAudioCtrlClicked: {
            console.log("membersManager.handsUpStatus", membersManager.handsUpStatus);
            console.log("meetingManager.meetingMuted", meetingManager.meetingMuted);
            console.log("audioManager.localAudioStatus", audioManager.localAudioStatus);
            console.log("meetingManager.meetingAllowSelfAudioOn", meetingManager.meetingAllowSelfAudioOn);
            console.log("authManager.authAccountId", authManager.authAccountId);
            console.log("membersManager.hostAccountId", membersManager.hostAccountId);
            console.log("membersManager.isManagerRole", membersManager.isManagerRole);
            if (meetingManager.meetingMuted && audioManager.localAudioStatus !== FooterBar.DeviceStatus.DeviceEnabled && !meetingManager.meetingAllowSelfAudioOn && authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                if (membersManager.handsUpStatus) {
                    toast.show(qsTr("You have raised your hand, please wait for the host to deal with it"));
                } else {
                    customDialog.cancelBtnText = qsTr("Cancel");
                    customDialog.confirmBtnText = qsTr("HandsUpRaise");
                    customDialog.text = qsTr("Mute all");
                    customDialog.description = qsTr("This meeting has been turned on all mute by host,you can hands up to speak");
                    customDialog.confirm.disconnect(enableLocalVideo);
                    customDialog.confirm.disconnect(leaveMeeting);
                    customDialog.confirm.disconnect(endMeeting);
                    customDialog.confirm.disconnect(muteHandsDown);
                    customDialog.confirm.disconnect(muteLocalAudio);
                    customDialog.confirm.disconnect(showMaxHubTip);
                    customDialog.cancel.disconnect(disableLocalVideo);
                    customDialog.cancel.disconnect(unMuteLoaclAudio);
                    customDialog.confirm.connect(muteHandsUp);
                    customDialog.open();
                }
                return;
            }
            audioManager.muteLocalAudio(audioManager.localAudioStatus === FooterBar.DeviceStatus.DeviceEnabled);
        }
        onBtnAudioSettingsClicked: {
            deviceSelector.setDeviceSelectorMode(DeviceSelector.DeviceSelectorMode.AudioMode);
            const controlPos = idMeetingToolBar.btnAudioSettings.mapToItem(mainLayout, 0, 0);
            deviceSelector.x = controlPos.x - deviceSelector.width / 2;
            // deviceSelector.y = controlPos.y - deviceSelector.height - 60
            deviceSelector.open();
        }
        onBtnChatClicked: {
            MessageBubble.hide();
            if (Qt.platform.os === 'osx' && mainWindow.messageBubbleFullWindow !== undefined && mainWindow.messageBubbleFullWindow.visible) {
                mainWindow.messageBubbleFullWindow.hide();
            }
            showChatroom();
        }
        onBtnInvitationClicked: {
            if (shareManager.ownerSharing) {
                return;
            }
            invitation.screen = mainWindow.screen;
            invitation.x = (mainWindow.screen.width - invitation.width) / 2 + mainWindow.screen.virtualX;
            invitation.y = (mainWindow.screen.height - invitation.height) / 2 + mainWindow.screen.virtualY;
            invitation.show();
            invitation.raise();
        }
        onBtnLiveClicked: {
            if (shareManager.ownerSharing) {
                return;
            }
            liveSetting.screen = mainWindow.screen;
            liveSetting.x = (mainWindow.screen.width - liveSetting.width) / 2 + mainWindow.screen.virtualX;
            liveSetting.y = (mainWindow.screen.height - liveSetting.height) / 2 + mainWindow.screen.virtualY;
            liveSetting.modality = Qt.NonModal;
            liveSetting.show();
            liveSetting.raise();
        }
        onBtnMembersCtrlClicked: {
            if (shareManager.ownerSharing) {
                return;
            }
            showMembers();
        }
        onBtnMoreClicked: {
            const controlPos = idMeetingToolBar.btnMore.mapToItem(mainLayout, 0, 0);
            if (moreItemManager.moreItemInjected) {
                moreItemsMenu.x = controlPos.x - moreItemsMenu.width / 2 + idMeetingToolBar.btnMore.width / 2;
                moreItemsMenu.open();
            } else {
                moreItemsMenuEx.x = controlPos.x - moreItemsMenuEx.width / 2 + idMeetingToolBar.btnMore.width / 2;
                moreItemsMenuEx.open();
            }
        }
        onBtnSharingClicked: {
            if (whiteboardManager.whiteboardSharing) {
                toast.show(qsTr("Whiteboard sharing does not currently support screen share"));
                return;
            }
            if (shareManager.ownerSharing) {
                return;
            }
            screenShare(shareManager.hasRecordPermission());
        }
        onBtnSipInviteClicked: {
            if (shareManager.ownerSharing) {
                return;
            }
            invitationList.screen = mainWindow.screen;
            invitationList.x = (mainWindow.screen.width - invitationList.width) / 2 + mainWindow.screen.virtualX;
            invitationList.y = (mainWindow.screen.height - invitationList.height) / 2 + mainWindow.screen.virtualY;
            invitationList.show();
            invitationList.raise();
        }
        onBtnSwitchViewClicked: {
            if (shareManager.ownerSharing) {
                return;
            }
            if (whiteboardManager.whiteboardSharing) {
                toast.show(qsTr("Whiteboard sharing does not currently support switching views"));
                return;
            }
            switchView();
        }
        onBtnVideoCtrlClicked: {
            if (meetingManager.meetingVideoMuted && videoManager.localVideoStatus !== FooterBar.DeviceStatus.DeviceEnabled && !meetingManager.meetingAllowSelfVideoOn && authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                if (membersManager.handsUpStatus) {
                    toast.show(qsTr("You have raised your hand, please wait for the host to deal with it"));
                } else {
                    function confirm() {
                        if (meetingManager.meetingVideoMuted && !meetingManager.meetingAllowSelfVideoOn) {
                            membersManager.handsUp(true);
                        }
                    }
                    //do nonthing
                    function cancel() {}
                    tempDynamicDialog = DialogManager.dynamicDialog2(qsTr("Mute all Video"), qsTr("This meeting has been turned on all mute video by host,you can hands up to speak"), confirm, cancel, qsTr("HandsUpRaise"), qsTr("Cancel"), mainWindow, false);
                }
                return;
            }
            videoManager.disableLocalVideo(videoManager.localVideoStatus === FooterBar.DeviceStatus.DeviceEnabled);
        }
        onBtnVideoSettingsClicked: {
            deviceSelector.setDeviceSelectorMode(DeviceSelector.DeviceSelectorMode.VideoMode);
            const controlPos = idMeetingToolBar.btnVideoSettings.mapToItem(mainLayout, 0, 0);
            deviceSelector.x = controlPos.x - deviceSelector.width / 2;
            // deviceSelector.y = controlPos.y - deviceSelector.height - 60
            deviceSelector.open();
        }
        onBtnWhiteboardClicked: {
            if (shareManager.shareAccountId !== "") {
                toast.show(qsTr("Screen sharing does not currently support screen share"));
                return;
            }

            //如果没人在共享,则直接调用开启白板
            if (!whiteboardManager.whiteboardSharing) {
                whiteboardManager.openWhiteboard(authManager.authAccountId);
                return;
            }

            //如果有人在共享，判断是不是自己，如果是自己则调用关闭白板接口，如果不是自己则提示不可以进行共享
            if (whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId) {
                whiteboardManager.closeWhiteboard(authManager.authAccountId);
            } else {
                toast.show(qsTr("Someone is currently sharing a whiteboard"));
            }
        }
    }
    Connections {
        target: meetingManager

        onMeetingStatusChanged: {
            switch (status) {
            case MeetingStatus.MEETING_ENDED:
                if (tempDynamicDialogEx != undefined) {
                    tempDynamicDialogEx.close();
                }
                break;
            default:
                break;
            }
        }
    }
    Connections {
        target: membersManager

        onManagerAccountIdChanged: {
            if (managerAccountId === authManager.authAccountId && !bAdd) {
                if (tempDynamicDialogEx !== undefined)
                    tempDynamicDialogEx.close();
            }
        }
    }
}
