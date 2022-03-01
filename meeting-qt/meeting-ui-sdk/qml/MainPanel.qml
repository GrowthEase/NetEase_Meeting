import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import NetEase.Meeting.Settings 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.GlobalToast 1.0
import NetEase.Meeting.GlobalChatManager 1.0
import NetEase.Meeting.ScreenSaver 1.0
import NetEase.Meeting.MessageBubble 1.0

import "utils/dialogManager.js" as DialogManager
import "components"
import "share"
import "chattingroom"
import "invite"
import "live"

Rectangle {
    id: root
    anchors.fill: parent

    enum ViewMode {
        FocusViewMode,
        GridViewMode,
        WhiteboardMode,
        ShareMode,
        LoadingMode
    }

    property int viewMode: MainPanel.ViewMode.FocusViewMode
    property int currentPage: 1
    property int pageSize: 4
    property int msgCount: 0
    property var staticPoint: '0,0'
    property var lastPoint: '0,0'
    property string myNickname: ''
    property string defaultDuration: '00:00:00'
    property int latestMeetingStatus: -1
    property bool extensionsShow: membersBar.show || chatBar.show

    signal newMsgNotity(int msgCount, string sender, string text)

    Component.onCompleted: {
        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'))
        if (mainWindow.visibility === Window.FullScreen) {
            mainWindow.showNormal()
        }

        if (authManager.autoLoginMode) {
            authManager.autoLogin()
        }
    }

    onExtensionsShowChanged: {
        if (mainWindow.visibility === Window.Maximized || mainWindow.visibility === Window.FullScreen) {
        }else {
            loaderLayout.width = loaderLayout.width
        }
        sidebarVisibled = extensionsShow
        extensions.visible = extensionsShow
    }

    Shortcut {
        sequence: "Ctrl+V,Ctrl+S"
        onActivated: {
            videoManager.displayVideoStats = !videoManager.displayVideoStats
        }
    }

    CustomDialog {
        id: customDialog
    }

    CustomDialog {
        id: handsupDialog
        cancelBtnText: qsTr("Cancel")
        confirmBtnText: qsTr("HandsUpRaise")

        text:qsTr("Mute all")
        description:qsTr("This meeting has been turned on all mute by host,you can hands up to speak")
    }

    MuteConfirmDialog{
        id:muteConfirmDialog;
    }

    DeviceSelector {
        id: deviceSelector
        y: footerBar.y - height - 10
        onVisibleChanged: {
            if (visible)
                hideFooterBarTimer.stop()
            else
                hideFooterBarTimer.start()
        }
    }

    Information {
        id: popupMeetingInfo
        meetingHost: membersManager.hostAccountId
        meetingId: meetingManager.prettyMeetingId
        meetingPassword: meetingManager.meetingPassword
        meetingTopic: meetingManager.meetingTopic
        meetingSIPChannelId: meetingManager.meetingSIPChannelId
        meetingshortId: meetingManager.shortMeetingId
    }

    Invitation {
        id: invitation
    }

    MoreItemsMenu {
        id: moreItemsMenu
        y: footerBar.y - height - 10
        onVisibleChanged: {
            if (visible)
                hideFooterBarTimer.stop()
            else
                hideFooterBarTimer.start()
        }
    }

    MoreItemsMenuEx {
        id: moreItemsMenuEx
        y: footerBar.y - height - 10
        onVisibleChanged: {
            if (visible)
                hideFooterBarTimer.stop()
            else
                hideFooterBarTimer.start()
        }
    }

    SSSelector {
        id: shareSelector
        parent: mainLayout
    }

    ShareVideo {
        id: shareVideo
    }

    LiveSetting {
        id: liveSetting
        screen: mainWindow.screen
    }

    SSRequestPermission {
        id: requestPermission
        anchors.centerIn: parent
    }

    SSOutsideWindow {
        id: sSOutsideWindow
    }

    ScreenSaver {
        id: idScreenSaver
        screenSaverEnabled: mainWindow.visible || 0 !== shareManager.shareAccountId.length
    }

    Component {
        id: idTFieldPwd
        Item {
            property alias showError: idTFieldPwdError.visible
            property alias errorText: idTFieldPwdError.text
            property alias text: idTFieldPwdEx.text
            anchors.fill: parent
            CustomTextFieldEx {
                id: idTFieldPwdEx
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                placeholderText: qsTr("Please enter password")
                validator: RegExpValidator { regExp: /[0-9a-zA-Z]{4,20}/ }
            }
            Label {
                id: idTFieldPwdError
                anchors.top: idTFieldPwdEx.bottom
                anchors.topMargin: 4
                anchors.left: parent.left
                width: parent.width
                text: qsTr("Password Error")
                color: "#F24957"
                font.pixelSize: 14
                visible: false
            }
        }
    }

    CustomWindow {
        id: passwordWindow
        title: qsTr("Meeting Password")
        width: 400 + 20
        height: 214 + 20
        modality: Qt.platform.os === "osx" ? Qt.ApplicationModal : Qt.WindowModal
        loader.sourceComponent: idTFieldPwd
        submitText: qsTr("Join Meeting")
        property bool showError: false
        property string errorText: ''
        property string password

        onSubmitClicked: {
            submitEnabled = false
            loader.item.showError = false
            password = loader.item.text
            meetingManager.joinMeeting(loader.item.text)
        }

        onVisibleChanged: {
            if (visible) {
                showError = false
                loader.item.text = ""
                submitEnabled = Qt.binding(function() { return loader.item.text.trim().length >= 4 })
            }
        }

        onShowErrorChanged: {
            loader.item.showError = showError
            submitEnabled = Qt.binding(function() { return loader.item.text.trim().length >= 4 && password !== loader.item.text })
        }

        onErrorTextChanged: {
            loader.item.errorText = errorText
        }

        onCloseClicked: {
            meetingManager.cancelJoinMeeting()
        }
    }

    Item {
        id: mainLayoutEx
        anchors.fill: parent
        Rectangle {
            id: loaderLayout
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width - (extensions.visible ? extensions.width : 0)
            height: parent.height
            Loader {
                id: mainLoader
                anchors.fill: parent
            }

            ColumnLayout {
                spacing: 5
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.rightMargin: 4
                z: 1
                RowLayout {
                    spacing: 5
                    Layout.alignment: Qt.AlignRight
                    visible: meetingManager.meetingId.length !== 0
                    Rectangle {
                        id: infoContainer
                        Layout.preferredWidth: netWorkQualityToolButton.width + 8
                        Layout.preferredHeight: 21
                        color: "#CC313138"
                        visible: footerBar.height !== 0
                        radius: 2
                        Image {
                            anchors.centerIn: parent
                            width: 11
                            height: 11
                            source: 'qrc:/qml/images/meeting/icon_information.png'
                        }
                        MouseArea {
                            id: infoArea
                            anchors.fill: parent
                            onClicked: {
                                const popupPosition = infoContainer.mapToItem(pageLoader, -popupMeetingInfo.width + infoContainer.width, infoContainer.height + 5)
                                popupMeetingInfo.x = popupPosition.x
                                popupMeetingInfo.y = popupPosition.y
                                popupMeetingInfo.open()
                            }
                        }
                        Accessible.role: Accessible.Button
                        Accessible.name: "meetingInfo"
                        Accessible.onPressAction: if (enabled) infoArea.clicked(Qt.LeftButton)
                    }
                    Rectangle {
                        Layout.preferredWidth: netWorkQualityToolButton.width + 8
                        Layout.preferredHeight: 21
                        color: "#CC313138"
                        visible: footerBar.height !== 0
                        radius: 2
                        Image {
                            id: netWorkQualityToolButton
                            width: 13
                            height: 13
                            opacity: 1.0
                            anchors.centerIn: parent
                            source: {
                                const netWorkQualityType = membersManager.netWorkQualityType
                                if (MeetingStatus.NETWORKQUALITY_GOOD === netWorkQualityType) {
                                    return "qrc:/qml/images/public/icons/networkquality_good.svg"
                                } else if (MeetingStatus.NETWORKQUALITY_GENERAL === netWorkQualityType) {
                                    return "qrc:/qml/images/public/icons/networkquality_general.svg"
                                } else if (MeetingStatus.NETWORKQUALITY_BAD === netWorkQualityType) {
                                    return "qrc:/qml/images/public/icons/networkquality_bad.svg"
                                } else {
                                    return "qrc:/qml/images/public/icons/networkquality_unknown.svg"
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: liveTip
                        color: "#CC313138"
                        Layout.preferredWidth: 58
                        Layout.preferredHeight: 21
                        visible: false
                        radius: 2
                        RowLayout{
                            spacing: 4
                            anchors.centerIn: parent

                            Rectangle {
                                color: "#FE3B30"
                                radius: 3
                                Layout.preferredHeight: 6
                                Layout.preferredWidth: 6
                            }

                            Label {
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                text: qsTr("living")
                            }
                        }
                    }

                    Rectangle {
                        id: recordTip
                        color: "#CC313138"
                        Layout.preferredWidth: 58
                        Layout.preferredHeight: 21
                        visible: false//meetingManager.enableRecord
                        radius: 2
                        RowLayout{
                            spacing: 4
                            anchors.centerIn: parent

                            Rectangle {
                                color: "#FE3B30"
                                radius: 3
                                Layout.preferredHeight: 6
                                Layout.preferredWidth: 6
                            }

                            Label {
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                text: qsTr("recording")
                            }
                        }
                    }

                    Rectangle {
                        id: durationContainer
                        visible: meetingManager.showMeetingDuration
                        Layout.preferredWidth: labelDuration.width + 8
                        Layout.preferredHeight: 21
                        color: "#CC313138"
                        radius: 2
                        Label {
                            id: labelDuration
                            anchors.centerIn: parent
                            text: {
                                const meetingDuration = meetingManager.meetingDuration
                                if (0 === meetingDuration) {
                                    return defaultDuration
                                }else {
                                    return format_time(meetingDuration)
                                }
                            }
                            color: "#FFFFFF"
                            font.pixelSize: 12
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: screenToolButton.width + 8
                        Layout.preferredHeight: 21
                        color: "#CC313138"
                        visible: false//shareManager.shareAccountId.length !== 0
                        Image {
                            id: screenToolButton
                            width: 13
                            height: 13
                            opacity: 1.0
                            anchors.centerIn: parent
                            source: mainWindow.visibility === Window.FullScreen
                                    ? "qrc:/qml/images/public/icons/show_normal.png"
                                    : "qrc:/qml/images/public/icons/show_fullscreen.png"
                        }
                        MouseArea {
                            id: btnShowNormal
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = "#7F222222"
                            onExited: parent.color = "#CC313138"
                            onClicked: mainWindow.visibility === Window.FullScreen ? mainWindow.showNormal() : mainWindow.showFullScreen()
                        }
                    }
                }

                RowLayout {
                    id: activeSpeakerTootips
                    visible:false
                    Layout.alignment: Qt.AlignRight
                    Rectangle {
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: childrenRect.width + 4
                        color: "#CC313138"
                        radius: 2
                        RowLayout {
                            Layout.preferredHeight: 21
                            Layout.preferredWidth: childrenRect.width
                            spacing: 0
                            Label {
                                Layout.topMargin: 2
                                Layout.leftMargin: 4
                                text: qsTr("Speaking: ")
                                color: "#FFFFFF"
                                font.pixelSize: 12
                            }
                            Label {
                                id:speakernickname
                                Layout.topMargin: 2
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                //text: audioManager.activeSpeakerNickname
                            }
                        }
                    }
                }

                RowLayout {
                    id: fPs
                    visible: videoManager.displayVideoStats
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: childrenRect.width
                    Rectangle {
                        id: fpsItemContainer
                        Layout.fillHeight: true
                        Layout.preferredWidth: childrenRect.width + 4
                        color: "#7F333333"
                        radius: 2
                        FpsItem {
                            id: idFpsItem
                        }
                    }
                }
            }
            FooterBar {
                id: footerBar
                anchors.bottom: parent.bottom
                width: parent.width
                height: 68
                visible: viewMode !== MainPanel.ViewMode.LoadingMode
            }

            Rectangle {
                id:handsStatus
                visible: false
                height: 32
                width:32
                color: "#337EFF"
                radius: 2

                ColumnLayout{
                    spacing: 0
                    anchors.fill: parent
                    anchors.centerIn: parent
                    Image {
                        width: 16
                        height: 16
                        Layout.alignment: Qt.AlignHCenter
                        source: "qrc:/qml/images/meeting/hand_raised.svg"
                    }
                    Label {
                        id:handstip
                        text: qsTr("HandsUp")
                        Layout.alignment: Qt.AlignHCenter
                        color: "#ECEDEF"
                        font.pixelSize: 8
                        visible: true
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        if(authManager.authAccountId !== membersManager.hostAccountId)
                            handstip.text = qsTr("Cancel")
                    }
                    onExited: {
                        if(authManager.authAccountId !== membersManager.hostAccountId)
                            handstip.text = qsTr("HandsUp")
                    }

                    onClicked: {
                        if(authManager.authAccountId === membersManager.hostAccountId){
                            if(membersBar.visible===false)
                                footerBar.showMembers()
                        }
                        else{
                            customDialog.cancelBtnText = qsTr("Cancel")
                            customDialog.confirmBtnText = qsTr("OK")
                            customDialog.text = qsTr("Cancel HandsUp")
                            customDialog.description =qsTr("are you sure to cancel hands up")
                            customDialog.confirm.disconnect(disableLocalVideo)
                            customDialog.confirm.disconnect(leaveMeeting)
                            customDialog.confirm.disconnect(endMeeting)
                            customDialog.confirm.disconnect(muteHandsUp)
                            customDialog.confirm.disconnect(muteLocalAudio)
                            customDialog.confirm.connect(muteHandsDown)
                            customDialog.cancel.disconnect(unMuteLoaclAudio)
                            customDialog.open()
                        }
                    }
                }
            }

            HoverHandler {
                id: footerEventHanlder
                //                onHoveredChanged: {
                //                    if (footerEventHanlder.hovered) {
                //                        showFooterContainer.restart()
                //                        hideFooterBarTimer.restart()
                //                    } else {
                //                        hideFooterContainer.restart()
                //                        hideFooterBarTimer.stop()
                //                    }
                //                }
                onPointChanged: {
                    if (footerBar.height === 0 && point.position !== staticPoint) {
                        showFooterContainer.restart()
                        hideFooterBarTimer.restart()
                        staticPoint = point.position
                        return
                    }
                    if (point.position !== lastPoint) {
                        lastPoint = point.position;
                        hideFooterBarTimer.restart()
                    }
                }
            }
        }


        Rectangle {
            id: extensions
            visible: false
            anchors.top: parent.top
            anchors.left: loaderLayout.right
            height: parent.height
            width: defaultSiderbarWidth
            border.width: 1
            border.color: "#cdcdcd"
            onVisibleChanged: {
                if (visible) {
                    if (mainWindow.visibility !== Window.FullScreen && mainWindow.visibility !== Window.Maximized) {
                        mainWindow.width = mainWindow.width + defaultSiderbarWidth
                    }
                } else {
                    if (mainWindow.visibility !== Window.FullScreen && mainWindow.visibility !== Window.Maximized) {
                        mainWindow.width = mainWindow.width - defaultSiderbarWidth
                    }
                }
            }

            ToastManager {
                id: operator
            }

            ColumnLayout {
                anchors.fill: parent
                width: parent.width
                height: parent.height
                spacing: 0
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                anchors.bottomMargin: 1

                Sidebar {
                    id: membersBar
                    backgroundColor: "#FFFFFF"
                    visible: show
                    Layout.preferredWidth: defaultSiderbarWidth - 2
                    Layout.fillHeight: true
                    property bool show: false
                }

                Rectangle {
                    id: chatBar
                    visible: show
                    Layout.preferredWidth: parent.width
                    Layout.fillHeight: true
                    property bool show: false
                    property var msgtimeGap : undefined

                    Rectangle {
                        id: chatbusyContainer
                        anchors.fill: chatBar
                        color: "#99000000"
                        z: 999
                        visible: false

                        BusyIndicator {
                            id: busyIndicator
                            width: 50
                            height: 50
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

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.preferredHeight: 1
                            Layout.fillWidth: true
                            color: "#EBEDF0"
                            opacity: .6
                        }

                        Rectangle {
                            id:title
                            Layout.preferredHeight:{
                                if(membersBar.visible)
                                    return 40
                                else
                                    return 41
                            }
                            Layout.preferredWidth:  parent.width
                            Label {
                                anchors.centerIn: parent
                                font.weight: Font.Medium
                                font.pixelSize: 16
                                color: "#333333"
                                text: qsTr("chatroom")
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: 1
                            Layout.fillWidth: true
                            color: "#EBEDF0"
                            opacity: .6
                        }

                        Rectangle {
                            id:listviewlayout
                            Layout.preferredWidth:  parent.width
                            Layout.fillHeight: true
                            ChatListView {
                                id:chatroom
                                maxMsgUintWidth:224
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
                            opacity: .6
                        }

                        Rectangle {
                            id:input
                            Layout.preferredHeight: 67
                            Layout.preferredWidth: parent.width
                            Flickable {
                                id: scView
                                anchors.centerIn: parent
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
                                    leftPadding: 8
                                    rightPadding: leftPadding
                                    placeholderText: qsTr("Input a message and press Enter to send it...")
                                    placeholderTextColor: "#a09f9f"
                                    color: "#333333"
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

                                        //addToList("msg", messageField.text, myNickname, true)
                                        chatManager.sendIMTextMsg(messageField.text, "main")
                                        messageField.text = "";
                                        messageField.focus = true;
                                    }

                                    Keys.onEnterPressed: {
                                        if(text.match(/^[ ]*$/)){
                                            operator.show(qsTr("can not send empty message"), 1500)
                                            return;
                                        }
                                        //addToList("msg", messageField.text, myNickname, true)
                                        chatManager.sendIMTextMsg(messageField.text,"main")
                                        messageField.text = "";
                                        messageField.focus = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: busyContainer
        anchors.fill: mainLayoutEx
        visible: false
        color: "#99000000"
        ColumnLayout {
            anchors.centerIn: parent
            BusyIndicator {
                running: true
                Layout.preferredHeight: 50
                Layout.preferredWidth: 50
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: qsTr('Network has been disconnected, trying to reconnect.')
                color: "#FFFFFF"
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }
    }



    Timer {
        id: hideWindow
        repeat: false
        interval: 1000
        onTriggered: {
            mainWindow.setVisible(false)
            mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'))
        }
    }

    Timer {
        id: quitTimer
        repeat: false
        interval: 1000
        onTriggered: {
            // Qt.callLater(Qt.quit)
            authManager.autoLogout()
        }
    }

    Timer {
        id: hideFooterBarTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            if(whiteboardManager.whiteboardSharing){
                return
            }

            if (!deviceSelector.visible) {
                staticPoint = footerEventHanlder.point.position
                hideFooterContainer.restart()
            }
        }
    }

    Timer {
        id: showPasswordTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            if (!passwordWindow.visible) {
                const constPos = root.mapToGlobal(0, 0)
                passwordWindow.x = constPos.x + (root.width - passwordWindow.width) / 2
                passwordWindow.y = constPos.y + (root.height - passwordWindow.height) / 2
                passwordWindow.show()
            }
        }
    }

    Connections {
        target: globalManager
        onShowSettingsWindow: {
            SettingsWnd.displayPage(0)
        }
    }

    Connections {
        target: deviceManager
        onRecordDeviceChangedNotify: {
            if (mainWindow.visible)
                GlobalToast.displayText(qsTr('Current record device "[%1]"').arg(deviceName), mainWindow.screen)
        }
        onPlayoutDeviceChangedNotify: {
            if (mainWindow.visible)
                GlobalToast.displayText(qsTr('Current playout device "[%1]"').arg(deviceName), mainWindow.screen)
        }
        onError: {
            toast.show(errorMessage)
        }
    }

    Connections {
        target: authManager
        onLogin: {
            if (authStatus == 2 && meetingManager.autoStartMode) {
                meetingManager.autoStartMeeting()
            }
        }

    }

    Connections {
        target: meetingManager
        onActiveWindow: {
            if (mainWindow.visibility === Window.Minimized)
                mainWindow.showNormal()
            mainWindow.raise()
        }
        onMeetingStatusChanged: {
            console.log("Meeting status changed, status: " + status + "  code: " + errorCode + ", message: " + errorMessage)
            latestMeetingStatus = status
            switch (status) {
            case MeetingStatus.MEETING_IDLE:
                if (meetingManager.autoStartMode) {
                    GlobalToast.displayText(qsTr('Meeting has been finished'), mainWindow.screen)
                    quitTimer.start()
                }
                console.log("mainWindow visibility(MEETING_IDLE): " + mainWindow.visibility)
                if (Qt.platform.os === 'osx' && !hideWindow.running && !mainWindow.visible) {
                    mainWindow.showNormal()
                    mainWindow.setVisible(false)
                }
                break
            case MeetingStatus.MEETING_CONNECTING:
                break
            case MeetingStatus.MEETING_WAITING_VERIFY_PASSWORD:
                if (!mainWindow.visible) {
                    mainWindow.raiseOnTop()
                    busyContainer.visible = false
                    mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'))
                }
                passwordWindow.showError = false
                passwordWindow.errorText = ''
                switch (errorCode)
                {
                case 2014:
                    passwordWindow.errorText = errorMessage;
                    passwordWindow.showError = true
                    break
                case 2018:
                    passwordWindow.showError = false
                    break
                default:
                    break
                }
                showPasswordTimer.start()
                break
            case MeetingStatus.MEETING_PREPARING:
                closeAllDialog()
                mainWindow.raiseOnTop()
                busyContainer.visible = false
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'))
                break
            case MeetingStatus.MEETING_PREPARED:
                mainWindow.setVisible(true)
                break
            case MeetingStatus.MEETING_CONNECTED:
                console.info('Meeting connected, meeting duration:', meetingManager.meetingDuration)
                passwordWindow.setVisible(false)
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'))

                if(whiteboardManager.getAutoOpenWhiteboard()){
                    if(whiteboardManager.whiteboardSharing){
                        if(viewMode !== MainPanel.ViewMode.WhiteboardMode){
                            mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/WhiteboardPage.qml'))
                        }
                    }else{
                        whiteboardManager.openWhiteboard(authManager.authAccountId)
                    }
                }else{
                    if(whiteboardManager.whiteboardSharing){
                        if(viewMode !== MainPanel.ViewMode.WhiteboardMode){
                            mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/WhiteboardPage.qml'))
                        }
                    }
                }


                if(meetingManager.meetingId !== globalSettings.value('localLastConferenceId')){
                    globalSettings.setValue('localLastNickname', meetingManager.nickname)
                }

                globalSettings.setValue('localLastMeetingTopic', meetingManager.meetingTopic)
                globalSettings.setValue('localLastMeetingPassword', meetingManager.meetingPassword)
                globalSettings.setValue('localLastMeetingshortId', meetingManager.shortMeetingId)
                globalSettings.setValue('localLastMeetingUniqueId', meetingManager.meetingUniqueId)
                globalSettings.setValue('localLastConferenceId', meetingManager.meetingId)
                globalSettings.setValue('localLastChannelId', meetingManager.channelId)
                globalSettings.setValue('localLastSipId', meetingManager.meetingSIPChannelId)

                if (!meetingManager.hideChatroom)
                    chatManager.loginChatroom()
                deviceManager.getCurrentSelectedDevice()
                myNickname = meetingManager.nickname
                chatBar.msgtimeGap = new Date()
                busyContainer.visible = false
                hideFooterBarTimer.start()
                mainWindow.raise()

//                if(meetingManager.enableRecord) {
//                    GlobalToast.displayText(qsTr("meeting recording"), mainWindow.screen)
//                }
                break
            case MeetingStatus.MEETING_RECONNECTED:
                break
            case MeetingStatus.MEETING_CONNECT_FAILED:
                if (meetingManager.autoStartMode) {
                    GlobalToast.displayText(qsTr('Failed to join meeting'), mainWindow.screen)
                    quitTimer.start()
                }
                passwordWindow.setVisible(false)
                mainWindow.setVisible(false)
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'))
                break
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_MULTI_SPOT_LOGIN:
            case MeetingStatus.MEETING_ENDED:
                handsStatus.visible = false
                handstip.text = qsTr("HandsUp")
                console.log("mainWindow visibility: " + mainWindow.visibility)
                if (Qt.platform.os === 'osx' && (mainWindow.visibility === Window.FullScreen || mainWindow.visibility === Window.Maximized)) {
                    mainWindow.showNormal()
                    hideWindow.start()
                } else {
                    mainWindow.setVisible(false)
                    mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'))
                }
                popupMeetingInfo.close()
                passwordWindow.setVisible(false)
                membersBar.restore()
                chatroom.listmodel.clear()
                messageField.text = "";
                GlobalChatManager.noNewMsgNotity()
                chatManager.logoutChatroom()
                chatbusyContainer.visible = false
                closeAllDialog()
                myNickname = ""

                break
            case MeetingStatus.MEETING_CMD_CHANNEL_DISCONNECTED:
                busyContainer.visible = true
                break
            default:
                mainWindow.setVisible(false)
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'))
                break
            }
        }
        onMuteStatusNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId) {
                if (meetingManager.meetingMuted)
                    toast.show(qsTr('You have turned on all mute'))
                else
                    toast.show(qsTr('You have turned off all mute'))
            } else {

                if (meetingManager.meetingMuted && audioManager.localAudioStatus !== 3 && audioManager.localAudioStatus !== 2){
                    toast.show(qsTr('This meeting has been turned on all mute by host'))
                }
            }
        }
        onLockStatusNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId) {
                if (meetingManager.meetingLocked)
                    toast.show(qsTr('You have been locked this meeting'))
                else
                    toast.show(qsTr('You have been unlocked this meeting'))
            } /*else {
                if (meetingManager.meetingLocked)
                    toast.show(qsTr('This meeting has been locked by host'))
                else
                    toast.show(qsTr('This meeting has been unlocked by host'))
            }*/
        }
        onModifyNicknameResult:{
            if(success){
                toast.show(qsTr('modify nickname success'))
            }
            else{
                toast.show(qsTr('modify nickname fail'))
            }
        }

        onError: {
            if(errorCode === 2108){
                customDialog.cancelBtnText = qsTr("Cancel")
                customDialog.confirmBtnText = qsTr("HandsUpRaise")

                customDialog.text = qsTr("Mute all")
                customDialog.description = qsTr("This meeting has been turned on all mute by host,you can hands up to speak")
                customDialog.confirm.disconnect(disableLocalVideo)
                customDialog.confirm.disconnect(leaveMeeting)
                customDialog.confirm.disconnect(endMeeting)
                customDialog.confirm.disconnect(muteHandsDown)
                customDialog.confirm.disconnect(muteLocalAudio)
                customDialog.cancel.disconnect(unMuteLoaclAudio)
                customDialog.confirm.connect(muteHandsUp)
                customDialog.open()
                return;
            }
            else if(errorCode === 2110){
                audioManager.muteLocalAudio(false)
                return
            }

            if (errorMessage !== '') {
                toast.show(errorMessage)
            }
        }
    }

    Connections {
        target: audioManager
        onUserAudioStatusChanged: {
            if (shareManager.shareAccountId === authManager.authAccountId) {
                return
            }
            if (changedAccountId === authManager.authAccountId ) {
                if (deviceStatus === MeetingStatus.DEVICE_DISABLED_BY_HOST && meetingManager.meetingMuteCount !== 1
                        && authManager.authAccountId !== membersManager.hostAccountId) {
                    toast.show(qsTr("You have been muted by host"))
                }
                if (deviceStatus === MeetingStatus.DEVICE_NEEDS_TO_CONFIRM) {
                    if(authManager.authAccountId !== membersManager.hostAccountId){
                        customDialog.confirmBtnText = qsTr("OK")
                        customDialog.cancelBtnText = qsTr("Cancel")
                        customDialog.text = qsTr('Open your microphone')
                        customDialog.description = qsTr('The host applies to open your microphone, do you agree.')
                        customDialog.confirm.disconnect(disableLocalVideo)
                        customDialog.confirm.disconnect(leaveMeeting)
                        customDialog.confirm.disconnect(endMeeting)
                        customDialog.confirm.disconnect(muteHandsDown)
                        customDialog.confirm.disconnect(muteHandsUp)
                        customDialog.confirm.connect(muteLocalAudio)
                        customDialog.cancel.connect(unMuteLoaclAudio)
                        customDialog.open()
                    }
                    else{
                        audioManager.muteLocalAudio(false)
                    }
                }
            }
        }

        onActiveSpeakerChanged: {
            if (videoManager.focusAccountId.length === 0 &&
                    shareManager.shareAccountId.length === 0 &&
                    viewMode === MainPanel.ViewMode.FocusViewMode) {
                membersManager.getMembersPaging(pageSize, currentPage)
            }
        }

        onActiveSpeakerNicknameChanged : {
            if(audioManager.activeSpeakerNickname.length !== 0 && shareManager.shareAccountId.length !== 0){
                speakernickname.text = audioManager.activeSpeakerNickname;
                activeSpeakerTootips.visible = true;
            }
            else{
                if(activeSpeakerTootips.visible === true)
                    activeSpeakerTootips.visible = false;
            }
        }

        onHandsupStatusChanged:{
            switch(status){
            case MeetingStatus.HAND_STATUS_RAISE:
                var controlPos = 0
                if(accountId === authManager.authAccountId){
                    toast.show(qsTr("Hands raised up, please wait host handle."))
                    if (undefined !== footerBar.idMeetingToolBar.btnAudioCtrl) {
                        controlPos = footerBar.idMeetingToolBar.btnAudioCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return controlPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return controlPos.y - handsStatus.height - 40})
                        handstip.text = qsTr("HandsUp")
                        handsStatus.visible = true
                    }

                }else if(authManager.authAccountId === membersManager.hostAccountId){
                    if(membersManager.audioHandsUpCount > 0){
                        handstip.text = membersManager.audioHandsUpCount
                        if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                            controlPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0)
                            handsStatus.x = Qt.binding(function() {return controlPos.x + handsStatus.width / 2})
                            handsStatus.y = Qt.binding(function() {return controlPos.y - handsStatus.height - 40})
                            handsStatus.visible = true
                        }
                    }


                }
                break
            case MeetingStatus.HAND_STATUS_DOWN:
                if(accountId === authManager.authAccountId && accountId !== membersManager.hostAccountId){
                    handsStatus.visible = false
                    handstip.text = qsTr("HandsUp")
                }
                else if(authManager.authAccountId === membersManager.hostAccountId){
                    if(membersManager.audioHandsUpCount == 0){
                        handsStatus.visible = false
                    }
                    else{
                        handstip.text = membersManager.audioHandsUpCount
                    }
                }
                break
            case MeetingStatus.HAND_STATUS_REJECT:
                if(accountId === authManager.authAccountId){
                    toast.show(qsTr("the host have refused your handsup request"))
                    handsStatus.visible = false
                    handstip.text = qsTr("HandsUp")
                }
                else if(authManager.authAccountId === membersManager.hostAccountId){
                    if(membersManager.audioHandsUpCount == 0){
                        handsStatus.visible = false
                    }
                    else{
                        handstip.text = membersManager.audioHandsUpCount
                    }
                }
                break
            case MeetingStatus.HAND_STATUS_AGREE:
                if(accountId === authManager.authAccountId){
                    toast.show(qsTr("you have been ummute bt most,you can speak freely."))
                    handsStatus.visible = false
                    handstip.text = qsTr("HandsUp")
                }
                else if(authManager.authAccountId === membersManager.hostAccountId){
                    if(membersManager.audioHandsUpCount == 0){
                        handsStatus.visible = false
                        handstip.text = qsTr("HandsUp")
                    }
                    else{
                        handstip.text = membersManager.audioHandsUpCount
                    }
                }
                break
            }

        }

        onError: {
            toast.show(errorMessage)
        }
    }

    Connections {
        target: videoManager
        onUserVideoStatusChanged: {
            if (shareManager.shareAccountId === authManager.authAccountId) {
                return
            }
            if (changedAccountId === authManager.authAccountId ) {
                if (deviceStatus === 3 && authManager.authAccountId !== membersManager.hostAccountId) {
                    toast.show(qsTr("Your camera has been disabled by the host"))
                }
                if (deviceStatus === 4 && deviceStatus !== 1) {
                    if (authManager.authAccountId !== membersManager.hostAccountId){

                        if(audioManager.localAudioStatus === 4){
                            audioManager.muteLocalAudio(true)
                        }

                        customDialog.confirmBtnText = qsTr("OK")
                        customDialog.cancelBtnText = qsTr("Cancel")
                        customDialog.text = qsTr('Open your camera')
                        customDialog.description = qsTr('The host applies to open your video, do you agree.')
                        customDialog.confirm.disconnect(muteLocalAudio)
                        customDialog.confirm.disconnect(leaveMeeting)
                        customDialog.confirm.disconnect(endMeeting)
                        customDialog.confirm.disconnect(muteHandsDown)
                        customDialog.confirm.disconnect(muteHandsUp)
                        customDialog.cancel.disconnect(unMuteLoaclAudio)
                        customDialog.confirm.connect(disableLocalVideo)
                        customDialog.open()
                    } else {
                        videoManager.disableLocalVideo(false)
                    }
                }
            }
        }
        onFocusAccountIdChanged: {
            console.info('Focus account Id changed, old focus:', oldSpeaker, ', new focus:', newSpeaker, ', current account:', authManager.authAccountId)
            if (newSpeaker !== '' && newSpeaker === authManager.authAccountId)
                toast.show(qsTr('You have been set as active speaker.'))
            if (oldSpeaker !== oldSpeaker && oldSpeaker === authManager.authAccountId)
                toast.show(qsTr('You have been unset of active speaker.'))
            if (oldSpeaker !== newSpeaker) {
                membersManager.getMembersPaging(pageSize, currentPage)
            }
        }
        onError:{
            toast.show(errorMessage)
        }
    }

    Connections {
        target: membersManager
        onUserJoinNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId)
                toast.show(qsTr('%1 joined the meeting').arg(nickname))
        }
        onUserLeftNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId)
                toast.show(qsTr('%1 left from the meeting').arg(nickname))
        }
        onHostAccountIdChangedSignal: {

            if(oldhostAccountId === authManager.authAccountId){
                if(handsStatus.visible){
                    handsStatus.visible = false
                    handstip.text = qsTr("HandsUp")
                }
            }
            //host rejoin the meeting
            if(hostAccountId === oldhostAccountId && hostAccountId === authManager.authAccountId){
                if(membersManager.audioHandsUpCount > 0) {
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl && membersManager.audioHandsUpCount > 0) {
                        handstip.text = membersManager.audioHandsUpCount
                        if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                            var controlPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0)
                            handsStatus.x = Qt.binding(function() {return controlPos.x + handsStatus.width / 2})
                            handsStatus.y = Qt.binding(function() {return controlPos.y - handsStatus.height - 40})
                            handsStatus.visible = true
                        }
                    }
                }
                return
            }

            if (hostAccountId === authManager.authAccountId && oldhostAccountId !== authManager.authAccountId){
                showFooterContainer.restart()
                toast.show(qsTr('You have been set as host'))
                handsStatus.visible = false
                if(membersManager.audioHandsUpCount > 0) {
                    if (undefined !== footerBar.idMeetingToolBar.btnAudioCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnAudioCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                        handstip.text = membersManager.audioHandsUpCount
                        if(handsStatus.visible === false)
                            handsStatus.visible = true
                    }
                }
            }
        }

        onNicknameChanged:{
            if( authManager.authAccountId === accountId){
                globalSettings.setValue("localLastNickname", nickname)
            }
        }
    }

    Timer {
        id: macShareTimer
        running: false
        repeat: false
        interval: 1000
        onTriggered: {
            shareSelector.close()
            mainWindow.setVisible(false)
            if (sharedWnd !== undefined) {
                sharedWnd.show()
            }
        }
    }

    Connections {
        target: shareManager
        onShareAccountIdChanged: {
            console.info("Screen sharing status changed: ", shareManager.shareAccountId)
            if (shareManager.shareAccountId.length !== 0) {
                if (shareManager.shareAccountId === authManager.authAccountId) {
                    //if member start sharing screen, auto put his hands down
                    if(authManager.authAccountId !== membersManager.hostAccountId && audioManager.handsUpStatus === true){
                        if(audioManager.handsUpStatus)
                            audioManager.handsUpToSpeak(false);
                    }

                    if (Qt.platform.os === "windows") {
                        shareSelector.close()
                        mainWindow.setVisible(false)
                        if (sharedWnd !== undefined) {
                            sharedWnd.show()
                        }
                    } else {
                        if (mainWindow.visibility === Window.FullScreen) {
                            mainWindow.showNormal()
                            macShareTimer.restart()
                        } else {
                            shareSelector.close()
                            mainWindow.setVisible(false)
                            if (sharedWnd !== undefined) {
                                sharedWnd.show()
                            }
                        }
                    }
                } else {
                    if (viewMode !== MainPanel.ViewMode.FocusViewMode)
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'))
                    membersManager.getMembersPaging(pageSize, currentPage)
                }
            } else {
                if (mainWindow.visibility !== Window.Windowed) {
                    mainWindow.setVisible(true)
                }

                if(SettingsWnd.visible){
                    SettingsWnd.raise()
                }

                if(membersManager.hostAccountId === authManager.authAccountId && membersManager.audioHandsUpCount > 0){
                    handstip.text = membersManager.audioHandsUpCount
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl && membersManager.audioHandsUpCount > 0) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                        handsStatus.visible = true
                    }
                }

                if (sharedWnd !== undefined) {
                    sharedWnd.hide()
                    mainWindow.raiseOnTop()
                }
                if (viewMode !== MainPanel.ViewMode.FocusViewMode)
                    mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'))
                membersManager.getMembersPaging(pageSize, currentPage)
            }
        }

        onError: {
            toast.show(errorMessage)
        }

        onCloseScreenShareByHost: {
            toast.show(qsTr('The host has terminated your sharing'))
        }
    }

    Connections {
        target: caption
        onClose: {
            if (Qt.platform.os === 'osx' && MeetingStatus.MEETING_IDLE === latestMeetingStatus) {
                console.log('latestMeetingStatus is MeetingStatus.MEETING_IDLE')
                mainWindow.showNormal()
                mainWindow.setVisible(false)
                return
            }

            if (authManager.authAccountId === membersManager.hostAccountId) {
                DialogManager.dynamicDialogEx(qsTr('End Meeting'), qsTr('Do you want to quit this meeting?'), function () {
                    meetingManager.leaveMeeting(false)
                }, function () {
                    meetingManager.leaveMeeting(true)
                })
            } else {
                customDialog.confirmBtnText = qsTr("OK")
                customDialog.cancelBtnText = qsTr("Cancel")
                customDialog.text = qsTr('Exit')
                customDialog.description = qsTr('Do you want to quit this meeting?')
                customDialog.confirm.disconnect(muteLocalAudio)
                customDialog.confirm.disconnect(disableLocalVideo)
                customDialog.confirm.disconnect(endMeeting)
                customDialog.confirm.disconnect(muteHandsDown)
                customDialog.confirm.disconnect(muteHandsUp)
                customDialog.cancel.disconnect(unMuteLoaclAudio)
                customDialog.confirm.connect(leaveMeeting)
                customDialog.open()
            }
        }
    }

    Connections {
        target: mainWindow
        onWidthChanged: {
            // Fix footer in center of window
            footerBar.y = parent.height - footerBar.height

            if (mainWindow.visibility !== Window.FullScreen && mainWindow.visibility !== Window.Maximized) {
                const rightSide = mainWindow.x + mainWindow.width
                if (rightSide > Screen.width) {
                    if (!adjustWindow())
                        centerInScreen()
                }

                const bottomSide = mainWindow.y + mainWindow.height
                const taskbarHeight = Qt.platform.os === 'windows' ? 60 : 0
                if (bottomSide > Screen.height - taskbarHeight) {
                    if (!adjustWindow())
                        centerInScreen()
                }
            }

            loaderLayout.width = Qt.binding(function(){ return loaderLayout.parent.width - (extensions.visible ? extensions.width : 0) })
        }
        onBeforeClose: {
            if (Qt.platform.os === 'osx' && MeetingStatus.MEETING_IDLE === latestMeetingStatus) {
                console.log('latestMeetingStatus is MeetingStatus.MEETING_IDLE')
                mainWindow.showNormal()
                mainWindow.setVisible(false)
                return
            }

            if (authManager.authAccountId === membersManager.hostAccountId)
            {
                DialogManager.dynamicDialogEx(qsTr('End Meeting'), qsTr('Do you want to quit this meeting?'), function () {
                    meetingManager.leaveMeeting(false)
                }, function () {
                    meetingManager.leaveMeeting(true)
                })
            }
            else
            {
                customDialog.confirmBtnText = qsTr("OK")
                customDialog.cancelBtnText = qsTr("Cancel")
                customDialog.text = qsTr('Exit')
                customDialog.description = qsTr('Do you want to quit this meeting?')
                customDialog.confirm.disconnect(muteLocalAudio)
                customDialog.confirm.disconnect(disableLocalVideo)
                customDialog.confirm.disconnect(endMeeting)
                customDialog.confirm.disconnect(muteHandsDown)
                customDialog.confirm.disconnect(muteHandsUp)
                customDialog.cancel.disconnect(unMuteLoaclAudio)
                customDialog.confirm.connect(leaveMeeting)
                customDialog.open()
            }
        }
        onVisibleChanged: {
            console.log("mainWindow onVisibleChanged: ", mainWindow.visible)
            if (mainWindow.visible) {
                if (chatBar.visible) {
                    if (chatroom.msglistView.atYEnd) {
                        footerBar.recvNewChatMsg(0,"","")
                        msgCount = 0
                        chatroom.msglistView.positionViewAtEnd()
                        if (msgTipBtn.visible){
                            msgTipBtn.visible = false
                        }
                    }
                }
                if (mainWindow.visibility !== Window.FullScreen &&
                        mainWindow.visibility !== Window.Maximized) {
                    adjustWindow()
                }
                showFooterContainer.restart()
                hideFooterBarTimer.restart()
            } else {
                //                if (chatroom.msglistView.atYEnd) {
                //                    GlobalChatManager.noNewMsgNotity()
                //                }
                chatBar.show = false
                membersBar.show = false
            }
            popupMeetingInfo.close()
            SettingsManager.setMainWindowVisible(mainWindow.visible)
        }
        onVisibilityChanged:{
            console.log("mainWindow onVisibilityChanged: ", mainWindow.visibility)
            if (mainWindow.visibility === Window.Maximized) {

            } else if (mainWindow.visibility === Window.Windowed) {
                if (extensions.visible) {
                    mainWindow.width = defaultWindowWidth + defaultSiderbarWidth
                } else {
                    mainWindow.width = defaultWindowWidth
                }
                adjustWindow()
            } else {
                messageField.focus = false;
            }
        }
    }

    Connections {
        target: chatManager
        onRecvMsgSiganl:{
            if(status != 200){
                operator.show(qsTr("send message fail"));
                return
            }
            else{
                if(msg.sendFlag === "main" || msg.sendFlag === "share")
                    addToList(msg.msgType, msg.content, msg.nickName, true)
                else
                    addToList(msg.msgType, msg.content, msg.nickName, false)
            }
        }

        onError : {
            // busyNotice.text = qsTr("chartoom errorcode: %1").arg(error_code)
            // chatbusyContainer.visible = true;
            // messageField.focus = false
        }
        onDisconnect:{
            console.log("chatroom disconnect code : " + code + " chatbusyContainer.visible :" + chatbusyContainer.visible)
            switch(code) {
            case 0:
                chatbusyContainer.visible = false
                messageField.focus = true
                break;
            case 1:
                busyNotice.text = qsTr("trying to connect chatroom")
                chatbusyContainer.visible = true;
                messageField.focus = false
                break;
            case 2:
                busyNotice.text = qsTr("trying to relogin chatroom")
                chatbusyContainer.visible = true;
                messageField.focus = false
                chatManager.reloginChatroom();
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
        target: whiteboardManager

        onWhiteboardSharingChanged: {
            if(whiteboardManager.whiteboardSharing){
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/WhiteboardPage.qml'));
            }
        }

        onWhiteboardCloseByHost: {
            toast.show(qsTr('The host has terminated your sharing'))
        }
    }

    Timer {
        id: showChatBarTimer
        repeat: false
        interval: 50
        onTriggered: {
            if (chatBar.visible) {
                messageField.focus = true
                footerBar.recvNewChatMsg(0,"","")
                msgCount = 0
                chatroom.msglistView.positionViewAtEnd()
                if (msgTipBtn.visible) {
                    msgTipBtn.visible = false
                }
            } else{
                messageField.focus = false
            }
        }
    }

    Connections{
        target: chatBar
        onVisibleChanged:{
            showChatBarTimer.restart()
        }

    }

    Connections {
        target: moreItemManager
        onChatItemVisibleChanged: {
            if (!moreItemManager.chatItemVisible) {
                chatBar.show = false
                MessageBubble.hide()
            }
        }

        onMangeParticipantsItemVisibleChanged: {
            if (!moreItemManager.mangeParticipantsItemVisible && !moreItemManager.participantsItemVisible) {
                membersBar.show = false
                handsStatus.visible = false
            }
        }

        onParticipantsItemVisibleChanged: {
            if (!moreItemManager.mangeParticipantsItemVisible && !moreItemManager.participantsItemVisible) {
                membersBar.show = false
                handsStatus.visible = false
            }
        }

        onInviteItemVisibleChanged: {
            if (invitation.visible && !moreItemManager.inviteItemVisible) {
                invitation.visible = false
            }
        }
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
        target: chatroom.verScrollBar
        onPositionChanged: {
            if(shareManager.shareAccountId === authManager.authAccountId){
                if (chatroom.msglistView.atYEnd){
                    chatroom.msglistView.positionViewAtEnd()
                    footerBar.recvNewChatMsg(0,"","")
                }
            }
            else{
                if (chatroom.msglistView.atYEnd){
                    GlobalChatManager.noNewMsgNotity()
                    chatroom.msglistView.positionViewAtEnd()
                    if (msgTipBtn.visible){
                        msgTipBtn.visible = false;
                    }
                }
            }
        }
    }

    Connections{
        target: footerBar
        onWidthChanged:{
            if(handsStatus.visible === true){
                if(authManager.authAccountId === membersManager.hostAccountId){
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                    }
                }
                else{
                    if (undefined !== footerBar.idMeetingToolBar.btnAudioCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnAudioCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                    }
                }
            }
        }

        onHeightChanged:{
            if(handsStatus.visible === true){
                if(authManager.authAccountId === membersManager.hostAccountId){
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                    }
                }
                else{
                    if (undefined !== footerBar.idMeetingToolBar.btnAudioCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnAudioCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                    }
                }
            }
        }
    }

    Connections{
        target: mainWindow
        onWidthChanged:{
            if(handsStatus.visible === true){
                if(authManager.authAccountId === membersManager.hostAccountId){
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                    }
                }
                else{
                    if (undefined !== footerBar.idMeetingToolBar.btnAudioCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnAudioCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                    }
                }
            }
        }

        onHeightChanged:{
            if(handsStatus.visible === true){
                if(authManager.authAccountId === membersManager.hostAccountId){
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                    }
                }
                else{
                    if (undefined !== footerBar.idMeetingToolBar.btnAudioCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnAudioCtrl.mapToItem(mainLayout, 0, 0)
                        handsStatus.x = Qt.binding(function() {return handsStatusPos.x + handsStatus.width / 2})
                        handsStatus.y = Qt.binding(function() {return handsStatusPos.y - handsStatus.height - 40})
                    }
                }
            }
        }
    }

    ParallelAnimation {
        id: showFooterContainer
        NumberAnimation {
            target: footerBar
            properties: "height"
            from: 0
            to: 68
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    ParallelAnimation {
        id: hideFooterContainer
        NumberAnimation {
            target: footerBar
            properties: "height"
            from: 68
            to: 0
            duration: 300
            easing.type: Easing.Linear
        }
    }

    Connections {
        target: liveManager
        onLiveStateChanged:{
            liveTip.visible = isLive;
            console.log("onLiveStateChanged")
        }
    }

    function muteHandsUp(){
        customDialog.confirm.disconnect(muteHandsUp)
        audioManager.handsUpToSpeak(true);

    }

    function muteHandsDown(){
        customDialog.confirm.disconnect(muteHandsDown)
        if(audioManager.handsUpStatus){
            audioManager.handsUpToSpeak(false)
        }
    }

    function muteLocalAudio(){
        audioManager.muteLocalAudio(false)
        customDialog.confirm.disconnect(muteLocalAudio)
    }
    function unMuteLoaclAudio(){
        audioManager.muteLocalAudio(true)
        customDialog.confirm.disconnect(unMuteLoaclAudio)
    }

    function disableLocalVideo(){
        videoManager.disableLocalVideo(false)
        customDialog.confirm.disconnect(disableLocalVideo)
    }

    function leaveMeeting(){
        if(audioManager.handsUpStatus){
            audioManager.handsUpToSpeak(false)
        }
        meetingManager.leaveMeeting(false)
        customDialog.confirm.disconnect(leaveMeeting)
    }

    function endMeeting(){
        meetingManager.leaveMeeting(true)
        customDialog.confirm.disconnect(endMeeting)
    }

    function closeAllDialog(){
        if (membersWindow.visible === true){
            membersWindow.hide()
        }
        if (invitation.visible === true){
            invitation.close()
        }
        if(liveSetting.visible === true){
            liveSetting.close()
        }
        if (SettingsWnd.visible === true){
            SettingsWnd.hide();
        }

        if (sharedWnd !== undefined) {
            sharedWnd.hide()
            sharedWnd.destroy()
            sharedWnd = undefined
        }

        deviceSelector.close()
        shareSelector.close()
        requestPermission.close()
        customDialog.close()
    }

    function appendZero(obj) {
        if(obj<10)
            return "0" +""+ obj;
        else
            return obj;
    }

    function format_time(sec) {
        return [parseInt(sec/3600), parseInt(sec/60 % 60), sec % 60].join(":").replace(/\b(\d)\b/g, "0$1");
    }

    function addToList(type, text, nickName, me) {
        if (text.length <= 0 || text.match(/^[ ]*$/)) {
            return;
        }

        if ( me === false && type === "msg") {
            ++msgCount;
        }

        var current = new Date().getTime()
        var startTime = chatBar.msgtimeGap.getTime()

        var gap = (current-startTime)
        var oneday = parseInt(gap/1000/3600/24)
        //update time
        chatBar.msgtimeGap = new Date()

        //in one day  insert time
        if (oneday === 0) {

            if (gap/1000 >= 300 && chatroom.listmodel.count >= 1) {
                //append one timestamp
                chatroom.msglistView.msgTimeTip = true
                chatroom.msglistView.model.append({"msgType":"time","content": Qt.formatDateTime(new Date(), "hh:mm"), "sentByMe": false,"nickName":""});
            } else {
                chatroom.msglistView.msgTimeTip = false
            }
        } else if (oneday === 1 && chatroom.listmodel.count >= 1) {
            chatroom.msglistView.msgTimeTip = true
            chatroom.msglistView.model.append({"msgType":"time","content": Qt.formatDateTime(new Date(), "hh:mm"), "sentByMe": false,"nickName":""});
        }

        //console.log("msgtype = " + type)
        chatroom.msglistView.appendByme = me

        chatroom.msglistView.model.append({"msgType":type,"content": text, "sentByMe": me,"nickName":nickName});
        //var scollbar = Math.abs(verScrollBar.position + verScrollBar.visualSize)

        if (me) {
            if(shareManager.shareAccountId !== authManager.authAccountId)
                chatroom.msglistView.positionViewAtEnd()

        } else {
            if (chatBar.visible){
                if (chatroom.msglistView.atYEnd && shareManager.shareAccountId !== authManager.authAccountId) {
                    chatroom.msglistView.positionViewAtEnd()
                    //msgCount = 0;
                } else {
                    footerBar.recvNewChatMsg(msgCount,nickName,text)
                    if (!msgTipBtn.visible){
                        msgTipBtn.visible = true
                    }
                }

            } else{
                footerBar.recvNewChatMsg(msgCount,nickName,text)
                //msglistView.positionViewAtEnd()
            }
        }
    }
}
