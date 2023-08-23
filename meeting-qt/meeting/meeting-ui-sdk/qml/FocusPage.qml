import QtQuick 2.15
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import NetEase.Meeting.MembersModel 1.0
import NetEase.Meeting.GlobalChatManager 1.0
import NetEase.Settings.SettingsStatus 1.0
import "components"
import "share"
import "utils/dialogManager.js" as DialogManager
import "utils/meetingHelpers.js" as MeetingHelpers

Rectangle {
    id: root

    property var currentSpeaker: undefined
    property var currentprimaryMember: undefined
    property int elementWidth: root.width * 0.15
    property int elementHeight: elementWidth * 9 / 16
    property point mousePoint: "0,0"

    anchors.fill: parent

    Component.onCompleted: {
        viewMode = MainPanel.ViewMode.FocusViewMode;
        membersManager.isGalleryView = false;
        membersManager.isWhiteboardView = false;
        currentPage = 1;
        pageSize = 4;
        membersManager.getMembersPaging(pageSize, currentPage);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: idSecondaryView
            Layout.fillWidth: true
            Layout.preferredHeight: secondaryView.height + 8
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

                        onClicked: membersManager.getMembersPaging(pageSize, currentPage - 1)
                    }
                }
                ListView {
                    id: secondaryView
                    Layout.preferredHeight: elementHeight
                    Layout.preferredWidth: count * elementWidth + ((count - 1) * 4)
                    Layout.topMargin: 4
                    orientation: Qt.Horizontal
                    spacing: 4

                    delegate: VideoDelegate {
                        accountId: model.accountId
                        audioStatus: model.audioStatus
                        createdAt: model.createdAt
                        height: secondaryView.height
                        highQuality: authManager.authAccountId === model.accountId ? false : SettingsManager.remoteVideoResolution
                        nickname: model.nickname
                        videoStatus: model.videoStatus
                        width: elementWidth
                    }
                    model: ListModel {
                        id: secondaryModel
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
                anchors.leftMargin: 8
                anchors.top: parent.top
                anchors.topMargin: 4
                spacing: 10
                z: 1

                Rectangle {
                    color: "#771E1E1E"
                    height: 22
                    visible: (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) && videoManager.focusAccountId.length !== 0 && shareManager.shareAccountId.length === 0
                    width: {
                        if (SettingsStatus.UILanguage_en === SettingsManager.uiLanguage) {
                            return 150;
                        } else if (SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage) {
                            return 180;
                        } else {
                            return 90;
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        text: qsTr('Unset Focus')
                    }
                    MouseArea {
                        id: unsetFocus
                        anchors.fill: parent
                        cursorShape: Qt.ClosedHandCursor

                        onClicked: membersManager.setAsFocus(videoManager.focusAccountId, false)
                    }
                }
                Rectangle {
                    color: "#CC313138"
                    height: 21
                    radius: 2
                    visible: authManager.authAccountId !== shareManager.shareAccountId && shareManager.shareAccountId.length !== 0
                    width: 21

                    Image {
                        anchors.fill: parent
                        height: 21
                        mipmap: true
                        source: idSecondaryView.visible ? "qrc:/qml/images/meeting/shrink.svg" : "qrc:/qml/images/meeting/extend.svg"
                        width: 21
                    }
                    MouseArea {
                        id: extendView
                        anchors.fill: parent
                        cursorShape: Qt.ClosedHandCursor

                        onClicked: {
                            idSecondaryView.visible = !idSecondaryView.visible;
                            SettingsManager.extendView = !idSecondaryView.visible;
                        }
                    }
                }
            }
        }
    }
    Connections {
        target: footerBar

        onScreenShare: {
            if (hasRecordPermission) {
                if (!shareSelector.visible) {
                    shareSelector.open();
                } else {
                    shareSelector.close();
                }
            } else {
                requestPermission.sigOpenSetting.connect(function () {
                        shareManager.openSystemSettings();
                    });
                requestPermission.titleText = qsTr("Screen Record Permission");
                requestPermission.contentText = qsTr('Due to the security control of MacOS system, it is necessary to turn on the system screen recording permission before starting to share the screen%1Open System Preferences > Security and privacy grant access').arg('\r\n\r\n');
                requestPermission.open();
            }
        }
        onShowChatroom: {
            chatBar.show = !chatBar.show;
        }
        onShowMembers: {
            membersBar.show = !membersBar.show;
        }
        onSwitchView: {
            if (shareManager.shareAccountId.length !== 0) {
                toast.show(qsTr("Someone is screen sharing currently, you can't switch the view mode"));
                return;
            }
            if (whiteboardManager.whiteboardSharing && whiteboardManager.whiteboardSharerAccountId.length !== 0) {
                toast.show(qsTr("Someone is whiteboard sharing currently, you can't switch the view mode"));
                return;
            }
            if (secondaryModel.count !== 0)
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/GalleryPage.qml'));
        }
    }
    Connections {
        target: membersManager

        onMembersChanged: {
            if (!visible || shareManager.shareAccountId === authManager.authAccountId) {
                return;
            }
            console.info('Members info changed:', JSON.stringify(primaryMember), JSON.stringify(secondaryMembers), realPage, realCount);
            if (currentPage !== realPage) {
                secondaryModel.clear();
                currentPage = realPage;
            }
            currentprimaryMember = primaryMember;
            MeetingHelpers.arrangeSpeakerLayout(primaryMember, secondaryMembers, realPage, realCount, primaryContainer, secondaryModel);
            console.info('Secondary members count: ', secondaryModel.count);
            buttonNextPage.visible = currentPage * pageSize < realCount;
            buttonPrePage.visible = currentPage > 1;
        }
        onNicknameChanged: {
            var rowCount = secondaryModel.count;
            var found = false;
            for (var i = 0; i < rowCount; i++) {
                var model = secondaryModel.get(i);
                if (model.accountId === accountId) {
                    model.nickname = nickname;
                    found = true;
                }
            }
            if (found === false) {
                if (accountId === currentSpeaker.accountId) {
                    currentSpeaker.nickname = nickname;
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
    Connections {
        target: shareManager

        onShareAccountIdChanged: {
            if (shareManager.shareAccountId.length === 0) {
                idSecondaryView.visible = Qt.binding(function () {
                        return secondaryView.count > 0;
                    });
            } else {
                if (SettingsManager.extendView) {
                    extendView.clicked(Qt.LeftButton);
                }
            }
        }
    }
}
