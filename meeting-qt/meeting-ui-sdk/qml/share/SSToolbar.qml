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
    title: "NetEaseScreenSharingToolBar"
    width: fullToolbar.visible ? fullToolbar.width : smallToolbar.width
    height: fullToolbar.visible ? fullToolbar.height : smallToolbar.height
    x: shareScreen !== undefined ? ((shareScreen.width - width) / 2) + shareScreen.virtualX : 0
    y: shareScreen !== undefined ? shareScreen.virtualY : 0
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "#00000000"

    property var shareScreen: undefined
    property point lastMousePoint: '0,0'

    signal toast(string content)
    signal message(string content)
    signal showChatRoom()

    Component.onCompleted: {
        shareManager.addShareWindow(rootWindow)
        shareManager.addShareWindow(handsUpStatusWindow)
        shareManager.addShareWindow(membersWindow)
        shareManager.addShareWindow(MessageBubble)
        shareManager.addShareWindow(deviceSelector)
        shareManager.addShareWindow(moreItemsMenu)
        shareManager.addShareWindow(invitation)
        shareManager.addShareWindow(pauseWindow)
        shareManager.addShareWindow(chattingWindow)
        shareManager.addShareWindow(systemSound)
        shareManager.addShareWindow(liveSetting)
        shareManager.addShareWindow(shareVideo)

        chattingWindow.newMsgNotity.connect(messageToastProc)
        MessageBubble.messageBubbleClick.connect(function(){
            if(shareManager.shareAccountId.length !== 0 && chattingWindow.visible === false && authManager.authAccountId === shareManager.shareAccountId){
                chattingWindow.screen = shareScreen
                chattingWindow.x = (shareScreen.width - chattingWindow.width) / 2 + shareScreen.virtualX
                chattingWindow.y = (shareScreen.height - chattingWindow.height) / 2 + shareScreen.virtualY
                chattingWindow.show()
                chattingWindow.raise()
            }
        })
    }

    Component.onDestruction: {
        shareManager.removeShareWindow(rootWindow)
        shareManager.removeShareWindow(handsUpStatusWindow)
        shareManager.removeShareWindow(membersWindow)
        shareManager.removeShareWindow(MessageBubble)
        shareManager.removeShareWindow(deviceSelector)
        shareManager.removeShareWindow(moreItemsMenu)
        shareManager.removeShareWindow(invitation)
        shareManager.removeShareWindow(pauseWindow)
        shareManager.removeShareWindow(chattingWindow)
        shareManager.removeShareWindow(systemSound)
        shareManager.removeShareWindow(liveSetting)
        shareManager.removeShareWindow(shareVideo)
    }

    onVisibleChanged: {
        if (visible) {
            smallToolbar.visible = false
            fullToolbar.visible = true
            timer.start()
            mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'))
            Qt.callLater(function() {
                shareVideo.screen = shareScreen
                shareVideo.resetPosition()
                shareVideo.show()
            })

            //console.log("SSToolbar, x : ", x, ", y: ", y, ", width: ", width, ", height: ", height, ",shareScreen.name: ", shareScreen.name)
        } else {
            shareManager.removeShareWindow(rootWindow)
            var timerMenu = getTimer();
            timerMenu.interval = 150;
            timerMenu.repeat = false;
            timerMenu.triggered.connect(function () {
                moreItemsMenu.menu.resetItem()
                idMeetingToolBar.resetItem()
            })
            timerMenu.start();
            chattingWindow.newMsgNotity.disconnect(messageToastProc)
            stopScreenSharing(false)
        }
    }

    MsgBox {
        id: msgbox
        screen: rootWindow.screen
    }

    DevSelector {
        id: deviceSelector
        screen: rootWindow.screen
    }

    HandsUpStatus{
        id:handsUpStatusWindow
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    }

    MoreMenu {
        id: moreItemsMenu
        screen: rootWindow.screen
    }

    SSystemSound {
        id: systemSound
        screen: rootWindow.screen
    }

    Window {
        id: pauseWindow
        title: "ScreenSharingPauseToolBar"
        width: 220
        height: 32
        x: rootWindow.x + (rootWindow.width - width) / 2
        y: rootWindow.y + rootWindow.height + 6
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "#00000000"
        visible: rootWindow.visible && shareManager.ownerSharing && shareManager.paused
        Rectangle {
            id: idPauseBar
            anchors.fill: parent
            radius: 4
            color: "#FE3B30"
            RowLayout {
                anchors.fill: parent
                spacing: 0
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "#FFFFFF"
                    text:  shareManager.appMinimized ? qsTr("The share has been suspended, please restore the window") : qsTr("The share has been suspended")
                }
            }
        }
    }

    Rectangle {
        id: smallToolbar
        width: 220
        height: 36
        radius: 4
        visible: false
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#33333F" }
            GradientStop { position: 1.0; color: "#292933" }
        }

        Rectangle {
            height: 4
            width: parent.width
            anchors.top: parent.top
            color: "#33333F"
        }

        Image {
            id: netWorkQualityImage
            width: 13
            height: 13
            opacity: 1.0
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            source: {
                const netWorkQualityType = membersManager.netWorkQualityType
                if (MeetingStatus.NETWORKQUALITY_GOOD === netWorkQualityType){
                    return "qrc:/qml/images/public/icons/networkquality_good.svg"
                }
                else if (MeetingStatus.NETWORKQUALITY_GENERAL === netWorkQualityType){
                    return "qrc:/qml/images/public/icons/networkquality_general.svg"
                }
                else if (MeetingStatus.NETWORKQUALITY_BAD === netWorkQualityType){
                    return "qrc:/qml/images/public/icons/networkquality_bad.svg"
                }
                else {
                    return "qrc:/qml/images/public/icons/networkquality_unknown.svg"
                }
            }
        }
        Label {
            id: idMeetingID
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenterOffset: 10
            anchors.horizontalCenter : parent.horizontalCenter
            font.pixelSize: 14
            color: "#FFFFFF"
            text: {
                let title = qsTr('Meeting ID: ')
                if (meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_SHORT_ID_ONLY && meetingManager.shortMeetingId !== '') {
                    return title + meetingManager.shortMeetingId
                }
                return title + MeetingHelpers.prettyConferenceId(meetingManager.meetingId)
            }
        }
    }

    MouseEventSpy {
        id: mouseEventSpy
        onMousePosDetected: {
            if (mousePosX > rootWindow.x && mousePosX < rootWindow.x + rootWindow.width &&
                    mousePosY > rootWindow.y && mousePosY < rootWindow.y + rootWindow.height) {
                smallToolbar.visible = false
                fullToolbar.visible = true
                timer.restart()
            }
            lastMousePoint.x = mousePosX
            lastMousePoint.y = mousePosY
        }
    }

    Rectangle {
        id: fullToolbar
        width: toolbarLayout.width + 30
        height: 68
        radius: 8
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#292933"
            }
            GradientStop {
                position: 1.0
                color: "#212129"
            }
        }

        Rectangle {
            height: 8
            width: parent.width
            anchors.top: parent.top
            color: '#292933'
        }

        RowLayout {
            id:toolbarLayout
            height: parent.height
            spacing: 0
            Image {
                Layout.preferredWidth: 13
                Layout.leftMargin: 20
                Layout.preferredHeight: 13
                opacity: 1.0
                source: {
                    const netWorkQualityType = membersManager.netWorkQualityType
                    if (MeetingStatus.NETWORKQUALITY_GOOD === netWorkQualityType){
                        return "qrc:/qml/images/public/icons/networkquality_good.svg"
                    }
                    else if (MeetingStatus.NETWORKQUALITY_GENERAL === netWorkQualityType){
                        return "qrc:/qml/images/public/icons/networkquality_general.svg"
                    }
                    else if (MeetingStatus.NETWORKQUALITY_BAD === netWorkQualityType){
                        return "qrc:/qml/images/public/icons/networkquality_bad.svg"
                    }
                    else {
                        return "qrc:/qml/images/public/icons/networkquality_unknown.svg"
                    }
                }
            }

            ColumnLayout {
                spacing: 0
                Layout.preferredWidth: 130
                Label {
                    color: "#FFFFFF"
                    text: qsTr("Meeting ID")
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    color: "#FFFFFF"
                    text: {
                        if (meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_SHORT_ID_ONLY && meetingManager.shortMeetingId !== '') {
                            return meetingManager.shortMeetingId
                        }
                        return MeetingHelpers.prettyConferenceId(meetingManager.meetingId)
                    }
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            ToolSeparator {
                opacity: 0.1
                contentItem: Rectangle {
                    implicitWidth: 1
                    implicitHeight: 40
                    color: "#EBEDF0"
                }
            }

            MToolBar {
                id: idMeetingToolBar
                bSSToolbar: true
            }

            ToolSeparator {
                visible: 0 !== idMeetingToolBar.width
                opacity: 0.1
                contentItem: Rectangle {
                    implicitWidth: 1
                    implicitHeight: 40
                    color: "#EBEDF0"
                }
            }

            CustomButton {
                visible: Qt.platform.os === 'osx'
                Layout.preferredWidth: 76
                Layout.preferredHeight: 28
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: 18
                buttonRadius: 4
                text: qsTr("End")
                highlighted: true
                highNormalBkColor: "#FE3B30"
                highPushedBkColor: "#FE3B40"
                highBorderColor: "#FE3B30"
                onClicked: {
                    stopScreenSharing()
                }
            }

            Rectangle {
                id: endRectangle
                visible: Qt.platform.os === 'windows'
                Layout.preferredWidth: 102
                Layout.preferredHeight: 28
                Layout.alignment: Qt.AlignHCenter
                radius: 4
                color: "#FE3B30"
                CustomButton {
                    id: btnEnd
                    width: 48
                    height: 28
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    buttonRadius: 4
                    text: qsTr("End")
                    highlighted: true
                    highNormalBkColor: "#FE3B30"
                    highPushedBkColor: "#FE3B40"
                    highBorderColor: "#FE3B30"
                    font.pixelSize: 12
                    onClicked: {
                        stopScreenSharing()
                    }
                }

                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    width: parent.width - btnEnd.width - btnEnd.anchors.leftMargin - 15
                    height: parent.height
                    ToolSeparator {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: imageSystemSound.left
                        anchors.rightMargin: 1
                        contentItem: Rectangle {
                            implicitWidth: 1
                            implicitHeight: 10
                            color: "#FFFFFF"
                        }
                    }

                    Image {
                        id: imageSystemSound
                        height: 6
                        width: 6
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        source: 'qrc:/qml/images/meeting/footerbar/btn_show_device_down_normal.png'
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            const pos = endRectangle.mapToItem(null, 0, 0)
                            systemSound.screen = shareScreen
                            systemSound.x = Qt.binding(function(){ return pos.x + rootWindow.x + endRectangle.width - systemSound.width } )
                            systemSound.y = Qt.binding(function(){ return rootWindow.y + rootWindow.height + 10 })
                            systemSound.setVisible(!systemSound.visible)
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: smallToolbar
        onVisibleChanged: {
            console.log("[handsup] smallToolbar onVisibleChanged " + smallToolbar.visible)
            if(smallToolbar.visible){
                handsUpStatusWindow.visible = false
            }
            else{
                if(authManager.authAccountId !== membersManager.hostAccountId)
                    return

                if(membersManager.hostAccountId === authManager.authAccountId){
                    if(shareManager.shareAccountId.length === 0){
                        handsUpStatusWindow.visible = false
                        return
                    }
                }
                if(membersManager.audioHandsUpCount > 0 && undefined !== idMeetingToolBar.btnMembersCtrl){
                    handsUpStatusWindow.visible = true
                    const pos = idMeetingToolBar.btnMembersCtrl.mapToItem(null, 0, 0)
                    handsUpStatusWindow.x = Qt.binding(function(){ return pos.x + rootWindow.x + 16} )
                    handsUpStatusWindow.y = Qt.binding(function(){ return pos.y + rootWindow.y + rootWindow.height + 5 })
                    handsUpStatusWindow.tipText = membersManager.audioHandsUpCount
                }
            }
        }
    }

    Timer{
        id:handsupTimer
        interval: 200
        repeat: false
        onTriggered: {
            if(membersManager.audioHandsUpCount > 0){
                console.log("[handsup] timer to show tip")
                handsUpStatusWindow.visible = true
                handsUpStatusWindow.tipText = membersManager.audioHandsUpCount
                const pos = idMeetingToolBar.btnMembersCtrl.mapToItem(null, 0, 0)
                handsUpStatusWindow.x = Qt.binding(function(){ return pos.x + rootWindow.x + 16 } )
                handsUpStatusWindow.y = Qt.binding(function(){ return pos.y + rootWindow.y + rootWindow.height + 5 })
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
                return
            }
            if (deviceSelector.visible) {
                return
            }
            if (moreItemsMenu.visible) {
                return
            }
            if (systemSound.visible) {
                return
            }
            if (lastMousePoint.x > rootWindow.x && lastMousePoint.x < rootWindow.x + rootWindow.width &&
                    lastMousePoint.y > rootWindow.y && lastMousePoint.y < rootWindow.y + rootWindow.height) {
                return
            }

            handsUpStatusWindow.visible = false
            fullToolbar.visible = false
            smallToolbar.visible = true
            deviceSelector.visible = false
            moreItemsMenu.visible = false
            systemSound.visible = false
        }
    }

    Timer {
        id: posFixTimer
        repeat: false
        interval: 2000
        onTriggered: {
            for (let i = 0; i < Qt.application.screens.length; i++) {
                const tmpScreen = Qt.application.screens[i]
                if (shareScreen.name === tmpScreen.name) {
                    console.info("[ScreenToolbar] Fix pos of current screen, screen info:", tmpScreen.virtualX,
                                 tmpScreen.virtualY, tmpScreen.width, tmpScreen.height)
                    console.info('[ScreenToolbar] Current sharing screen info:', shareScreen.virtualX,
                                 shareScreen.virtualY, shareScreen.width, shareScreen.height)
                    if (shareScreen.virtualX !== tmpScreen.virtualX ||
                            shareScreen.virtualY !== tmpScreen.virtualY ||
                            shareScreen.width !== tmpScreen.width ||
                            shareScreen.height !== tmpScreen.height) {
                        stopScreenSharing()
                        return
                    }
                    break;
                }
            }
        }
    }

    Timer {
        id: resetSizeTimer
        repeat: false
        interval: 1000
        onTriggered: {
            rootWindow.x = Qt.binding(function() { return shareScreen !== undefined ? ((shareScreen.width - rootWindow.width) / 2) + shareScreen.virtualX : 0; })
            rootWindow.y = Qt.binding(function() { return shareScreen !== undefined ? shareScreen.virtualY : 0; })
            fullToolbar.visible = true
            fullToolbar.visible = false
            shareVideo.screen = shareScreen
            shareVideo.resetPosition()
        }
    }

    Connections {
        target: deviceSelector
        onVisibleChanged: {
            if (!deviceSelector.visible)
                timer.start()
        }
    }

    Connections {
        target: systemSound
        onVisibleChanged: {
            if (!systemSound.visible)
                timer.start()
        }
    }

    Connections {
        target: membersManager
        onUserJoinNotify: {
            if (rootWindow.visible && authManager.authAccountId === membersManager.hostAccountId) {
                ToastHelper.displayText(qsTr('%1 joined the meeting').arg(nickname), shareScreen)
            }
        }
        onUserLeftNotify: {
            if (rootWindow.visible && authManager.authAccountId === membersManager.hostAccountId) {
                ToastHelper.displayText(qsTr('%1 left from the meeting').arg(nickname), shareScreen)
            }
        }
        onHostAccountIdChangedSignal: {
            //in share scene,when member is sharing, this member is setted as host. new host must sync members handsUpStatus
            if (hostAccountId === authManager.authAccountId && oldhostAccountId !== authManager.authAccountId){
                if(membersManager.audioHandsUpCount > 0 && undefined !== idMeetingToolBar.btnMembersCtrl){
                    fullToolbar.visible = true
                    smallToolbar.visible = false
                    console.log("[handsup] new host set")
                    handsUpStatusWindow.visible = true
                    const pos = idMeetingToolBar.btnMembersCtrl.mapToItem(null, 0, 0)
                    handsUpStatusWindow.x = Qt.binding(function(){ return pos.x + rootWindow.x + 16 } )
                    handsUpStatusWindow.y = Qt.binding(function(){ return pos.y + rootWindow.y + rootWindow.height + 5 })
                    handsUpStatusWindow.tipText = membersManager.audioHandsUpCount
                }
            }

            if (rootWindow.visible && authManager.authAccountId === hostAccountId) {
                ToastHelper.displayText(qsTr('You have been set as host'), shareScreen)
            }
        }
    }

    Connections {
        target: deviceManager
        onRecordDeviceChangedNotify: {
            if (rootWindow.visible)
                GlobalToast.displayText(qsTr('Current record device "[%1]"').arg(deviceName), shareScreen)
        }
        onPlayoutDeviceChangedNotify: {
            if (rootWindow.visible)
                GlobalToast.displayText(qsTr('Current playout device "[%1]"').arg(deviceName), shareScreen)
        }
        onError: {
            toast.show(errorMessage)
        }
    }

    Connections {
        target: shareManager
        onScreenAdded: {
            if (shareManager.shareAccountId.length === 0) {
                return
            }
            console.info('New screen added, screen:', addedScreen, ', current sharing screen name:', shareScreen.name)
            posFixTimer.start()
        }

        onScreenRemoved: {
            if (shareManager.shareAccountId.length === 0) {
                return
            }
            console.info('Screen removed, screen:', removedScreen, ', current sharing screen name:', shareScreen.name)
            if (removedScreen === shareScreen.name) {
                rootWindow.hide()
                stopScreenSharing()
            } else {
                posFixTimer.start()
            }
        }

        onShareAccountIdChanged: {
            fullToolbar.visible = true
            smallToolbar.visible = false
            if(shareManager.shareAccountId === membersManager.hostAccountId && membersManager.hostAccountId.length !== 0){
                console.log("[handsup] handsupTimer.restart")
                handsupTimer.restart()
            }
        }

        onScreenSizeChanged:{
            resetSizeTimer.start()
        }
    }

    Connections {
        target: audioManager
        onUserAudioStatusChanged: {
            if (shareManager.shareAccountId !== authManager.authAccountId) {
                return
            }
            if (changedAccountId === authManager.authAccountId ) {
                if (deviceStatus === MeetingStatus.DEVICE_DISABLED_BY_HOST && meetingManager.meetingMuteCount !== 1 && authManager.authAccountId !== membersManager.hostAccountId) {
                    GlobalToast.displayText(qsTr('You have been muted by host'), shareScreen)
                }
                if (deviceStatus === MeetingStatus.DEVICE_NEEDS_TO_CONFIRM) {
                    if(authManager.authAccountId !== membersManager.hostAccountId){
                        msgbox.showMsgBox(qsTr('Open your microphone'), qsTr('The host applies to open your microphone, do you agree.'), function () {
                            audioManager.muteLocalAudio(false)
                        }, function () {}, rootWindow, false)
                    }
                    else{
                        audioManager.muteLocalAudio(false)
                    }
                }
            }
        }

        onHandsupStatusChanged:{
            if(membersManager.hostAccountId !== authManager.authAccountId && membersManager.hostAccountId !== shareManager.shareAccountId){
                return
            }
            if (undefined === idMeetingToolBar.btnMembersCtrl) {
                return
            }

            switch(status){
            case MeetingStatus.HAND_STATUS_RAISE:
                fullToolbar.visible = true
                smallToolbar.visible = false
                console.log("[handsup] new handsup request")
                handsUpStatusWindow.visible = true
                const pos = idMeetingToolBar.btnMembersCtrl.mapToItem(null, 0, 0)
                handsUpStatusWindow.x = Qt.binding(function(){ return pos.x + rootWindow.x + 16 } )
                handsUpStatusWindow.y = Qt.binding(function(){ return pos.y + rootWindow.y + rootWindow.height + 5 })
                handsUpStatusWindow.tipText = membersManager.audioHandsUpCount
                break
            case MeetingStatus.HAND_STATUS_DOWN:
            case MeetingStatus.HAND_STATUS_REJECT:
            case MeetingStatus.HAND_STATUS_AGREE:
                if(membersManager.audioHandsUpCount === 0){
                    handsUpStatusWindow.tipText = '';
                    handsUpStatusWindow.visible = false
                }
                else{
                    fullToolbar.visible = true
                    smallToolbar.visible = false
                    handsUpStatusWindow.tipText = membersManager.audioHandsUpCount
                }

                break
            }
        }
    }

    Connections {
        target: videoManager
        onUserVideoStatusChanged: {
            if (!rootWindow.visible || shareManager.shareAccountId !== authManager.authAccountId) {
                return
            }
            if (changedAccountId === authManager.authAccountId ) {
                if (deviceStatus === 3 && authManager.authAccountId !== membersManager.hostAccountId) {
                    GlobalToast.displayText(qsTr('Your camera has been disabled by the host'), shareScreen)
                }
                if (deviceStatus === 4 && deviceStatus !== 1) {
                    if (authManager.authAccountId !== membersManager.hostAccountId) {
                        msgbox.showMsgBox(qsTr('Open your camera'), qsTr('The host applies to open your video, do you agree.'), function () {
                            videoManager.disableLocalVideo(false)
                        }, function () {}, rootWindow, false)
                    } else {
                        videoManager.disableLocalVideo(false)
                    }
                }
            }
        }
    }

    Connections {
        target: rootWindow
        onClosing: {
            handsUpStatusWindow.visible = false
            rootWindow.hide()
            close.accepted = false
        }
    }

    Connections {
        target: meetingManager
        onMeetingStatusChanged: {
            switch(status){
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_ENDED:
                if (MessageBubble.visible) {
                    MessageBubble.hide()
                }
                if(chattingWindow.visible) {
                    chattingWindow.hide()
                }
                if(invitation.visible) {
                    invitation.hide()
                }
                if(liveSetting.visible) {
                    liveSetting.hide()
                }
                if (pauseWindow.visible) {
                    pauseWindow.hide()
                }
                break
            default:
                break
            }
        }
    }

    Connections {
        target: GlobalChatManager
        onNoNewMsgNotity:{
            chattingWindow.msgCount = 0
        }
    }

    Connections{
        target: handsUpStatusWindow
        onClick:{
            if(membersWindow.visible === true){
                membersWindow.raise()
                return
            }

            membersWindow.x = (shareScreen.width - membersWindow.width) / 2 + shareScreen.virtualX
            membersWindow.y = (shareScreen.height - membersWindow.height) / 2 + shareScreen.virtualY
            membersWindow.screen = shareScreen
            membersWindow.show()
            membersWindow.raise()
        }
    }

    Connections {
        target: moreItemManager
        onChatItemVisibleChanged: {
            if (!moreItemManager.chatItemVisible) {
                MessageBubble.hide()
                if (undefined !== chattingWindow) {
                    chattingWindow.hide()
                }
            }
        }

        onMangeParticipantsItemVisibleChanged: {
            if (!moreItemManager.mangeParticipantsItemVisible && !moreItemManager.participantsItemVisible) {
                handsUpStatusWindow.hide()
                membersWindow.hide()
            }
        }

        onParticipantsItemVisibleChanged: {
            if (!moreItemManager.mangeParticipantsItemVisible && !moreItemManager.participantsItemVisible) {
                handsUpStatusWindow.hide()
                membersWindow.hide()
            }
        }

        onInviteItemVisibleChanged: {
            if (invitation.visible && !moreItemManager.inviteItemVisible) {
                invitation.hide()
            }
        }
    }

    Connections {
        target: idMeetingToolBar
        onBtnAudioCtrlClicked: {
            audioManager.muteLocalAudio(audioManager.localAudioStatus === FooterBar.DeviceStatus.DeviceEnabled)
        }

        onBtnAudioSettingsClicked: {
            if (deviceSelector.visible) {
                deviceSelector.visible = false
            }
            const point = rootWindow.contentItem.mapFromItem(idMeetingToolBar.btnAudioSettings, 0, 0)
            deviceSelector.x = rootWindow.x + point.x + (idMeetingToolBar.btnAudioSettings.width - deviceSelector.width) / 2
            deviceSelector.y = rootWindow.y + rootWindow.height + 10
            deviceSelector.mode = DeviceSelector.DeviceSelectorMode.AudioMode
            deviceSelector.show()
        }

        onBtnVideoCtrlClicked: {
            videoManager.disableLocalVideo(videoManager.localVideoStatus === FooterBar.DeviceStatus.DeviceEnabled)
        }

        onBtnVideoSettingsClicked: {
            if (deviceSelector.visible) {
                deviceSelector.visible = false
            }
            const point = rootWindow.contentItem.mapFromItem(idMeetingToolBar.btnVideoSettings, 0, 0)
            deviceSelector.x = rootWindow.x + point.x + (idMeetingToolBar.btnVideoSettings.width - deviceSelector.width) / 2
            deviceSelector.y = rootWindow.y + rootWindow.height + 10
            deviceSelector.mode = DeviceSelector.DeviceSelectorMode.VideoMode
            deviceSelector.show()
        }

        onBtnInvitationClicked: {
            if (!shareManager.ownerSharing) {
                return
            }
            invitation.screen = shareScreen
            invitation.x = (shareScreen.width - invitation.width) / 2 + shareScreen.virtualX
            invitation.y = (shareScreen.height - invitation.height) / 2 + shareScreen.virtualY
            invitation.show()
        }

        onBtnMembersCtrlClicked: {
            if (!shareManager.ownerSharing) {
                return
            }
            membersWindow.x = (shareScreen.width - membersWindow.width) / 2 + shareScreen.virtualX
            membersWindow.y = (shareScreen.height - membersWindow.height) / 2 + shareScreen.virtualY
            membersWindow.screen = shareScreen
            membersWindow.show()
            membersWindow.raise()
        }

        onBtnChatClicked: {
            if (MessageBubble.visible) {
                MessageBubble.hide()
            }

            chattingWindow.screen = shareScreen
            chattingWindow.x = (shareScreen.width - chattingWindow.width) / 2 + shareScreen.virtualX
            chattingWindow.y = (shareScreen.height - chattingWindow.height) / 2 + shareScreen.virtualY
            chattingWindow.show()
        }

        onBtnMoreClicked: {
            const point = rootWindow.contentItem.mapFromItem(idMeetingToolBar.btnMore, 0, 0)
            moreItemsMenu.screen = shareScreen
            moreItemsMenu.x = rootWindow.x + point.x + (idMeetingToolBar.btnMore.width - moreItemsMenu.width) / 2
            moreItemsMenu.y = rootWindow.y + rootWindow.height + 10
            moreItemsMenu.show()
        }

        onBtnLiveClicked: {
            if (!shareManager.ownerSharing) {
                return
            }
            if(!liveSetting.visible) {
                liveSetting.screen = shareScreen
                liveSetting.x = (shareScreen.width - liveSetting.width) / 2 + shareScreen.virtualX
                liveSetting.y = (shareScreen.height - liveSetting.height) / 2 + shareScreen.virtualY
                liveSetting.modality = Qt.NonModal
                liveSetting.show()
            }
            else{
                liveSetting.raise()
            }
        }
    }

    function messageToastProc(msgCount, sender, content){
        if (undefined === idMeetingToolBar.btnChat) {
            return
        }

        GlobalChatManager.chatMsgCount = msgCount
        if(chattingWindow.visible){
            return
        }

        if (content.length !== 0){
            if (shareManager.shareAccountId === authManager.authAccountId){
                MessageBubble.screen = shareScreen
                MessageBubble.x = Qt.binding(function() { return shareScreen.virtualX + shareScreen.desktopAvailableWidth - MessageBubble.width})
                MessageBubble.y = Qt.binding(function() { return shareScreen.virtualY + shareScreen.desktopAvailableHeight - MessageBubble.height})
                MessageBubble.toastChatMessage(sender, content, true)
            }
        }
    }

    function stopScreenSharing(stop = true) {
        console.log("stopScreenSharing, stop: ", stop)
        if (stop)
            shareManager.stopScreenSharing(authManager.authAccountId)
        if(MessageBubble.visible)
            MessageBubble.hide()
        if (membersWindow.visible)
            membersWindow.hide()
        if(chattingWindow.visible)
            chattingWindow.hide()
        if (invitation.visible)
            invitation.hide()
        if(liveSetting.visible)
            liveSetting.hide()
        if (handsUpStatusWindow.visible)
            handsUpStatusWindow.visible = false
        if (deviceSelector.visible)
            deviceSelector.visible = false
        if (systemSound.visible)
            systemSound.hide()
        if (shareVideo.visible)
            shareVideo.hide()
        if (pauseWindow.visible)
            pauseWindow.hide()
    }

    function getTimer() {
        return Qt.createQmlObject("import QtQuick 2.15; Timer {}", rootWindow);
    }
}
