import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import NetEase.Meeting.ToastHelper 1.0
import NetEase.Meeting.MeetingStatus 1.0
import MouseEventSpy 1.0
import NetEase.Meeting.MessageBubble 1.0
import NetEase.Meeting.GlobalChatManager 1.0
import NetEase.Meeting.GlobalToast 1.0
import "../components"
import "../msgbox"
import "../chattingroom"
import "../footerbar"
import "../invite"
import "../live"
import "../share"
import "../utils/meetingHelpers.js" as MeetingHelpers

Window {
    id: rootWindow

    property point lastMousePoint: '0,0'
    property var shareScreen: undefined

    signal message(string content)
    signal showChatRoom
    signal toast(string content)

    function getTimer() {
        return Qt.createQmlObject("import QtQuick 2.15; Timer {}", rootWindow);
    }
    function messageToastProc(msgCount, sender, content) {
        if (undefined === idMeetingToolBar.btnChat) {
            return;
        }
        GlobalChatManager.chatMsgCount = msgCount;
        if (chattingWindow.visible) {
            return;
        }
        if (content.length !== 0) {
            if (shareManager.shareAccountId === authManager.authAccountId) {
                MessageBubble.screen = shareScreen;
                MessageBubble.x = Qt.binding(function () {
                        return shareScreen.virtualX + shareScreen.desktopAvailableWidth - MessageBubble.width;
                    });
                MessageBubble.y = Qt.binding(function () {
                        return shareScreen.virtualY + shareScreen.desktopAvailableHeight - MessageBubble.height;
                    });
                MessageBubble.toastChatMessage(sender, content, true);
            }
        }
    }
    function stopScreenSharing(stop = true) {
        console.log("stopScreenSharing, stop: ", stop);
        if (stop)
            shareManager.stopScreenSharing(authManager.authAccountId);
        if (MessageBubble.visible)
            MessageBubble.hide();
        if (membersWindow.visible)
            membersWindow.hide();
        if (chattingWindow.visible)
            chattingWindow.hide();
        if (invitation.visible)
            invitation.hide();
        if (liveSetting.visible)
            liveSetting.hide();
        if (handsUpStatusWindow.visible)
            handsUpStatusWindow.visible = false;
        if (deviceSelector.visible)
            deviceSelector.visible = false;
        if (systemSound.visible)
            systemSound.hide();
        if (shareVideo.visible)
            shareVideo.hide();
        if (pauseWindow.visible)
            pauseWindow.hide();
        if (remainTipWindow.visible)
            remainTipWindow.hide();
    }

    Accessible.name: "NetEaseScreenSharingToolBar"
    color: "#00000000"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    height: fullToolbar.visible ? fullToolbar.height : smallToolbar.height
    title: "NetEaseScreenSharingToolBar"
    width: fullToolbar.visible ? fullToolbar.width : smallToolbar.width
    x: shareScreen !== undefined ? ((shareScreen.width - width) / 2) + shareScreen.virtualX : 0
    y: shareScreen !== undefined ? shareScreen.virtualY : 0

    Component.onCompleted: {
        shareManager.addExcludeShareWindow(rootWindow);
        shareManager.addExcludeShareWindow(MessageBubble);
        if (Qt.platform.os === 'osx') {
            shareManager.addExcludeShareWindow(handsUpStatusWindow);
            shareManager.addExcludeShareWindow(membersWindow);
            shareManager.addExcludeShareWindow(deviceSelector);
            shareManager.addExcludeShareWindow(moreItemsMenu);
            shareManager.addExcludeShareWindow(invitation);
            shareManager.addExcludeShareWindow(pauseWindow);
            shareManager.addExcludeShareWindow(chattingWindow);
            shareManager.addExcludeShareWindow(systemSound);
            shareManager.addExcludeShareWindow(liveSetting);
            shareManager.addExcludeShareWindow(shareVideo);
            shareManager.addExcludeShareWindow(sharePermissionWindow);
            shareManager.addExcludeShareWindow(invitationList);
            shareManager.addExcludeShareWindow(audioMsgbox);
            shareManager.addExcludeShareWindow(videoMsgbox);
            shareManager.addExcludeShareWindow(remainTipWindow);
        }
        chattingWindow.newMsgNotity.connect(messageToastProc);
        MessageBubble.messageBubbleClick.connect(function () {
                if (shareManager.shareAccountId.length !== 0 && chattingWindow.visible === false && authManager.authAccountId === shareManager.shareAccountId) {
                    chattingWindow.screen = shareScreen;
                    chattingWindow.x = (shareScreen.width - chattingWindow.width) / 2 + shareScreen.virtualX;
                    chattingWindow.y = (shareScreen.height - chattingWindow.height) / 2 + shareScreen.virtualY;
                    chattingWindow.show();
                    chattingWindow.raise();
                }
            });
    }
    Component.onDestruction: {
        shareManager.clearExcludeShareWindow();
    }
    onVisibleChanged: {
        if (visible) {
            if (shareManager.shareAccountId.length !== 0 && !shareManager.isExistScreen(shareScreen.name)) {
                rootWindow.hide();
                stopScreenSharing();
                return;
            }
            shareManager.addExcludeShareWindow(rootWindow);
            smallToolbar.visible = false;
            fullToolbar.visible = true;
            timer.start();
            // mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'));
            Qt.callLater(function () {
                    shareVideo.screen = shareScreen;
                    shareVideo.show();
                    shareVideo.resetPosition();
                });

            //console.log("SSToolbar, x : ", x, ", y: ", y, ", width: ", width, ", height: ", height, ",shareScreen.name: ", shareScreen.name)
        } else {
            shareManager.removeExcludeShareWindow(rootWindow);
            var timerMenu = getTimer();
            timerMenu.interval = 150;
            timerMenu.repeat = false;
            timerMenu.triggered.connect(function () {
                    moreItemsMenu.menu.resetItem();
                    idMeetingToolBar.resetItem();
                });
            timerMenu.start();
            chattingWindow.newMsgNotity.disconnect(messageToastProc);
            stopScreenSharing(false);
        }
    }

    MsgBox {
        id: audioMsgbox
        screen: rootWindow.screen

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(audioMsgbox) : shareManager.removeExcludeShareWindow(audioMsgbox);
            }
        }
    }
    MsgBox {
        id: videoMsgbox
        screen: rootWindow.screen

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(videoMsgbox) : shareManager.removeExcludeShareWindow(videoMsgbox);
            }
        }
    }
    DevSelector {
        id: deviceSelector
        screen: rootWindow.screen

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(deviceSelector) : shareManager.removeExcludeShareWindow(deviceSelector);
            }
        }
    }
    HandsUpStatus {
        id: handsUpStatusWindow
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(handsUpStatusWindow) : shareManager.removeExcludeShareWindow(handsUpStatusWindow);
            }
        }
    }
    MoreMenu {
        id: moreItemsMenu
        screen: rootWindow.screen

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(moreItemsMenu) : shareManager.removeExcludeShareWindow(moreItemsMenu);
            }
        }
    }
    SSystemSound {
        id: systemSound
        screen: rootWindow.screen

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(systemSound) : shareManager.removeExcludeShareWindow(systemSound);
            }
        }
    }
    SSRequestPermissionWindow {
        id: sharePermissionWindow
        screen: rootWindow.screen

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(sharePermissionWindow) : shareManager.removeExcludeShareWindow(sharePermissionWindow);
            }
        }
    }
    Window {
        id: pauseWindow
        color: "#00000000"
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        height: 32
        title: "ScreenSharingPauseToolBar"
        visible: rootWindow.visible && shareManager.ownerSharing && shareManager.paused
        width: 220
        x: rootWindow.x + (rootWindow.width - width) / 2
        y: rootWindow.y + rootWindow.height + 6

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(pauseWindow) : shareManager.removeExcludeShareWindow(pauseWindow);
            }
        }

        Rectangle {
            id: idPauseBar
            anchors.fill: parent
            color: "#FE3B30"
            radius: 4

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Label {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    text: shareManager.appMinimized ? qsTr("The share has been suspended, please restore the window") : qsTr("The share has been suspended")
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    Window {
        id: remainTipWindow
        color: "#00000000"
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        height: 50
        visible: remainingTip.visible
        width: 250
        x: rootWindow.x + (rootWindow.width - width) / 2
        y: rootWindow.y + rootWindow.height + 6

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(remainTipWindow) : shareManager.removeExcludeShareWindow(remainTipWindow);
            }
        }

        CustomTipArea {
            anchors.fill: parent
            description: remainingTip.description
            height: 50
            visible: true
            width: 250

            onSigCloseClicked: {
                showRemainingTipTimer.stop();
                hasShowRemainingTip = false;
                remainingTip.visible = false;
            }
        }
    }
    Rectangle {
        id: smallToolbar
        Accessible.name: "smallToolbar"
        height: 36
        radius: 4
        visible: false
        width: 220

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

        Rectangle {
            anchors.top: parent.top
            color: "#33333F"
            height: 4
            width: parent.width
        }
        Image {
            id: netWorkQualityImage
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            height: 13
            mipmap: true
            opacity: 1.0
            source: {
                const netWorkQualityType = membersManager.netWorkQualityType;
                if (MeetingStatus.NETWORKQUALITY_GOOD === netWorkQualityType) {
                    return "qrc:/qml/images/public/icons/networkquality_good.svg";
                } else if (MeetingStatus.NETWORKQUALITY_GENERAL === netWorkQualityType) {
                    return "qrc:/qml/images/public/icons/networkquality_general.svg";
                } else if (MeetingStatus.NETWORKQUALITY_BAD === netWorkQualityType) {
                    return "qrc:/qml/images/public/icons/networkquality_bad.svg";
                } else {
                    return "qrc:/qml/images/public/icons/networkquality_good.svg";
                }
            }
            width: 13
        }
        Label {
            id: idMeetingID
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "#FFFFFF"
            font.pixelSize: 14
            text: {
                let title = qsTr('Meeting ID: ');
                if (meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_SHORT_ID_ONLY && meetingManager.shortMeetingNum !== '') {
                    return title + meetingManager.shortMeetingNum;
                }
                return title + MeetingHelpers.prettyConferenceId(meetingManager.meetingId);
            }
        }
    }
    MouseEventSpy {
        id: mouseEventSpy
        onMousePosDetected: {
            if (mousePosX > rootWindow.x && mousePosX < rootWindow.x + rootWindow.width && mousePosY > rootWindow.y && mousePosY < rootWindow.y + rootWindow.height) {
                smallToolbar.visible = false;
                fullToolbar.visible = true;
                timer.restart();
            }
            lastMousePoint.x = mousePosX;
            lastMousePoint.y = mousePosY;
        }
    }
    Rectangle {
        id: fullToolbar
        Accessible.name: "fullToolbar"
        height: 68
        radius: 8
        width: toolbarLayout.width + 30

        gradient: Gradient {
            GradientStop {
                color: "#292933"
                position: 0.0
            }
            GradientStop {
                color: "#212129"
                position: 1.0
            }
        }

        Rectangle {
            anchors.top: parent.top
            color: '#292933'
            height: 8
            width: parent.width
        }
        RowLayout {
            id: toolbarLayout
            height: parent.height
            spacing: 0

            Image {
                Layout.leftMargin: 20
                Layout.preferredHeight: 13
                Layout.preferredWidth: 13
                mipmap: true
                opacity: 1.0
                source: {
                    const netWorkQualityType = membersManager.netWorkQualityType;
                    if (MeetingStatus.NETWORKQUALITY_GOOD === netWorkQualityType) {
                        return "qrc:/qml/images/public/icons/networkquality_good.svg";
                    } else if (MeetingStatus.NETWORKQUALITY_GENERAL === netWorkQualityType) {
                        return "qrc:/qml/images/public/icons/networkquality_general.svg";
                    } else if (MeetingStatus.NETWORKQUALITY_BAD === netWorkQualityType) {
                        return "qrc:/qml/images/public/icons/networkquality_bad.svg";
                    } else {
                        return "qrc:/qml/images/public/icons/networkquality_good.svg";
                    }
                }
            }
            ColumnLayout {
                Layout.preferredWidth: 130
                spacing: 0

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    color: "#FFFFFF"
                    font.pixelSize: 10
                    text: qsTr("Meeting ID")
                }
                Label {
                    Layout.alignment: Qt.AlignHCenter
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    text: {
                        if (meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_SHORT_ID_ONLY && meetingManager.shortMeetingNum !== '') {
                            return meetingManager.shortMeetingNum;
                        }
                        return MeetingHelpers.prettyConferenceId(meetingManager.meetingId);
                    }
                }
            }
            ToolSeparator {
                opacity: 0.1

                contentItem: Rectangle {
                    color: "#EBEDF0"
                    implicitHeight: 40
                    implicitWidth: 1
                }
            }
            MToolBar {
                id: idMeetingToolBar
                bSSToolbar: true
            }
            ToolSeparator {
                opacity: 0.1
                visible: 0 !== idMeetingToolBar.width

                contentItem: Rectangle {
                    color: "#EBEDF0"
                    implicitHeight: 40
                    implicitWidth: 1
                }
            }
            CustomButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: 18
                Layout.preferredHeight: 28
                Layout.preferredWidth: 76
                buttonRadius: 4
                highBorderColor: "#FE3B30"
                highNormalBkColor: "#FE3B30"
                highPushedBkColor: "#FE3B40"
                highlighted: true
                text: qsTr("End")
                visible: Qt.platform.os === 'osx'

                onClicked: {
                    stopScreenSharing();
                }
            }
            Rectangle {
                id: endRectangle
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 28
                Layout.preferredWidth: 102
                color: "#FE3B30"
                radius: 4
                visible: Qt.platform.os === 'windows'

                CustomButton {
                    id: btnEnd
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    buttonRadius: 4
                    font.pixelSize: 12
                    height: 28
                    highBorderColor: "#FE3B30"
                    highNormalBkColor: "#FE3B30"
                    highPushedBkColor: "#FE3B40"
                    highlighted: true
                    text: qsTr("End")
                    width: 48

                    onClicked: {
                        stopScreenSharing();
                    }
                }
                Item {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    width: parent.width - btnEnd.width - btnEnd.anchors.leftMargin - 15

                    ToolSeparator {
                        anchors.right: imageSystemSound.left
                        anchors.rightMargin: 1
                        anchors.verticalCenter: parent.verticalCenter

                        contentItem: Rectangle {
                            color: "#FFFFFF"
                            implicitHeight: 10
                            implicitWidth: 1
                        }
                    }
                    Image {
                        id: imageSystemSound
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        height: 6
                        mipmap: true
                        source: 'qrc:/qml/images/meeting/footerbar/btn_show_device_down_normal.png'
                        width: 6
                    }
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            const pos = endRectangle.mapToItem(null, 0, 0);
                            systemSound.screen = shareScreen;
                            systemSound.x = Qt.binding(function () {
                                    return pos.x + rootWindow.x + endRectangle.width - systemSound.width;
                                });
                            systemSound.y = Qt.binding(function () {
                                    return rootWindow.y + rootWindow.height + 10;
                                });
                            systemSound.setVisible(!systemSound.visible);
                        }
                    }
                }
            }
        }
    }
    Connections {
        target: smallToolbar

        onVisibleChanged: {
            console.log("[handsup] smallToolbar onVisibleChanged " + smallToolbar.visible);
            if (smallToolbar.visible) {
                handsUpStatusWindow.visible = false;
            } else {
                if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole)
                    return;
                if (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole) {
                    if (shareManager.shareAccountId.length === 0) {
                        handsUpStatusWindow.visible = false;
                        return;
                    }
                }
                if (shareManager.shareAccountId.length === 0) {
                    return;
                }
                if (membersManager.handsUpCount > 0 && undefined !== idMeetingToolBar.btnMembersCtrl) {
                    handsUpStatusWindow.visible = true;
                    const pos = idMeetingToolBar.btnMembersCtrl.mapToItem(null, 0, 0);
                    handsUpStatusWindow.x = Qt.binding(function () {
                            return pos.x + rootWindow.x + 16;
                        });
                    handsUpStatusWindow.y = Qt.binding(function () {
                            return pos.y + rootWindow.y + rootWindow.height + 5;
                        });
                    handsUpStatusWindow.tipText = membersManager.handsUpCount;
                }
            }
        }
    }
    Timer {
        id: handsupTimer
        interval: 200
        repeat: false

        onTriggered: {
            if (membersManager.handsUpCount > 0) {
                console.log("[handsup] timer to show tip");
                handsUpStatusWindow.visible = true;
                handsUpStatusWindow.tipText = membersManager.handsUpCount;
                const pos = idMeetingToolBar.btnMembersCtrl.mapToItem(null, 0, 0);
                handsUpStatusWindow.x = Qt.binding(function () {
                        return pos.x + rootWindow.x + 16;
                    });
                handsUpStatusWindow.y = Qt.binding(function () {
                        return pos.y + rootWindow.y + rootWindow.height + 5;
                    });
            }
        }
    }
    Timer {
        id: timer
        interval: 3000
        repeat: false
        running: false

        onTriggered: {
            if (!rootWindow.visible) {
                return;
            }
            if (deviceSelector.visible) {
                return;
            }
            if (moreItemsMenu.visible) {
                return;
            }
            if (systemSound.visible) {
                return;
            }
            if (lastMousePoint.x > rootWindow.x && lastMousePoint.x < rootWindow.x + rootWindow.width && lastMousePoint.y > rootWindow.y && lastMousePoint.y < rootWindow.y + rootWindow.height) {
                return;
            }
            handsUpStatusWindow.visible = false;
            fullToolbar.visible = false;
            smallToolbar.visible = true;
            deviceSelector.visible = false;
            moreItemsMenu.visible = false;
            systemSound.visible = false;
        }
    }
    Timer {
        id: posFixTimer
        interval: 2000
        repeat: false

        onTriggered: {
            for (var i = 0; i < Qt.application.screens.length; i++) {
                const tmpScreen = Qt.application.screens[i];
                if (shareScreen.name === tmpScreen.name) {
                    console.info("[ScreenToolbar] Fix pos of current screen, screen info:", tmpScreen.virtualX, tmpScreen.virtualY, tmpScreen.width, tmpScreen.height);
                    console.info('[ScreenToolbar] Current sharing screen info:', shareScreen.virtualX, shareScreen.virtualY, shareScreen.width, shareScreen.height);
                    if (shareScreen.virtualX !== tmpScreen.virtualX || shareScreen.virtualY !== tmpScreen.virtualY || shareScreen.width !== tmpScreen.width || shareScreen.height !== tmpScreen.height) {
                        stopScreenSharing();
                        return;
                    }
                    break;
                }
            }
        }
    }
    Timer {
        id: resetSizeTimer
        interval: 1000
        repeat: false

        onTriggered: {
            rootWindow.x = Qt.binding(function () {
                    return shareScreen !== undefined ? ((shareScreen.width - rootWindow.width) / 2) + shareScreen.virtualX : 0;
                });
            rootWindow.y = Qt.binding(function () {
                    return shareScreen !== undefined ? shareScreen.virtualY : 0;
                });
            fullToolbar.visible = true;
            fullToolbar.visible = false;
            shareVideo.screen = shareScreen;
            shareVideo.resetPosition();
        }
    }
    Connections {
        target: deviceSelector

        onVisibleChanged: {
            if (!deviceSelector.visible)
                timer.start();
        }
    }
    Connections {
        target: systemSound

        onVisibleChanged: {
            if (!systemSound.visible)
                timer.start();
        }
    }
    Connections {
        target: membersManager

        onHandsupStatusChanged: {
            if (membersManager.hostAccountId !== authManager.authAccountId && membersManager.hostAccountId !== shareManager.shareAccountId && !membersManager.isManagerRole && !membersManager.isManagerRoleEx(authManager.shareAccountId)) {
                return;
            }
            if (undefined === idMeetingToolBar.btnMembersCtrl) {
                return;
            }
            switch (status) {
            case MeetingStatus.HAND_STATUS_RAISE:
                fullToolbar.visible = true;
                smallToolbar.visible = false;
                console.log("[handsup] new handsup request");
                handsUpStatusWindow.tipText = membersManager.handsUpCount;
                handsUpStatusWindow.visible = true;
                const pos = idMeetingToolBar.btnMembersCtrl.mapToItem(null, 0, 0);
                handsUpStatusWindow.x = Qt.binding(function () {
                        return pos.x + rootWindow.x + 16;
                    });
                handsUpStatusWindow.y = Qt.binding(function () {
                        return pos.y + rootWindow.y + rootWindow.height + 5;
                    });
                break;
            case MeetingStatus.HAND_STATUS_DOWN:
            case MeetingStatus.HAND_STATUS_REJECT:
            case MeetingStatus.HAND_STATUS_AGREE:
                if (membersManager.handsUpCount === 0) {
                    handsUpStatusWindow.tipText = '';
                    handsUpStatusWindow.visible = false;
                } else {
                    fullToolbar.visible = true;
                    smallToolbar.visible = false;
                    handsUpStatusWindow.tipText = membersManager.handsUpCount;
                }
                break;
            }
        }
        onHostAccountIdChangedSignal: {
            //in share scene,when member is sharing, this member is setted as host. new host must sync members handsUpStatus
            if (hostAccountId === authManager.authAccountId && oldhostAccountId !== authManager.authAccountId) {
                if (membersManager.handsUpCount > 0 && undefined !== idMeetingToolBar.btnMembersCtrl) {
                    fullToolbar.visible = true;
                    smallToolbar.visible = false;
                    console.log("[handsup] new host set");
                    handsUpStatusWindow.visible = true;
                    const pos = idMeetingToolBar.btnMembersCtrl.mapToItem(null, 0, 0);
                    handsUpStatusWindow.x = Qt.binding(function () {
                            return pos.x + rootWindow.x + 16;
                        });
                    handsUpStatusWindow.y = Qt.binding(function () {
                            return pos.y + rootWindow.y + rootWindow.height + 5;
                        });
                    handsUpStatusWindow.tipText = membersManager.handsUpCount;
                }
            }
            if (rootWindow.visible) {
                if (authManager.authAccountId === hostAccountId) {
                    ToastHelper.displayText(qsTr('You have been set as host'), shareScreen);
                }
            }
        }
        onManagerAccountIdChanged: {
            if (managerAccountId === authManager.authAccountId) {
                if (bAdd) {
                    if (rootWindow.visible) {
                        ToastHelper.displayText(qsTr('You have been set as Manager'), shareScreen);
                    }
                    if (membersManager.handsUpCount > 0 && undefined !== idMeetingToolBar.btnMembersCtrl) {
                        fullToolbar.visible = true;
                        smallToolbar.visible = false;
                        console.log("[handsup] new manager set");
                        handsUpStatusWindow.visible = true;
                        const pos = idMeetingToolBar.btnMembersCtrl.mapToItem(null, 0, 0);
                        handsUpStatusWindow.x = Qt.binding(function () {
                                return pos.x + rootWindow.x + 16;
                            });
                        handsUpStatusWindow.y = Qt.binding(function () {
                                return pos.y + rootWindow.y + rootWindow.height + 5;
                            });
                        handsUpStatusWindow.tipText = membersManager.handsUpCount;
                    }
                } else {
                    if (rootWindow.visible) {
                        ToastHelper.displayText(qsTr('You have been unset as manager'), shareScreen);
                    }
                }
            }
        }
        onUserJoinNotify: {
            if (rootWindow.visible && (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole)) {
                ToastHelper.displayText(qsTr('%1 joined the meeting').arg(nickname), shareScreen);
            }
        }
        onUserLeftNotify: {
            if (rootWindow.visible && (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole)) {
                ToastHelper.displayText(qsTr('%1 left from the meeting').arg(nickname), shareScreen);
            }
        }
    }
    Connections {
        target: deviceManager

        onError: {
            toast.show(errorMessage);
        }
        onPlayoutDeviceChangedNotify: {
            if (rootWindow.visible)
                GlobalToast.displayText(qsTr('Current playout device "[%1]"').arg(deviceName), shareScreen);
        }
        onRecordDeviceChangedNotify: {
            if (rootWindow.visible)
                GlobalToast.displayText(qsTr('Current record device "[%1]"').arg(deviceName), shareScreen);
        }
        onShowMaxHubTip: {
            if (rootWindow.visible) {
                audioMsgbox.showMsgBox(qsTr('Select the audio output device'), qsTr('The screen is being cast. Do you want to output audio through the large screen?'), function () {
                        deviceManager.selectMaxHubDevice(DeviceSelector.DeviceType.PlayoutType);
                    }, function () {}, rootWindow, false);
            }
        }
    }
    Connections {
        target: shareManager

        onScreenAdded: {
            if (shareManager.shareAccountId.length === 0) {
                return;
            }
            console.info('New screen added, screen:', addedScreen, ', current sharing screen name:', shareScreen.name);
            posFixTimer.start();
        }
        onScreenRemoved: {
            if (shareManager.shareAccountId.length === 0) {
                return;
            }
            console.info('Screen removed, screen:', removedScreen, ', current sharing screen name:', shareScreen.name);
            if (removedScreen === shareScreen.name) {
                rootWindow.hide();
                stopScreenSharing();
            } else {
                posFixTimer.start();
            }
        }
        onScreenSizeChanged: {
            resetSizeTimer.start();
        }
        onShareAccountIdChanged: {
            fullToolbar.visible = true;
            smallToolbar.visible = false;
            if (shareManager.shareAccountId === authManager.authAccountId) {
                shareSelector.close();
                mainWindow.setVisible(false);
            }
            if ((shareManager.shareAccountId === membersManager.hostAccountId && membersManager.hostAccountId.length !== 0) || membersManager.isManagerRoleEx(authManager.authAccountId)) {
                console.log("[handsup] handsupTimer.restart");
                handsupTimer.restart();
            }
        }
    }
    Connections {
        target: audioManager

        onShowPermissionWnd: {
            sharePermissionWindow.sigOpenSetting.connect(function () {
                    audioManager.openSystemMicrophoneSettings();
                });
            sharePermissionWindow.titleText = qsTr("Microphone Permission");
            sharePermissionWindow.contentText = qsTr('Due to the security control of MacOS system, it is necessary to turn on the system Microphone permission before open Microphone%1Open System Preferences > Security and privacy grant access').arg('\r\n\r\n');
            sharePermissionWindow.x = (shareScreen.width - sharePermissionWindow.width) / 2 + shareScreen.virtualX;
            sharePermissionWindow.y = (shareScreen.height - sharePermissionWindow.height) / 2 + shareScreen.virtualY;
            sharePermissionWindow.screen = shareScreen;
            sharePermissionWindow.show();
            sharePermissionWindow.raise();
            sharePermissionWindow.visible = true;
        }
        onUserAudioStatusChanged: {
            if (shareManager.shareAccountId !== authManager.authAccountId) {
                return;
            }
            if (changedAccountId === authManager.authAccountId) {
                if (deviceStatus === MeetingStatus.DEVICE_DISABLED_BY_HOST && authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                    GlobalToast.displayText(qsTr('You have been muted by host'), shareScreen);
                }
                if (deviceStatus === MeetingStatus.DEVICE_NEEDS_TO_CONFIRM) {
                    if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                        audioMsgbox.showMsgBox(qsTr('Open your microphone'), qsTr('The host applies to open your microphone, do you agree.'), function () {
                                audioManager.muteLocalAudio(false);
                            }, function () {
                                audioManager.onUserAudioStatusChangedUI(authManager.authAccountId, 2);
                            }, rootWindow, false);
                    } else {
                        audioManager.muteLocalAudio(false);
                    }
                }
            }
        }
    }
    Connections {
        target: videoManager

        onShowPermissionWnd: {
            sharePermissionWindow.sigOpenSetting.connect(function () {
                    videoManager.openSystemCameraSettings();
                });
            sharePermissionWindow.titleText = qsTr("Camera Permission");
            sharePermissionWindow.contentText = qsTr('Due to the security control of MacOS system, it is necessary to turn on the system Camera permission before open Camera%1Open System Preferences > Security and privacy grant access').arg('\r\n\r\n');
            sharePermissionWindow.x = (shareScreen.width - sharePermissionWindow.width) / 2 + shareScreen.virtualX;
            sharePermissionWindow.y = (shareScreen.height - sharePermissionWindow.height) / 2 + shareScreen.virtualY;
            sharePermissionWindow.screen = shareScreen;
            sharePermissionWindow.show();
            sharePermissionWindow.raise();
            sharePermissionWindow.visible = true;
        }
        onUserVideoStatusChanged: {
            if (!rootWindow.visible || shareManager.shareAccountId !== authManager.authAccountId) {
                return;
            }
            if (changedAccountId === authManager.authAccountId) {
                if (deviceStatus === 3 && authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                    GlobalToast.displayText(qsTr('Your camera has been disabled by the host'), shareScreen);
                }
                if (deviceStatus === 4) {
                    if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                        videoMsgbox.showMsgBox(qsTr('Open your camera'), qsTr('The host applies to open your video, do you agree.'), function () {
                                videoManager.disableLocalVideo(false);
                            }, function () {
                                videoManager.onUserVideoStatusChangedUI(authManager.authAccountId, 2);
                            }, rootWindow, false);
                    } else {
                        videoManager.disableLocalVideo(false);
                    }
                }
            }
        }
    }
    Connections {
        target: rootWindow

        onClosing: {
            handsUpStatusWindow.visible = false;
            rootWindow.hide();
            close.accepted = false;
        }
    }
    Connections {
        target: meetingManager

        onMeetingStatusChanged: {
            switch (status) {
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_ENDED:
                if (MessageBubble.visible) {
                    MessageBubble.hide();
                }
                if (chattingWindow.visible) {
                    chattingWindow.hide();
                }
                if (invitation.visible) {
                    invitation.hide();
                }
                if (liveSetting.visible) {
                    liveSetting.hide();
                }
                if (pauseWindow.visible) {
                    pauseWindow.hide();
                }
                if (remainTipWindow.visible) {
                    remainTipWindow.hide();
                }
                break;
            default:
                break;
            }
        }
    }
    Connections {
        target: GlobalChatManager

        onNoNewMsgNotity: {
            chattingWindow.msgCount = 0;
        }
    }
    Connections {
        target: handsUpStatusWindow

        onClick: {
            if (membersWindow.visible === true) {
                membersWindow.raise();
                return;
            }
            membersWindow.x = (shareScreen.width - membersWindow.width) / 2 + shareScreen.virtualX;
            membersWindow.y = (shareScreen.height - membersWindow.height) / 2 + shareScreen.virtualY;
            membersWindow.screen = shareScreen;
            membersWindow.show();
            membersWindow.raise();
        }
    }
    Connections {
        target: moreItemManager

        onChatItemVisibleChanged: {
            if (!moreItemManager.chatItemVisible) {
                MessageBubble.hide();
                if (undefined !== chattingWindow) {
                    chattingWindow.hide();
                }
            }
        }
        onInviteItemVisibleChanged: {
            if (invitation.visible && !moreItemManager.inviteItemVisible) {
                invitation.hide();
            }
        }
        onMangeParticipantsItemVisibleChanged: {
            if (!moreItemManager.mangeParticipantsItemVisible && !moreItemManager.participantsItemVisible) {
                handsUpStatusWindow.hide();
                membersWindow.hide();
            }
        }
        onParticipantsItemVisibleChanged: {
            if (!moreItemManager.mangeParticipantsItemVisible && !moreItemManager.participantsItemVisible) {
                handsUpStatusWindow.hide();
                membersWindow.hide();
            }
        }
    }
    Connections {
        target: idMeetingToolBar

        onBtnAudioCtrlClicked: {
            audioManager.muteLocalAudio(audioManager.localAudioStatus === FooterBar.DeviceStatus.DeviceEnabled);
        }
        onBtnAudioSettingsClicked: {
            if (deviceSelector.visible) {
                deviceSelector.visible = false;
            }
            const point = rootWindow.contentItem.mapFromItem(idMeetingToolBar.btnAudioSettings, 0, 0);
            deviceSelector.x = rootWindow.x + point.x + (idMeetingToolBar.btnAudioSettings.width - deviceSelector.width) / 2;
            deviceSelector.y = rootWindow.y + rootWindow.height + 10;
            deviceSelector.mode = DeviceSelector.DeviceSelectorMode.AudioMode;
            deviceSelector.show();
        }
        onBtnChatClicked: {
            if (MessageBubble.visible) {
                MessageBubble.hide();
            }
            chattingWindow.screen = shareScreen;
            chattingWindow.x = (shareScreen.width - chattingWindow.width) / 2 + shareScreen.virtualX;
            chattingWindow.y = (shareScreen.height - chattingWindow.height) / 2 + shareScreen.virtualY;
            chattingWindow.show();
        }
        onBtnInvitationClicked: {
            if (!shareManager.ownerSharing) {
                return;
            }
            invitation.screen = shareScreen;
            invitation.x = (shareScreen.width - invitation.width) / 2 + shareScreen.virtualX;
            invitation.y = (shareScreen.height - invitation.height) / 2 + shareScreen.virtualY;
            invitation.show();
        }
        onBtnLiveClicked: {
            if (!shareManager.ownerSharing) {
                return;
            }
            if (!liveSetting.visible) {
                liveSetting.screen = shareScreen;
                liveSetting.x = (shareScreen.width - liveSetting.width) / 2 + shareScreen.virtualX;
                liveSetting.y = (shareScreen.height - liveSetting.height) / 2 + shareScreen.virtualY;
                liveSetting.modality = Qt.NonModal;
                liveSetting.show();
            } else {
                liveSetting.raise();
            }
        }
        onBtnMembersCtrlClicked: {
            if (!shareManager.ownerSharing) {
                return;
            }
            membersWindow.x = (shareScreen.width - membersWindow.width) / 2 + shareScreen.virtualX;
            membersWindow.y = (shareScreen.height - membersWindow.height) / 2 + shareScreen.virtualY;
            membersWindow.screen = shareScreen;
            membersWindow.show();
            membersWindow.raise();
        }
        onBtnMoreClicked: {
            const point = rootWindow.contentItem.mapFromItem(idMeetingToolBar.btnMore, 0, 0);
            moreItemsMenu.screen = shareScreen;
            moreItemsMenu.x = rootWindow.x + point.x + (idMeetingToolBar.btnMore.width - moreItemsMenu.width) / 2;
            moreItemsMenu.y = rootWindow.y + rootWindow.height + 10;
            moreItemsMenu.show();
        }
        onBtnSipInviteClicked: {
            if (!shareManager.ownerSharing) {
                return;
            }
            if (!invitationList.visible) {
                invitationList.screen = shareScreen;
                invitationList.x = (shareScreen.width - invitationList.width) / 2 + shareScreen.virtualX;
                invitationList.y = (shareScreen.height - invitationList.height) / 2 + shareScreen.virtualY;
                invitationList.show();
            } else {
                invitationList.raise();
            }
        }
        onBtnVideoCtrlClicked: {
            videoManager.disableLocalVideo(videoManager.localVideoStatus === FooterBar.DeviceStatus.DeviceEnabled);
        }
        onBtnVideoSettingsClicked: {
            if (deviceSelector.visible) {
                deviceSelector.visible = false;
            }
            const point = rootWindow.contentItem.mapFromItem(idMeetingToolBar.btnVideoSettings, 0, 0);
            deviceSelector.x = rootWindow.x + point.x + (idMeetingToolBar.btnVideoSettings.width - deviceSelector.width) / 2;
            deviceSelector.y = rootWindow.y + rootWindow.height + 10;
            deviceSelector.mode = DeviceSelector.DeviceSelectorMode.VideoMode;
            deviceSelector.show();
        }
    }
}
