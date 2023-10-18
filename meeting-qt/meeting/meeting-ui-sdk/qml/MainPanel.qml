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
import NetEase.Settings.SettingsStatus 1.0
import NetEase.Members.Status 1.0
import QtQuick.Dialogs
import QtCore 6.4
import "utils/dialogManager.js" as DialogManager
import "components"
import "share"
import "chattingroom"
import "invite"
import "live"
import "meeting"

Rectangle {
    id: root
    enum AudioVolumeLevel {
        Level_1 = 1,
        Level_2,
        Level_3,
        Level_4,
        Level_5
    }
    enum ViewMode {
        FocusViewMode,
        FocusViewLeftToRightMode,
        GridViewMode,
        WhiteboardMode,
        LoadingMode
    }

    property var cameraDynamicDialog: undefined
    property int currentPage: 1
    property string defaultDuration: '00:00:00'
    property bool hasShowRemainingTip: false
    property bool isNewMeetingLayout: true
    property var lastPoint: '0,0'
    property int latestMeetingStatus: -1
    property var microphoneDynamicDialog: undefined
    property int msgCount: 0
    property string myNickname: ''
    property int networkQualityBadTimes: 0
    property int pageSize: 4
    property bool showRightList: true
    property bool showTopList: true
    property bool spacePressed: false
    property int splitViewCurrentViewMode: SplitPage.ViewMode.FocusView
    property var splitViewDefaultState: undefined
    property int splitViewLastViewMode: SplitPage.ViewMode.FocusView
    property var splitViewState: undefined
    property var staticPoint: '0,0'
    property var tempDynamicDialog: undefined
    property var tempDynamicDialogEx: undefined
    property bool temporarilyUnmute: false
    property int videoLayout: layoutChooser.current
    property int viewMode: MainPanel.ViewMode.FocusViewMode

    signal newMsgNotity(int msgCount, string sender, string text)

    function appendZero(obj) {
        if (obj < 10)
            return "0" + "" + obj;
        else
            return obj;
    }
    function closeAllDialog() {
        if (footerBar.tempDynamicDialogEx !== undefined && footerBar.tempDynamicDialogEx !== null) {
            footerBar.tempDynamicDialogEx.close();
        }
        if (membersWindow.visible === true) {
            membersWindow.hide();
        }
        if (invitation.visible === true) {
            invitation.close();
        }
        if (invitationList.visible === true) {
            invitationList.close();
        }
        if (liveSetting.visible === true) {
            liveSetting.close();
        }
        if (SettingsWnd.visible === true) {
            SettingsWnd.hideWindow();
        }
        if (sharedWnd !== undefined) {
            sharedWnd.hide();
            sharedWnd.destroy();
            sharedWnd = undefined;
        }
        deviceSelector.close();
        shareSelector.close();
        requestPermission.close();
        customDialog.close();
        if (tempDynamicDialogEx !== undefined && tempDynamicDialogEx !== null)
            tempDynamicDialogEx.close();
        if (microphoneDynamicDialog !== undefined && microphoneDynamicDialog !== null)
            microphoneDynamicDialog.close();
        if (cameraDynamicDialog !== undefined && cameraDynamicDialog !== null)
            cameraDynamicDialog.close();
    }
    function disableLocalVideo() {
        videoManager.disableLocalVideo(true);
        customDialog.confirm.disconnect(disableLocalVideo);
    }
    function enableLocalVideo() {
        videoManager.disableLocalVideo(false);
        customDialog.confirm.disconnect(enableLocalVideo);
    }
    function endMeeting() {
        meetingManager.leaveMeeting(true);
        customDialog.confirm.disconnect(endMeeting);
    }
    function format_time(sec) {
        return [parseInt(sec / 3600), parseInt(sec / 60 % 60), sec % 60].join(":").replace(/\b(\d)\b/g, "0$1");
    }
    function getAudioVolumeSourceImage(level) {
        switch (level) {
        case MainPanel.AudioVolumeLevel.Level_1:
            return "qrc:/qml/images/meeting/volume/volume_level_1.png";
        case MainPanel.AudioVolumeLevel.Level_2:
            return "qrc:/qml/images/meeting/volume/volume_level_2.png";
        case MainPanel.AudioVolumeLevel.Level_3:
            return "qrc:/qml/images/meeting/volume/volume_level_3.png";
        case MainPanel.AudioVolumeLevel.Level_4:
            return "qrc:/qml/images/meeting/volume/volume_level_4.png";
        case MainPanel.AudioVolumeLevel.Level_5:
            return "qrc:/qml/images/meeting/volume/volume_level_5.png";
        default:
            return "qrc:/qml/images/meeting/volume/volume_level_1.png";
        }
    }
    function leaveMeeting() {
        if (membersManager.handsUpStatus) {
            membersManager.handsUp(false);
        }
        meetingManager.leaveMeeting(false);
        customDialog.confirm.disconnect(leaveMeeting);
    }
    function muteHandsDown() {
        customDialog.confirm.disconnect(muteHandsDown);
        if (membersManager.handsUpStatus) {
            membersManager.handsUp(false);
        }
    }
    function muteHandsUp() {
        customDialog.confirm.disconnect(muteHandsUp);
        if (meetingManager.meetingMuted && !meetingManager.meetingAllowSelfAudioOn) {
            membersManager.handsUp(true);
        }
    }
    function muteLocalAudio() {
        audioManager.muteLocalAudio(false);
        customDialog.confirm.disconnect(muteLocalAudio);
    }
    function showMaxHubTip() {
        deviceManager.selectMaxHubDevice(DeviceSelector.DeviceType.PlayoutType);
        customDialog.confirm.disconnect(showMaxHubTip);
    }
    function unMuteLoaclAudio() {
        audioManager.muteLocalAudio(true);
        customDialog.confirm.disconnect(unMuteLoaclAudio);
    }

    anchors.fill: parent
    color: "#000000"

    Component.onCompleted: {
        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'));
        if (mainWindow.visibility === Window.FullScreen) {
            mainWindow.showNormal();
        }
        if (authManager.autoLoginMode) {
            authManager.autoLogin();
        }
    }
    onSpacePressedChanged: {
        if (!SettingsManager.enableUnmuteBySpace) {
            return;
        }
        if (spacePressed) {
            console.log("SpacePressed start...");
            if (audioManager.localAudioStatus === MeetingStatus.DEVICE_ENABLED) {
                return;
            }
            var enterTemporarilyUnmute = false;
            if (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole) {
                enterTemporarilyUnmute = true;
            } else {
                if (!meetingManager.meetingMuted) {
                    enterTemporarilyUnmute = true;
                } else {
                    if (meetingManager.meetingAllowSelfAudioOn) {
                        enterTemporarilyUnmute = true;
                    }
                }
            }
            if (enterTemporarilyUnmute) {
                audioManager.muteLocalAudio(false);
                temporarilyUnmute = true;
                console.log("temporarilyUnmute start...");
            }
        } else {
            console.log("SpacePressed end...");
            if (temporarilyUnmute) {
                audioManager.muteLocalAudio(true);
                temporarilyUnmute = false;
                console.log("temporarilyUnmute end...");
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+V,Ctrl+S"

        onActivated: {
            videoManager.displayVideoStats = !videoManager.displayVideoStats;
        }
    }
    CustomDialog {
        id: customDialog
    }
    CustomDialog {
        id: handsupDialog
        cancelBtnText: qsTr("Cancel")
        confirmBtnText: qsTr("HandsUpRaise")
        description: qsTr("This meeting has been turned on all mute by host,you can hands up to speak")
        text: qsTr("Mute all")
    }
    MuteConfirmDialog {
        id: muteConfirmDialog
    }
    DeviceSelector {
        id: deviceSelector
        y: footerBar.y - height - 10

        onVisibleChanged: {
            if (visible)
                hideFooterBarTimer.stop();
            else
                hideFooterBarTimer.start();
        }
    }
    Information {
        id: popupMeetingInfo
        meetingHost: membersManager.hostAccountId
        meetingId: meetingManager.prettyMeetingId
        meetingInviteUrl: meetingManager.meetingInviteUrl
        meetingPassword: meetingManager.meetingPassword
        meetingSIPChannelId: meetingManager.meetingSIPChannelId
        meetingTopic: meetingManager.meetingTopic
        meetingshortId: meetingManager.shortMeetingNum
    }
    LayoutChooser {
        id: layoutChooser
        enableFocusLeftToRight: {
            if (membersManager.count === 1)
                return false;
            return true;
        }
        enableGallery: {
            if (shareManager.shareAccountId.length !== 0)
                return false;
            if (membersManager.count === 1)
                return false;
            return true;
        }

        onCurrentChanged: {
            if (current === LayoutChooser.VideoLayout.Gallery && mainLoader.source !== 'qrc:/qml/GalleryPage.qml') {
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/GalleryPage.qml'));
            }
            if (current === LayoutChooser.VideoLayout.FocusTopToBottom && mainLoader.source !== 'qrc:/qml/FocusPage.qml') {
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'));
            }
            if (current === LayoutChooser.VideoLayout.FocusLeftToRight && mainLoader.source !== 'qrc:/qml/FocusPage.qml') {
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/SplitPage.qml'));
            }
        }
    }
    NetWorkQualityInformation {
        id: popupNetWorkQualityInfo
    }
    Invitation {
        id: invitation
        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(invitation) : shareManager.removeExcludeShareWindow(invitation);
            }
        }
    }
    InvitationList {
        id: invitationList
        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(invitationList) : shareManager.removeExcludeShareWindow(invitationList);
            }
        }
    }
    MoreItemsMenu {
        id: moreItemsMenu
        y: footerBar.y - height - 10

        onVisibleChanged: {
            visible ? hideFooterBarTimer.stop() : hideFooterBarTimer.start();
        }
    }
    MoreItemsMenuEx {
        id: moreItemsMenuEx
        y: footerBar.y - height - 10

        onVisibleChanged: {
            visible ? hideFooterBarTimer.stop() : hideFooterBarTimer.start();
        }
    }
    SSSelector {
        id: shareSelector
        parent: mainLayout
    }
    ShareVideo {
        id: shareVideo
        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(shareVideo) : shareManager.removeExcludeShareWindow(shareVideo);
            }
        }
    }
    LiveSetting {
        id: liveSetting
        screen: mainWindow.screen

        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(liveSetting) : shareManager.removeExcludeShareWindow(liveSetting);
            }
        }
    }
    SSRequestPermission {
        id: requestPermission
        anchors.centerIn: parent
    }
    SSOutsideWindow {
        id: sSOutsideWindow
        onVisibleChanged: {
            if (Qt.platform.os === 'windows') {
                visible ? shareManager.addExcludeShareWindow(sSOutsideWindow) : shareManager.removeExcludeShareWindow(sSOutsideWindow);
            }
        }
    }
    ScreenSaver {
        id: idScreenSaver
        screenSaverEnabled: mainWindow.visible || 0 !== shareManager.shareAccountId.length
    }
    Component {
        id: idTFieldPwd
        Item {
            property alias errorText: idTFieldPwdError.text
            property alias showError: idTFieldPwdError.visible
            property alias text: idTFieldPwdEx.text

            anchors.fill: parent

            CustomTextFieldEx {
                id: idTFieldPwdEx
                anchors.left: parent.left
                anchors.top: parent.top
                placeholderText: qsTr("Please enter password")
                width: parent.width

                validator: RegularExpressionValidator {
                    regularExpression: /[0-9]{4,1000}/
                }
            }
            Label {
                id: idTFieldPwdError
                anchors.left: parent.left
                anchors.top: idTFieldPwdEx.bottom
                anchors.topMargin: 4
                color: "#F24957"
                font.pixelSize: 14
                text: qsTr("Password Error")
                visible: false
                width: parent.width
            }
        }
    }
    CustomWindow {
        id: passwordWindow

        property string errorText: ''
        property string password
        property bool showError: false

        height: 214 + 20
        loader.sourceComponent: idTFieldPwd
        modality: Qt.platform.os === "osx" ? Qt.ApplicationModal : Qt.WindowModal
        submitText: qsTr("Join Meeting")
        title: qsTr("Meeting Password")
        width: 400 + 20

        onCloseClicked: {
            meetingManager.cancelJoinMeeting();
        }
        onErrorTextChanged: {
            loader.item.errorText = errorText;
        }
        onShowErrorChanged: {
            loader.item.showError = showError;
            submitEnabled = Qt.binding(function () {
                    return loader.item.text.trim().length >= 4 && password !== loader.item.text;
                });
        }
        onSubmitClicked: {
            submitEnabled = false;
            loader.item.showError = false;
            password = loader.item.text;
            meetingManager.joinMeeting(loader.item.text);
        }
        onVisibleChanged: {
            if (visible) {
                showError = false;
                loader.item.text = "";
                submitEnabled = Qt.binding(function () {
                        return loader.item.text.trim().length >= 4;
                    });
            }
        }
    }
    Item {
        id: mainLayoutEx
        Keys.enabled: true
        anchors.fill: parent

        Keys.onReleased: {
            if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                root.spacePressed = false;
            }
        }
        Keys.onSpacePressed: {
            if (event.isAutoRepeat && !temporarilyUnmute) {
                root.spacePressed = true;
            }
        }
        onActiveFocusChanged: {
            if (!activeFocus) {
                if (SettingsManager.enableUnmuteBySpace && temporarilyUnmute && root.spacePressed) {
                    audioManager.muteLocalAudio(true);
                    temporarilyUnmute = false;
                    console.log("temporarilyUnmute end by lose focus...");
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true

            onClicked: {
                mainLayoutEx.forceActiveFocus();
                mouse.accepted = false;
            }
        }
        Rectangle {
            id: loaderLayout
            anchors.left: parent.left
            anchors.top: parent.top
            color: "black"
            height: parent.height
            width: parent.width - (extensions.visible ? extensions.width : 0)

            Loader {
                id: mainLoader
                anchors.fill: parent

                onSourceChanged: {
                    console.info("mainLoader changed, page:", source);
                    if (source == 'qrc:/qml/LoadingPage.qml') {
                        if (Qt.platform.os === 'windows') {
                            mainWindow.width = defaultWindowWidth;
                            mainWindow.height = defaultWindowHieght;
                            mainWindow.x = (Screen.width - mainWindow.width) / 2 + Screen.virtualX;
                            mainWindow.y = (Screen.height - mainWindow.height) / 2 + Screen.virtualY;
                        }
                    }
                    if (source == 'qrc:/qml/FocusPage.qml') {
                        layoutChooser.current = LayoutChooser.VideoLayout.FocusTopToBottom;
                    }
                    if (source == 'qrc:/qml/SplitPage.qml') {
                        layoutChooser.current = LayoutChooser.VideoLayout.FocusLeftToRight;
                    }
                    if (source == 'qrc:/qml/GalleryPage.qml') {
                        layoutChooser.current = LayoutChooser.VideoLayout.Gallery;
                    }
                }
            }
            ColumnLayout {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.top: parent.top
                anchors.topMargin: 4
                spacing: 5
                z: 1

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 5
                    visible: meetingManager.meetingId.length !== 0

                    Rectangle {
                        id: infoContainer
                        Accessible.name: "meetingInfo"
                        Accessible.role: Accessible.Button
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: infoToolButton.width + 10
                        color: "#CC313138"
                        radius: 2
                        visible: footerBar.height !== 0

                        Accessible.onPressAction: if (enabled)
                            infoArea.clicked(Qt.LeftButton)
                        onVisibleChanged: {
                            infoArea.hoverEnabled = visible;
                        }

                        Image {
                            id: infoToolButton
                            anchors.centerIn: parent
                            height: 11
                            mipmap: true
                            source: 'qrc:/qml/images/meeting/icon_information.png'
                            width: 11
                        }
                        MouseArea {
                            id: infoArea
                            anchors.fill: parent
                            hoverEnabled: false

                            onEntered: {
                                popupMeetingInfo.stopClose();
                                const popupPosition = infoContainer.mapToItem(pageLoader, -popupMeetingInfo.width + infoContainer.width, infoContainer.height + 5);
                                popupMeetingInfo.x = popupPosition.x;
                                popupMeetingInfo.y = popupPosition.y;
                                popupMeetingInfo.closePolicy = Popup.CloseOnEscape;
                                popupMeetingInfo.open();
                            }
                            onExited: {
                                if (footerBar.height !== 0)
                                    popupMeetingInfo.startClose();
                            }
                        }
                    }
                    Rectangle {
                        id: netWorkQualityContainer
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: netWorkQualityToolButton.width + 8
                        color: "#CC313138"
                        radius: 2
                        visible: footerBar.height !== 0

                        onVisibleChanged: {
                            netWorkQualityArea.hoverEnabled = visible;
                        }

                        Image {
                            id: netWorkQualityToolButton
                            anchors.centerIn: parent
                            height: 13
                            mipmap: true
                            opacity: 1.0
                            source: {
                                const netWorkQualityType = membersManager.netWorkQualityType;
                                switch (netWorkQualityType) {
                                case MeetingStatus.NETWORKQUALITY_GOOD:
                                    return "qrc:/qml/images/public/icons/networkquality_good.svg";
                                case MeetingStatus.NETWORKQUALITY_GENERAL:
                                    return "qrc:/qml/images/public/icons/networkquality_general.svg";
                                case MeetingStatus.NETWORKQUALITY_BAD:
                                    return "qrc:/qml/images/public/icons/networkquality_bad.svg";
                                default:
                                    return "qrc:/qml/images/public/icons/networkquality_good.svg";
                                }
                            }
                            width: 13
                        }
                        MouseArea {
                            id: netWorkQualityArea
                            anchors.fill: parent
                            hoverEnabled: false

                            onEntered: {
                                popupNetWorkQualityInfo.stopClose();
                                const popupNetWorkQualityPosition = netWorkQualityContainer.mapToItem(pageLoader, -popupNetWorkQualityInfo.width + netWorkQualityContainer.width, netWorkQualityContainer.height + 5);
                                popupNetWorkQualityInfo.x = popupNetWorkQualityPosition.x;
                                popupNetWorkQualityInfo.y = popupNetWorkQualityPosition.y;
                                popupNetWorkQualityInfo.closePolicy = Popup.CloseOnEscape;
                                popupNetWorkQualityInfo.open();
                            }
                            onExited: {
                                if (footerBar.height !== 0)
                                    popupNetWorkQualityInfo.startClose();
                            }
                        }
                    }
                    Rectangle {
                        id: liveTip
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: {
                            if (SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage) {
                                return 150;
                            } else if (SettingsStatus.UILanguage_en === SettingsManager.uiLanguage) {
                                return 80;
                            } else {
                                return 58;
                            }
                        }
                        color: "#CC313138"
                        radius: 2
                        visible: false

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Rectangle {
                                Layout.preferredHeight: 6
                                Layout.preferredWidth: 6
                                color: "#FE3B30"
                                radius: 3
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
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: 58
                        color: "#CC313138"
                        radius: 2
                        visible: false//meetingManager.enableRecord

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Rectangle {
                                Layout.preferredHeight: 6
                                Layout.preferredWidth: 6
                                color: "#FE3B30"
                                radius: 3
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
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: labelDuration.width + 8
                        color: "#CC313138"
                        radius: 2
                        visible: meetingManager.showMeetingDuration

                        Label {
                            id: labelDuration
                            Accessible.name: "duration"
                            anchors.centerIn: parent
                            color: "#FFFFFF"
                            font.pixelSize: 12
                            text: {
                                const meetingDuration = meetingManager.meetingDuration;
                                if (0 === meetingDuration) {
                                    return defaultDuration;
                                } else {
                                    return format_time(meetingDuration);
                                }
                            }
                            width: Qt.platform.os === 'osx' ? 52 : undefined
                        }
                    }
                    Rectangle {
                        id: layoutChooserContainer
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: chooserContainer.width + 8
                        color: "#CC313138"
                        radius: 2
                        visible: membersManager.count > 1

                        Accessible.onPressAction: if (enabled)
                            layoutChooserArea.clicked(Qt.LeftButton)
                        onVisibleChanged: {
                            layoutChooserArea.hoverEnabled = visible;
                            if (!visible)
                                layoutChooser.close();
                        }

                        RowLayout {
                            id: chooserContainer
                            anchors.centerIn: parent
                            spacing: 4

                            Image {
                                Layout.preferredHeight: 11
                                Layout.preferredWidth: 13
                                mipmap: true
                                source: {
                                    if (videoLayout === LayoutChooser.VideoLayout.FocusTopToBottom) {
                                        return "qrc:/qml/images/meeting/layout_focus_top_to_bottom_white.svg";
                                    }
                                    if (videoLayout === LayoutChooser.VideoLayout.FocusLeftToRight) {
                                        return "qrc:/qml/images/meeting/layout_focus_left_to_right_white.svg";
                                    }
                                    if (videoLayout === LayoutChooser.VideoLayout.Gallery) {
                                        return "qrc:/qml/images/meeting/layout_gallery_white.svg";
                                    }
                                    return "qrc:/qml/images/meeting/layout_focus_top_to_bottom_white.svg";
                                }
                            }
                            Label {
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                text: qsTr("View")
                            }
                            Image {
                                Layout.preferredHeight: 12
                                Layout.preferredWidth: 12
                                mipmap: true
                                source: layoutChooser.visible ? "qrc:/qml/images/public/button/btn_up_white.svg" : "qrc:/qml/images/public/button/btn_down_white.svg"
                            }
                        }
                        MouseArea {
                            id: layoutChooserArea
                            anchors.fill: parent
                            hoverEnabled: false

                            onEntered: {
                                layoutChooser.stopClose();
                                const popupPosition = layoutChooserContainer.mapToItem(pageLoader, -layoutChooser.width + layoutChooserContainer.width, layoutChooserContainer.height + 5);
                                layoutChooser.x = popupPosition.x;
                                layoutChooser.y = popupPosition.y;
                                layoutChooser.closePolicy = Popup.CloseOnEscape;
                                layoutChooser.open();
                            }
                            onExited: {
                                if (footerBar.height !== 0)
                                    layoutChooser.startClose();
                            }
                        }
                    }
                    Rectangle {
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: screenToolButton.width + 8
                        color: "#CC313138"
                        visible: false//shareManager.shareAccountId.length !== 0

                        Image {
                            id: screenToolButton
                            anchors.centerIn: parent
                            height: 13
                            mipmap: true
                            opacity: 1.0
                            source: mainWindow.visibility === Window.FullScreen ? "qrc:/qml/images/public/icons/show_normal.png" : "qrc:/qml/images/public/icons/show_fullscreen.png"
                            width: 13
                        }
                        MouseArea {
                            id: btnShowNormal
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: mainWindow.visibility === Window.FullScreen ? mainWindow.showNormal() : mainWindow.showFullScreen()
                            onEntered: parent.color = "#7F222222"
                            onExited: parent.color = "#CC313138"
                        }
                    }
                }
                RowLayout {
                    id: activeSpeakerTootips
                    Layout.alignment: Qt.AlignRight
                    visible: false

                    Rectangle {
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: speakersContainer.childrenRect.width + 4
                        color: "#CC313138"
                        radius: 2

                        RowLayout {
                            id: speakersContainer
                            height: 21
                            spacing: 0

                            Label {
                                Layout.leftMargin: 4
                                Layout.topMargin: 2
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                text: qsTr("Speaking: ")
                            }
                            Label {
                                id: speakernickname
                                Layout.topMargin: 2
                                color: "#FFFFFF"
                                font.pixelSize: 12
                            }
                        }
                    }
                }
                RowLayout {
                    id: speakers
                    Layout.alignment: Qt.AlignRight
                    visible: false

                    Rectangle {
                        id: speaker
                        Layout.maximumWidth: 260
                        Layout.preferredHeight: 21
                        Layout.preferredWidth: childrenRect.width
                        color: "#CC313138"
                        radius: 2

                        RowLayout {
                            Layout.maximumWidth: 254
                            anchors.left: parent.left
                            anchors.leftMargin: 0
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Image {
                                id: microphoneImg
                                height: 14
                                mipmap: true
                                source: "qrc:/qml/images/meeting/microphone.svg"
                                width: 14
                            }
                            CustomToolSeparator {
                                id: helloline
                                Layout.leftMargin: 0
                                opacity: 0.8
                                width: 1

                                contentItem: Rectangle {
                                    implicitHeight: 21
                                    implicitWidth: 1
                                    width: 1

                                    gradient: Gradient {
                                        GradientStop {
                                            color: "#292938"
                                            position: 0.0
                                        }
                                        GradientStop {
                                            color: "#1B1B22"
                                            position: 1.0
                                        }
                                    }
                                }
                            }
                            Label {
                                Layout.alignment: Qt.AlignVCenter
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                text: qsTr("Speaking: ")
                            }
                            Label {
                                id: speakersNickname
                                Layout.maximumWidth: 160
                                Layout.rightMargin: 4
                                ToolTip.text: speakersNickname.text
                                ToolTip.visible: ma.containsMouse ? speakersNickname.text.length !== 0 && speakersNickname.truncated : false
                                background: null
                                color: "#FFFFFF"
                                elide: Text.ElideRight
                                font.pixelSize: 12
                            }
                            MouseArea {
                                id: ma
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                hoverEnabled: true
                            }
                        }
                    }
                }
                RowLayout {
                    id: fPs
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: childrenRect.width
                    visible: videoManager.displayVideoStats

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
                height: 68
                visible: viewMode !== MainPanel.ViewMode.LoadingMode
                width: parent.width
            }
            Rectangle {
                id: handsStatus
                color: "#337EFF"
                height: 32
                radius: 2
                visible: false
                width: 32

                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    spacing: 0

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        height: 16
                        mipmap: true
                        source: "qrc:/qml/images/meeting/hand_raised.svg"
                        width: 16
                    }
                    Label {
                        id: handstip
                        Layout.alignment: Qt.AlignHCenter
                        color: "#ECEDEF"
                        font.pixelSize: 8
                        text: qsTr("HandsUp")
                        visible: true
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                            if (membersBar.visible === false)
                                footerBar.showMembers();
                        } else {
                            customDialog.cancelBtnText = qsTr("Cancel");
                            customDialog.confirmBtnText = qsTr("OK");
                            customDialog.text = qsTr("Cancel HandsUp");
                            customDialog.description = qsTr("are you sure to cancel hands up");
                            customDialog.confirm.disconnect(enableLocalVideo);
                            customDialog.confirm.disconnect(leaveMeeting);
                            customDialog.confirm.disconnect(endMeeting);
                            customDialog.confirm.disconnect(muteHandsUp);
                            customDialog.confirm.disconnect(muteLocalAudio);
                            customDialog.confirm.disconnect(showMaxHubTip);
                            customDialog.confirm.connect(muteHandsDown);
                            customDialog.cancel.disconnect(disableLocalVideo);
                            customDialog.cancel.disconnect(unMuteLoaclAudio);
                            customDialog.open();
                        }
                    }
                    onEntered: {
                        if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole)
                            handstip.text = qsTr("Cancel");
                    }
                    onExited: {
                        if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole)
                            handstip.text = qsTr("HandsUp");
                    }
                }
            }
            HoverHandler {
                id: footerEventHanlder
                onPointChanged: {
                    if (footerBar.height === 0 && point.position !== staticPoint) {
                        showFooterContainer.restart();
                        hideFooterBarTimer.restart();
                        staticPoint = point.position;
                        return;
                    }
                    if (point.position !== lastPoint) {
                        lastPoint = point.position;
                        hideFooterBarTimer.restart();
                    }
                }
            }
            CustomTipArea {
                id: remainingTip
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 30
                height: 50
                visible: false
                width: 250

                onSigCloseClicked: {
                    showRemainingTipTimer.stop();
                    hasShowRemainingTip = false;
                    remainingTip.visible = false;
                }
            }
            Rectangle {
                id: recVolume
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 128
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.rgba(0, 0, 0, 0.7)
                height: 100
                radius: 6
                visible: temporarilyUnmute
                width: 100

                ColumnLayout {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 17
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 17
                    spacing: 6

                    Image {
                        id: imgVolume
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 40
                        mipmap: true
                        source: "qrc:/qml/images/meeting/volume/volume_level_1.png"
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        color: "#ffffff"
                        text: qsTr("unmute")
                    }
                }
            }
        }
        Rectangle {
            id: extensions
            Accessible.name: "chatroom_sidebar"
            anchors.left: loaderLayout.right
            anchors.top: parent.top
            border.color: "#cdcdcd"
            border.width: 1
            height: parent.height
            visible: membersBar.show || chatBar.show
            width: defaultSiderbarWidth

            onVisibleChanged: {
                if (visible) {
                    if (mainWindow.visibility !== Window.FullScreen && mainWindow.visibility !== Window.Maximized) {
                        mainWindow.width = mainWindow.width + defaultSiderbarWidth;
                        if (Qt.platform.os === 'windows' && (mainWindow.x + mainWindow.width) > (Screen.virtualX + Screen.width)) {
                            mainWindow.x = (Screen.width - mainWindow.width) / 2 + Screen.virtualX;
                        }
                    }
                } else {
                    if (mainWindow.visibility !== Window.FullScreen && mainWindow.visibility !== Window.Maximized) {
                        mainWindow.width = mainWindow.width - defaultSiderbarWidth;
                    }
                }
                mainWindow.sidebarShown = visible;
            }

            ToastManager {
                id: operator
            }
            ColumnLayout {
                anchors.bottomMargin: 1
                anchors.fill: parent
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                height: parent.height
                spacing: 0
                width: parent.width

                Sidebar {
                    id: membersBar

                    property bool show: false

                    Layout.fillHeight: true
                    Layout.preferredWidth: defaultSiderbarWidth - 2
                    backgroundColor: "#FFFFFF"
                    visible: show
                }
                Rectangle {
                    id: chatBar

                    property bool show: false

                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width
                    visible: show

                    Rectangle {
                        id: chatbusyContainer
                        anchors.fill: chatBar
                        color: "#99000000"
                        visible: false
                        z: 999

                        BusyIndicator {
                            id: busyIndicator
                            anchors.centerIn: parent
                            height: 50
                            running: true
                            width: 50
                        }
                        Label {
                            id: busyNotice
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: busyIndicator.bottom
                            anchors.topMargin: 8
                            color: "#FFFFFF"
                            font.pixelSize: 16
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
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#EBEDF0"
                            opacity: .6
                        }
                        Rectangle {
                            id: title
                            Layout.preferredHeight: {
                                if (membersBar.visible)
                                    return 40;
                                else
                                    return 41;
                            }
                            Layout.preferredWidth: parent.width

                            Label {
                                anchors.centerIn: parent
                                color: "#333333"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                text: qsTr("chatroom")
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#EBEDF0"
                            opacity: .6
                        }
                        Rectangle {
                            id: listviewlayout
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width

                            ChatListView {
                                id: chatroom
                                maxMsgUintWidth: 224
                                messageModel: chatMessageModel

                                Rectangle {
                                    id: msgTipBtn
                                    anchors.bottom: chatroom.bottom
                                    anchors.bottomMargin: 5
                                    anchors.right: chatroom.right
                                    anchors.rightMargin: 15
                                    color: "#337EFF"
                                    height: 28
                                    radius: 14
                                    visible: false
                                    width: 74
                                    z: 2

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Image {
                                            id: btnImage
                                            Layout.preferredHeight: 8
                                            Layout.preferredWidth: 8
                                            mipmap: true
                                            source: "qrc:/qml/images/chatroom/messagedown.png"
                                        }
                                        Label {
                                            id: tipLabel
                                            Layout.preferredHeight: 17
                                            Layout.preferredWidth: 36
                                            color: "#FFFFFF"
                                            font.pixelSize: 12
                                            text: qsTr("new message")
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            chatroom.msglistView.positionViewAtEnd();
                                            msgTipBtn.visible = false;
                                            chatroom.msglistView.msgTimeTip = false;
                                            newMsgNotity(0, "", "");
                                        }
                                    }
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#EBEDF0"
                            opacity: .6
                        }
                        Rectangle {
                            id: input
                            Layout.preferredHeight: 67
                            Layout.preferredWidth: parent.width

                            Flickable {
                                id: scView
                                anchors.left: parent.left
                                anchors.top: parent.top
                                height: parent.height
                                width: !idTool.visible ? parent.width : parent.width - idTool.width - 14

                                ScrollBar.vertical: ScrollBar {
                                    width: 5

                                    onActiveChanged: {
                                        if (active) {
                                            messageField.focus = false;
                                        }
                                    }
                                }
                                TextArea.flickable: TextArea {
                                    id: messageField

                                    property int inputImageHeight: 38

                                    function sendMsg() {
                                        if (messageField.text.match(/^[ ]*$/) || messageField.getText(0, messageField.length) === '') {
                                            operator.show(qsTr("can not send empty message"), 1500);
                                            return;
                                        }
                                        let startFragment = "<!--StartFragment-->";
                                        let endFragment = "<!--EndFragment-->";
                                        let startImage = "<img src=\"file:///";
                                        let endImage = "\" height=\"" + messageField.inputImageHeight + "\" />";
                                        let formattedText = messageField.getFormattedText(0, messageField.length);
                                        // console.log("formattedText:", formattedText)
                                        let path = formattedText.toLowerCase();
                                        if (formattedText.toLowerCase().includes(startFragment.toLowerCase()) && !messageField.text.toLowerCase().includes(startFragment.toLowerCase())) {
                                            formattedText = formattedText.substr(formattedText.indexOf(startFragment)).replace(startFragment, "");
                                            formattedText = formattedText.substring(0, formattedText.indexOf(endFragment));
                                            // console.log("formattedTextEx:", formattedText)
                                            while (0 !== formattedText.length) {
                                                let pos = formattedText.indexOf(startImage);
                                                let pos2 = formattedText.indexOf(endImage);
                                                if (-1 === pos || -1 === pos2) {
                                                    // console.log("text:", formattedText)
                                                    chatManager.sendMsg(1, formattedText);
                                                    break;
                                                }
                                                if (0 !== pos) {
                                                    // console.log("text:", formattedText.substring(0, pos))
                                                    chatManager.sendMsg(1, formattedText.substring(0, pos));
                                                }
                                                // console.log("image:", formattedText.substring(pos + startImage.length, pos2))
                                                chatManager.sendMsg(3, formattedText.substring(pos + startImage.length, pos2));
                                                formattedText = formattedText.substr(pos2).replace(endImage, "");
                                            }
                                        } else {
                                            chatManager.sendTextMsg(messageField.text);
                                        }
                                        messageField.text = "";
                                        messageField.focus = true;
                                        atEndTimer.restart();
                                    }

                                    Accessible.name: "messageField"
                                    color: "#333333"
                                    font.pixelSize: 14
                                    leftPadding: 8
                                    placeholderText: qsTr("Input a message and press Enter to send it...")
                                    placeholderTextColor: "#a09f9f"
                                    rightPadding: leftPadding
                                    selectByKeyboard: true
                                    selectByMouse: true
                                    textFormat: Text.AutoText
                                    wrapMode: TextArea.Wrap

                                    background: Rectangle {
                                        //hide the focus line
                                        height: 0
                                    }

                                    Keys.onEnterPressed: {
                                        sendMsg();
                                    }
                                    Keys.onPressed: {
                                        if (event.modifiers & Qt.ControlModifier) {
                                            if (event.key === Qt.Key_C) {
                                                // Ctrl+C复制
                                                // console.log("ctrl + c", messageField.text, "CCCCCCCC", messageField.getFormattedText(0, messageField.length))
                                                if (messageField.text !== messageField.getFormattedText(0, messageField.length)) {
                                                    event.accepted = true;
                                                }
                                            } else if (event.key === Qt.Key_V) {
                                                // Ctrl+V复制
                                                let imagePath = clipboard.getImage();
                                                // console.log("ctrl + v, getImage:", imagePath)
                                                if (imagePath.length !== 0) {
                                                    let path = imagePath.toLowerCase();
                                                    if (path.endsWith(".jpg") || path.endsWith(".png") || path.endsWith(".jpeg") || path.endsWith(".bmp")) {
                                                        if (Qt.platform.os === 'osx' && path.startsWith("file:///")) {
                                                            imagePath = imagePath.substring(0, 5) + '/' + imagePath.substring(5);
                                                        }
                                                        imagePath = imagePath.replace("file:///", "");
                                                        messageField.insert(messageField.cursorPosition, "<img src=\"" + "file:///" + imagePath + "\"" + ", height=" + messageField.inputImageHeight + "\>");
                                                    }
                                                    event.accepted = true;
                                                } else {
                                                    // console.log("ctrl + v, getText:", clipboard.getText())
                                                    if (clipboard.getText().length === 0)
                                                        event.accepted = true;
                                                }
                                            }
                                        }
                                    }
                                    Keys.onReturnPressed: {
                                        sendMsg();
                                    }

                                    DropArea {
                                        id: dropArea
                                        anchors.fill: parent

                                        onDropped: drop => {
                                            // console.log("drop hasUrls:", drop.hasUrls)
                                            if (drop.hasUrls) {
                                                // console.log("drop hasUrls[0]:", drop.urls[0])
                                                let url = drop.urls[0].toString();
                                                if (Qt.platform.os === 'osx') {
                                                    url = url.substring(0, 5) + '/' + url.substring(5);
                                                }
                                                messageField.insert(messageField.cursorPosition, "<img src=\"" + url + "\"" + ", height=" + messageField.inputImageHeight + "\>");
                                            }
                                        }
                                        onEntered: drop => {
                                            // console.log("drop hasUrls:", drop.hasUrls)
                                            if (drop.hasUrls) {
                                                // console.log("drop hasUrls[0]:", drop.urls[0])
                                                let path = drop.urls[0].toString().toLowerCase();
                                                if (path.endsWith(".jpg") || path.endsWith(".png") || path.endsWith(".jpeg") || path.endsWith(".bmp")) {
                                                } else {
                                                    drop.accepted = false;
                                                    return false;
                                                }
                                            }
                                        }
                                    }
                                    Timer {
                                        id: atEndTimer
                                        interval: 100
                                        repeat: false

                                        onTriggered: {
                                            chatroom.msglistView.positionViewAtEnd();
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                id: idTool
                                anchors.right: parent.right
                                anchors.rightMargin: 14
                                anchors.top: scView.top
                                anchors.topMargin: 13
                                height: 16
                                visible: meetingManager.enableImageMessage || meetingManager.enableFileMessage
                                width: (meetingManager.enableImageMessage && meetingManager.enableFileMessage) ? 48 : 16

                                RowLayout {
                                    Layout.alignment: Qt.AlignRight
                                    anchors.fill: parent
                                    spacing: 16

                                    ImageButton {
                                        id: idImage
                                        Layout.preferredHeight: 16
                                        Layout.preferredWidth: 18
                                        hoveredImage: 'qrc:/qml/images/chatroom/image.svg'
                                        normalImage: 'qrc:/qml/images/chatroom/image.svg'
                                        pushedImage: 'qrc:/qml/images/chatroom/image.svg'
                                        visible: meetingManager.enableImageMessage

                                        onClicked: {
                                            console.log(fileDialog.selectedFile);
                                            fileDialog.selectedFile = 'file:///';
                                            fileDialog.imageType = true;
                                            fileDialog.open();
                                        }
                                    }
                                    ImageButton {
                                        id: idFile
                                        Layout.preferredHeight: 16
                                        Layout.preferredWidth: 17
                                        hoveredImage: 'qrc:/qml/images/chatroom/file.svg'
                                        normalImage: 'qrc:/qml/images/chatroom/file.svg'
                                        pushedImage: 'qrc:/qml/images/chatroom/file.svg'
                                        visible: meetingManager.enableFileMessage

                                        onClicked: {
                                            console.log(fileDialog.selectedFile);
                                            fileDialog.selectedFile = 'file:///';
                                            fileDialog.imageType = false;
                                            fileDialog.open();
                                        }
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
        color: "transparent"
        visible: false

        Rectangle {
            anchors.centerIn: parent
            color: "#FFFFFF"
            height: 80
            radius: 8
            width: 360

            RowLayout {
                anchors.centerIn: parent
                height: 50
                spacing: 5
                width: childrenRect.width

                AnimatedImage {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 24
                    antialiasing: true
                    mipmap: true
                    playing: busyContainer.visible
                    smooth: true
                    source: "qrc:/qml/images/loading/loading-ring-medium.gif"
                }
                Label {
                    color: "#337EFF"
                    font.pixelSize: 14
                    text: qsTr('Disconnected, trying to reconnect.')
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }
    }
    Timer {
        id: hideWindow

        property bool preparerun: false

        interval: 1000
        repeat: false

        onTriggered: {
            console.log("hideWindow Timer, visible:", mainWindow.visible);
            preparerun = false;
            mainWindow.beforeClose();
            if (!mainWindow.visible) {
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'));
                mainWindow.setVisible(false);
            }
        }
    }
    Timer {
        id: quitTimer
        interval: 1000
        repeat: false

        onTriggered: {
            // Qt.callLater(Qt.quit)
            authManager.autoLogout();
        }
    }
    Timer {
        id: synDataTimer
        interval: 1000
        repeat: false

        onTriggered: {
            if (membersManager.handsUpCount > 0) {
                if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                    var controlPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                    handsStatus.x = Qt.binding(function () {
                            return controlPos.x + handsStatus.width / 2;
                        });
                    handsStatus.y = Qt.binding(function () {
                            return controlPos.y - handsStatus.height - 40;
                        });
                    if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                        handstip.text = membersManager.handsUpCount;
                        // fix: 当以联席主持人身份异常退出会议时，在此进入会议后，被主持人取消联席身份后，无法举手
                        // membersManager.handsUpStatus = true;
                        handsStatus.visible = true;
                    } else {
                        if (membersManager.getMyHandsupStatus()) {
                            handstip.text = qsTr("HandsUp");
                            handsStatus.visible = true;
                        }
                    }
                }
            }
        }
    }
    Timer {
        id: hideFooterBarTimer
        interval: 3000
        repeat: false
        running: false

        onTriggered: {
            if (whiteboardManager.whiteboardSharing) {
                return;
            }
            if (!deviceSelector.visible) {
                staticPoint = footerEventHanlder.point.position;
                hideFooterContainer.restart();
            }
        }
    }
    Timer {
        id: showPasswordTimer
        interval: 200
        repeat: false
        running: false

        onTriggered: {
            if (!passwordWindow.visible) {
                const constPos = root.mapToGlobal(0, 0);
                passwordWindow.x = constPos.x + (root.width - passwordWindow.width) / 2;
                passwordWindow.y = constPos.y + (root.height - passwordWindow.height) / 2;
                passwordWindow.show();
            }
        }
    }
    Timer {
        id: showRemainingTipTimer
        interval: 1000 * 60
        repeat: false

        onTriggered: {
            hasShowRemainingTip = false;
            remainingTip.visible = false;
        }
    }
    FileDialog {
        id: fileDialog

        property bool imageType: true

        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        nameFilters: imageType ? ["%1 (*.jpg *.png *.jpeg *.bmp)".arg(qsTr("image files"))] : ["%1 (*.mp3 *.aac *.wav *.pcm *.mp4 *.flv *.mov *.doc *.docx *.xls *.xlsx *.ppt *.pptx *.jpg *.png *.jpeg *.bmp *.pdf *.zip *.7z *.biz *.tar *.txt *.apk *.ipa)".arg(qsTr("all files")), "%1 (*.mp3 *.aac *.wav *.pcm)".arg(qsTr("audio files")), "%1 (*.mp4 *.flv *.mov)".arg(qsTr("video files")), "%1 (*.doc *.docx *.xls *.xlsx *.ppt *.pptx)".arg(qsTr("office files")), "%1 (*.jpg *.png *.jpeg *.bmp)".arg(qsTr("image files")), "%1 (*.zip *.7z *.biz *.tar)".arg(qsTr("zip files")), "%1 (*.pdf)".arg(qsTr("pdf files")), "%1 (*.txt)".arg(qsTr("text files")), "%1 (*.apk *.ipa)".arg(qsTr("pack files"))]

        onAccepted: {
            console.log("sendFileMsg image: " + fileDialog.selectedFile);
            var filePath = "";
            filePath = fileDialog.selectedFile.toString();
            if (Qt.platform.os === 'osx') {
                filePath = filePath.replace("file://", "");
            } else {
                filePath = filePath.replace("file:///", "");
            }
            if (imageType) {
                chatManager.sendFileMsg(3, filePath);
            } else {
                chatManager.sendFileMsg(2, filePath);
            }
        }
    }
    Connections {
        target: globalManager

        onHideSettingsWindow: {
            SettingsWnd.hide();
        }
        onShowSettingsWindow: {
            SettingsWnd.displayPage(0);
        }
    }
    Connections {
        target: deviceManager

        onError: {
            toast.show(errorMessage);
        }
        onPlayoutDeviceChangedNotify: {
            if (mainWindow.visible)
                GlobalToast.displayText(qsTr('Current playout device "[%1]"').arg(deviceName), mainWindow.screen);
        }
        onRecordDeviceChangedNotify: {
            if (mainWindow.visible)
                GlobalToast.displayText(qsTr('Current record device "[%1]"').arg(deviceName), mainWindow.screen);
        }
        onShowIndicationTip: {
            GlobalToast.displayText(qsTr('It is detected that you are speaking, if you need to speak,\n please click the "Unmute" button and speak again'), mainWindow.screen);
        }
        onShowMaxHubTip: {
            if (mainWindow.visible) {
                customDialog.confirmBtnText = qsTr("OK");
                customDialog.cancelBtnText = qsTr("Cancel");
                customDialog.text = qsTr('Select the audio output device');
                customDialog.description = qsTr('The screen is being cast. Do you want to output audio through the large screen?');
                customDialog.confirm.disconnect(enableLocalVideo);
                customDialog.confirm.disconnect(leaveMeeting);
                customDialog.confirm.disconnect(endMeeting);
                customDialog.confirm.disconnect(muteHandsDown);
                customDialog.confirm.disconnect(muteHandsUp);
                customDialog.cancel.disconnect(disableLocalVideo);
                customDialog.cancel.disconnect(unMuteLoaclAudio);
                customDialog.confirm.connect(showMaxHubTip);
                customDialog.open();
            }
        }
    }
    Connections {
        target: authManager

        onLogin: {
            if (authStatus == 2 && meetingManager.autoStartMode) {
                meetingManager.autoStartMeeting();
            }
        }
    }
    Connections {
        target: meetingManager

        onActiveWindow: {
            if (shareManager.shareAccountId === authManager.authAccountId) {
                return;
            }
            if (mainWindow.visibility === Window.Minimized)
                mainWindow.showNormal();
            mainWindow.raise();

            //            if (Qt.platform.os === "osx") {
            //                if (bRaise) {
            //                    mainWindow.raise()
            //                } else {
            //                    if (!shareManager.ownerSharing()) {
            //                         meetingManager.activeMainWindow();
            //                    }
            //                }
            //            } else {
            //                mainWindow.raise()
            //            }
        }
        onError: {
            if (errorCode === 2110) {
                audioManager.muteLocalAudio(false);
                return;
            }
            if (errorMessage !== '' && errorCode != 0) {
                toast.show(errorMessage);
            }
        }
        onLockStatusNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                if (meetingManager.meetingLocked)
                    toast.show(qsTr('You have been locked this meeting'));
                else
                    toast.show(qsTr('You have been unlocked this meeting'));
            } /*else {
                if (meetingManager.meetingLocked)
                    toast.show(qsTr('This meeting has been locked by host'))
                else
                    toast.show(qsTr('This meeting has been unlocked by host'))
            }*/
        }
        onMeetingStatusChanged: {
            console.log("Meeting status changed, status: " + status + "  code: " + errorCode + ", message: " + errorMessage);
            latestMeetingStatus = status;
            switch (status) {
            case MeetingStatus.MEETING_IDLE:
                if (meetingManager.autoStartMode) {
                    GlobalToast.displayText(qsTr('Meeting has been finished'), mainWindow.screen);
                    quitTimer.start();
                }
                if (meetingManager.reconnecting) {
                    console.info('Reconnecting... skip next steps.');
                    break;
                }
                console.log("mainWindow visibility(MEETING_IDLE): " + mainWindow.visibility);
                if (Qt.platform.os === 'osx' && !hideWindow.preparerun && !mainWindow.visible) {
                    console.log("mainWindow hideWindow.preparerun: " + hideWindow.preparerun, mainWindow.visible);
                    mainWindow.showNormal();
                    mainWindow.setVisible(false);
                }
                break;
            case MeetingStatus.MEETING_CONNECTING:
                break;
            case MeetingStatus.MEETING_WAITING_VERIFY_PASSWORD:
                if (!mainWindow.visible) {
                    mainWindow.raiseOnTop();
                    busyContainer.visible = false;
                    mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'));
                }
                passwordWindow.showError = false;
                passwordWindow.errorText = '';
                switch (errorCode) {
                case 1020:
                    passwordWindow.errorText = errorMessage;
                    passwordWindow.showError = true;
                    break;
                default:
                    break;
                }
                showPasswordTimer.start();
                break;
            case MeetingStatus.MEETING_PREPARING:
                closeAllDialog();
                mainWindow.raiseOnTop();
                busyContainer.visible = false;
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'));
                break;
            case MeetingStatus.MEETING_PREPARED:
                mainWindow.setVisible(true);
                break;
            case MeetingStatus.MEETING_CONNECTED:
                console.info('Meeting connected, meeting duration:', meetingManager.meetingDuration);
                passwordWindow.setVisible(false);
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'));
                if (whiteboardManager.getAutoOpenWhiteboard()) {
                    if (whiteboardManager.whiteboardSharing) {
                        if (viewMode !== MainPanel.ViewMode.WhiteboardMode) {
                            mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/WhiteboardPage.qml'));
                        }
                    } else {
                        whiteboardManager.openWhiteboard(authManager.authAccountId);
                    }
                } else {
                    if (whiteboardManager.whiteboardSharing) {
                        if (viewMode !== MainPanel.ViewMode.WhiteboardMode) {
                            mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/WhiteboardPage.qml'));
                        }
                    }
                }
                var localLastModifyNickname = globalSettings.value('localLastModifyNickname');
                if (localLastModifyNickname !== '' && meetingManager.meetingId !== globalSettings.value('localLastConferenceId')) {
                    globalSettings.setValue('localLastModifyNickname', '');
                }
                var localLastNickname = globalSettings.value('localLastNickname');
                if (meetingManager.meetingId !== globalSettings.value('localLastConferenceId')) {
                    globalSettings.setValue('localLastNickname', meetingManager.nickname);
                }
                globalSettings.setValue('localLastMeetingTopic', meetingManager.meetingTopic);
                globalSettings.setValue('localLastMeetingPassword', meetingManager.meetingPassword);
                globalSettings.setValue('localLastMeetingshortId', meetingManager.shortMeetingNum);
                globalSettings.setValue('localLastMeetingUniqueId', meetingManager.meetingUniqueId);
                globalSettings.setValue('localLastConferenceId', meetingManager.meetingId);
                globalSettings.setValue('localLastChannelId', meetingManager.channelId);
                globalSettings.setValue('localLastSipId', meetingManager.meetingSIPChannelId);
                if (!meetingManager.hideChatroom)
                    chatManager.loginChatroom();
                deviceManager.getCurrentSelectedDevice();
                myNickname = meetingManager.nickname;
                busyContainer.visible = false;
                hasShowRemainingTip = false;
                remainingTip.visible = false;
                hideFooterBarTimer.start();
                mainWindow.raise();
                synDataTimer.start();

                //                if(meetingManager.enableRecord) {
                //                    GlobalToast.displayText(qsTr("meeting recording"), mainWindow.screen)
                //                }
                break;
            case MeetingStatus.MEETING_RECONNECTED:
                toast.show(qsTr('Network reconnected.'));
                busyContainer.visible = false;
                break;
            case MeetingStatus.MEETING_CONNECT_FAILED:
                if (meetingManager.autoStartMode) {
                    GlobalToast.displayText(qsTr('Failed to join meeting'), mainWindow.screen);
                    quitTimer.start();
                }
                if (meetingManager.reconnecting) {
                    DialogManager.dynamicDialog2(qsTr('Bad network'), qsTr('Network has been disconnected, check your network and rejoin please.'), function () {
                            meetingManager.leaveMeeting(true);
                        }, function () {
                            meetingManager.rejoinMeeting();
                        }, qsTr("Leave"), qsTr("Rejoin"), mainWindow, false, "#FE3B30", "#337EFF", Popup.NoAutoClose);
                    toast.show(errorMessage);
                    console.info('Reconnecting... skip next steps.');
                    break;
                }
                passwordWindow.setVisible(false);
                mainWindow.setVisible(false);
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'));
                break;
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_MULTI_SPOT_LOGIN:
            case MeetingStatus.MEETING_ENDED:
                handsStatus.visible = false;
                handstip.text = qsTr("HandsUp");
                muteConfirmDialog.close();
                popupMeetingInfo.close();
                popupNetWorkQualityInfo.close();
                moreItemsMenuEx.close();
                passwordWindow.setVisible(false);
                membersBar.restore();
                chatMessageModel.clearMessage();
                messageField.text = "";
                GlobalChatManager.noNewMsgNotity();
                chatManager.logoutChatroom();
                chatbusyContainer.visible = false;
                closeAllDialog();
                myNickname = "";
                hasShowRemainingTip = false;
                remainingTip.visible = false;
                temporarilyUnmute = false;
                showRemainingTipTimer.stop();
                busyContainer.visible = false;
                isNewMeetingLayout = true;
                showTopList = true;
                showRightList = true;
                splitViewCurrentViewMode = SplitPage.ViewMode.FocusView;
                splitViewLastViewMode = SplitPage.ViewMode.FocusView;
                console.log("mainWindow visibility: " + mainWindow.visibility);
                if (errorCode === 9) {
                    mainWindow.showNormal();
                    DialogManager.dynamicDialog2(qsTr('Bad network'), qsTr('Network has been disconnected, check your network and rejoin please.'), function () {
                            meetingManager.leaveMeeting(true);
                        }, function () {
                            meetingManager.rejoinMeeting();
                        }, qsTr("Leave"), qsTr("Rejoin"), mainWindow, false, "#FE3B30", "#337EFF", Popup.NoAutoClose);
                } else {
                    if (Qt.platform.os === 'osx' && (mainWindow.visibility === Window.FullScreen || mainWindow.visibility === Window.Maximized)) {
                        console.log("mainWindow visibility is FullScreen or Maximized.");
                        mainWindow.showNormal();
                        hideWindow.preparerun = true;
                        hideWindow.start();
                    } else {
                        mainWindow.setVisible(false);
                        mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'));
                    }
                }
                break;
            case MeetingStatus.MEETING_CMD_CHANNEL_DISCONNECTED:
                busyContainer.visible = true;
                if (shareSelector.visible) {
                    shareSelector.close();
                }
                if (liveSetting.visible) {
                    liveSetting.close();
                }
                break;
            default:
                if (meetingManager.reconnecting)
                    break;
                mainWindow.setVisible(false);
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoadingPage.qml'));
                break;
            }
        }
        onModifyNicknameResult: {
            if (success) {
                toast.show(qsTr('modify nickname success'));
            } else {
                toast.show(qsTr('modify nickname fail'));
            }
        }
        onMuteStatusNotify: {
            if (audio) {
                if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                    if (meetingManager.meetingMuted)
                        toast.show(qsTr('You have turned on all mute'));
                    else
                        toast.show(qsTr('You have turned off all mute'));
                } else {
                    if (meetingManager.meetingMuted && audioManager.localAudioStatus !== 3 && audioManager.localAudioStatus !== 2) {
                        toast.show(qsTr('This meeting has been turned on all mute by host'));
                    }
                    if (meetingManager.meetingMuted && temporarilyUnmute && spacePressed) {
                        temporarilyUnmute = false;
                        console.log("temporarilyUnmute end by host");
                    }
                }
            } else {
                if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                    if (meetingManager.meetingVideoMuted)
                        toast.show(qsTr('You have turned on all mute video'));
                    else
                        toast.show(qsTr('You have turned off all mute video'));
                } else {
                    if (meetingManager.meetingVideoMuted && videoManager.localVideoStatus !== 3 && videoManager.localVideoStatus !== 2) {
                        toast.show(qsTr('This meeting has been turned on all mute video by host'));
                    }
                }
            }
        }
        onRemainingSecondsChanged: {
            if (meetingManager.remainingSeconds === 60 * 10 || meetingManager.remainingSeconds === 60 * 5 || meetingManager.remainingSeconds === 60 * 1) {
                if (!hasShowRemainingTip) {
                    hasShowRemainingTip = true;
                    remainingTip.visible = true;
                    var minNum = meetingManager.remainingSeconds / 60;
                    remainingTip.description = qsTr('Meeting will close in %1 min.').arg(minNum);
                    showRemainingTipTimer.restart();
                }
            }
        }
        onRemainingSecondsRenewed: {
            if (showRemainingTipTimer.running) {
                showRemainingTipTimer.stop();
                hasShowRemainingTip = false;
                remainingTip.visible = false;
            }
        }
    }
    Connections {
        target: deviceManager

        onUserAudioVolumeIndication: {
            if (!root.visible) {
                return;
            }
            if (accountId !== authManager.authAccountId) {
                return;
            }
            imgVolume.source = getAudioVolumeSourceImage(level);
        }
    }
    Connections {
        target: audioManager

        onActiveSpeakerChanged: {
            if (videoManager.focusAccountId.length === 0 && shareManager.shareAccountId.length === 0) {
                if (viewMode !== MainPanel.ViewMode.FocusViewMode && viewMode !== MainPanel.ViewMode.FocusViewLeftToRightMode)
                    return;
                membersManager.getMembersPaging(pageSize, currentPage, MembersStatus.VIEW_MODE_AUTO);
            }
        }
        onActiveSpeakerNicknameChanged: {
            activeSpeakerTootips.visible = false;
            return;
            if (audioManager.activeSpeakerNickname.length !== 0 && shareManager.shareAccountId.length === 0) {
                speakernickname.text = audioManager.activeSpeakerNickname;
                activeSpeakerTootips.visible = true;
            } else {
                if (activeSpeakerTootips.visible === true)
                    activeSpeakerTootips.visible = false;
            }
        }
        onError: {
            toast.show(errorMessage);
        }
        onShowPermissionWnd: {
            if (shareManager.shareAccountId.length !== 0) {
                return;
            }
            requestPermission.sigOpenSetting.connect(function () {
                    audioManager.openSystemMicrophoneSettings();
                });
            requestPermission.titleText = qsTr("Microphone Permission");
            requestPermission.contentText = qsTr('Due to the security control of MacOS system, it is necessary to turn on the system Microphone permission before open Microphone%1Open System Preferences > Security and privacy grant access').arg('\r\n\r\n');
            requestPermission.open();
        }
        onUserAudioStatusChanged: {
            if (shareManager.shareAccountId === authManager.authAccountId) {
                return;
            }
            if (changedAccountId === authManager.authAccountId) {
                if (deviceStatus === MeetingStatus.DEVICE_DISABLED_BY_HOST) {
                    if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                        toast.show(qsTr("You have been muted by host"));
                    }
                    if (temporarilyUnmute && spacePressed) {
                        temporarilyUnmute = false;
                        console.log("temporarilyUnmute end by host");
                    }
                } else if (deviceStatus === MeetingStatus.DEVICE_NEEDS_TO_CONFIRM) {
                    if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                        function confirm() {
                            if (meetingManager.meetingMuted && !meetingManager.meetingAllowSelfAudioOn && audioManager.localAudioStatus === MeetingStatus.DEVICE_DISABLED_BY_SELF) {
                                footerBar.idMeetingToolBar.btnAudioCtrlClicked();
                                return;
                            }
                            muteLocalAudio();
                            if (membersManager.handsUpStatus) {
                                //举手时打开音频，取消举手
                                membersManager.handsUp(false);
                            }
                        }
                        function cancel() {
                            audioManager.onUserAudioStatusChangedUI(authManager.authAccountId, 2);
                        }
                        if (customDialog != undefined && customDialog.visible && customDialog.text === qsTr("Mute all")) {
                            customDialog.close();
                        }
                        if (microphoneDynamicDialog != undefined && microphoneDynamicDialog.visible) {
                            return;
                        }
                        microphoneDynamicDialog = DialogManager.dynamicDialog2(qsTr("Open your microphone"), qsTr("The host applies to open your microphone, do you agree."), confirm, cancel, qsTr("OK"), qsTr("Cancel"), mainWindow, false);
                    } else {
                        audioManager.muteLocalAudio(false);
                    }
                } else if (deviceStatus === MeetingStatus.DEVICE_DISABLED_BY_SELF) {
                    if (temporarilyUnmute && spacePressed) {
                        temporarilyUnmute = false;
                        console.log("temporarilyUnmute end by self");
                    }
                } else if (deviceStatus === MeetingStatus.DEVICE_ENABLED) {
                    if (meetingManager.meetingMuted && !meetingManager.meetingAllowSelfAudioOn && authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                        toast.show(qsTr("you have been ummute bt most,you can speak freely."));
                    }
                }
            }
        }
        onUserSpeakerChanged: {
            speakers.visible = SettingsManager.showSpeaker && nickName !== '';
            speakersNickname.text = nickName;
        }
    }
    Connections {
        target: videoManager

        onError: {
            toast.show(errorMessage);
        }
        onFocusAccountIdChanged: {
            console.info('Focus account Id changed, old focus:', oldSpeaker, ', new focus:', newSpeaker, ', current account:', authManager.authAccountId);
            if (newSpeaker !== '' && newSpeaker === authManager.authAccountId)
                toast.show(qsTr('You have been set as active speaker.'));
            if (oldSpeaker !== newSpeaker && oldSpeaker === authManager.authAccountId)
                toast.show(qsTr('You have been unset of active speaker.'));
            if (oldSpeaker !== newSpeaker) {
                membersManager.getMembersPaging(pageSize, currentPage, MembersStatus.VIEW_MODE_AUTO);
            }
        }
        onShowPermissionWnd: {
            if (shareManager.shareAccountId.length !== 0) {
                return;
            }
            requestPermission.sigOpenSetting.connect(function () {
                    videoManager.openSystemCameraSettings();
                });
            requestPermission.titleText = qsTr("Camera Permission");
            requestPermission.contentText = qsTr('Due to the security control of MacOS system, it is necessary to turn on the system Camera permission before open Camera%1Open System Preferences > Security and privacy grant access').arg('\r\n\r\n');
            requestPermission.open();
        }
        onUserVideoStatusChanged: {
            console.log("onUserVideoStatusChanged changedAccountId", changedAccountId);
            console.log("onUserVideoStatusChanged deviceStatus", deviceStatus);
            if (shareManager.shareAccountId === authManager.authAccountId) {
                return;
            }
            if (changedAccountId === authManager.authAccountId) {
                if (deviceStatus === MeetingStatus.DEVICE_DISABLED_BY_HOST) {
                    if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                        toast.show(qsTr("Your camera has been disabled by the host"));
                    }
                } else if (deviceStatus === MeetingStatus.DEVICE_NEEDS_TO_CONFIRM) {
                    if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole) {
                        function confirm() {
                            if (meetingManager.meetingVideoMuted && !meetingManager.meetingAllowSelfVideoOn && videoManager.localVideoStatus === MeetingStatus.DEVICE_DISABLED_BY_SELF) {
                                footerBar.idMeetingToolBar.btnVideoCtrlClicked();
                                return;
                            }
                            enableLocalVideo();
                            if (membersManager.handsUpStatus) {
                                //举手时打开视频，取消举手
                                membersManager.handsUp(false);
                            }
                        }
                        function cancel() {
                            console.log("cancel open video");
                            videoManager.onUserVideoStatusChangedUI(authManager.authAccountId, 2);
                        }
                        if (tempDynamicDialog != undefined && tempDynamicDialog.text === qsTr("Mute all Video")) {
                            tempDynamicDialog.close();
                        }
                        if (customDialog != undefined && customDialog.visible && customDialog.text === qsTr("Mute all")) {
                            customDialog.close();
                        }
                        if (cameraDynamicDialog != undefined && cameraDynamicDialog.visible) {
                            console.log("cameraDynamicDialog is already open");
                            return;
                        }
                        cameraDynamicDialog = DialogManager.dynamicDialog2(qsTr("Open your camera"), qsTr("The host applies to open your video, do you agree."), confirm, cancel, qsTr("OK"), qsTr("Cancel"), mainWindow, false);
                    } else {
                        videoManager.disableLocalVideo(false);
                    }
                }
            }
        }
    }
    Connections {
        target: membersManager

        onHandsupStatusChanged: {
            switch (status) {
            case MeetingStatus.HAND_STATUS_RAISE:
                var controlPos = 0;
                if (accountId === authManager.authAccountId) {
                    toast.show(qsTr("Hands raised up, please wait host handle."));
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                        controlPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                        handsStatus.x = Qt.binding(function () {
                                return controlPos.x + handsStatus.width / 2;
                            });
                        handsStatus.y = Qt.binding(function () {
                                return controlPos.y - handsStatus.height - 40;
                            });
                        handstip.text = qsTr("HandsUp");
                        handsStatus.visible = true;
                    }
                } else if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                    if (membersManager.handsUpCount > 0) {
                        handstip.text = membersManager.handsUpCount;
                        if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                            controlPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                            handsStatus.x = Qt.binding(function () {
                                    return controlPos.x + handsStatus.width / 2;
                                });
                            handsStatus.y = Qt.binding(function () {
                                    return controlPos.y - handsStatus.height - 40;
                                });
                            handsStatus.visible = true;
                        }
                    }
                }
                break;
            case MeetingStatus.HAND_STATUS_DOWN:
                if (accountId === authManager.authAccountId && accountId !== membersManager.hostAccountId)
                /*&& !membersManager.isManagerRoleEx(accountId)*/{
                    if (!membersManager.isManagerRole) {
                        handsStatus.visible = false;
                        handstip.text = qsTr("HandsUp");
                    }
                } else if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                    if (membersManager.handsUpCount === 0) {
                        handsStatus.visible = false;
                    } else {
                        handstip.text = membersManager.handsUpCount;
                    }
                }
                break;
            case MeetingStatus.HAND_STATUS_REJECT:
                if (accountId === authManager.authAccountId) {
                    toast.show(qsTr("the host have refused your handsup request"));
                    handsStatus.visible = false;
                    handstip.text = qsTr("HandsUp");
                } else if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                    if (membersManager.handsUpCount === 0) {
                        handsStatus.visible = false;
                    } else {
                        handstip.text = membersManager.handsUpCount;
                    }
                }
                break;
            case MeetingStatus.HAND_STATUS_AGREE:
                if (accountId === authManager.authAccountId) {
                    handsStatus.visible = false;
                    handstip.text = qsTr("HandsUp");
                } else if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                    if (membersManager.handsUpCount === 0) {
                        handsStatus.visible = false;
                        handstip.text = qsTr("HandsUp");
                    } else {
                        handstip.text = membersManager.handsUpCount;
                    }
                }
                break;
            }
        }
        onHostAccountIdChangedSignal: {
            if (oldhostAccountId === authManager.authAccountId) {
                if (handsStatus.visible) {
                    handsStatus.visible = false;
                    handstip.text = qsTr("HandsUp");
                }
            }
            //host rejoin the meeting
            if (hostAccountId === oldhostAccountId && hostAccountId === authManager.authAccountId) {
                if (membersManager.handsUpCount > 0) {
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl && membersManager.handsUpCount > 0) {
                        handstip.text = membersManager.handsUpCount;
                        if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                            var controlPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                            handsStatus.x = Qt.binding(function () {
                                    return controlPos.x + handsStatus.width / 2;
                                });
                            handsStatus.y = Qt.binding(function () {
                                    return controlPos.y - handsStatus.height - 40;
                                });
                            handsStatus.visible = true;
                        }
                    }
                }
                return;
            }
            if (hostAccountId === authManager.authAccountId && oldhostAccountId !== authManager.authAccountId) {
                showFooterContainer.restart();
                toast.show(qsTr('You have been set as host'));
                handsStatus.visible = false;
                if (membersManager.handsUpCount > 0) {
                    handstip.text = membersManager.handsUpCount;
                    if (handsStatus.visible === false)
                        handsStatus.visible = true;
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                        handsStatus.x = Qt.binding(function () {
                                return handsStatusPos.x + handsStatus.width / 2;
                            });
                        handsStatus.y = Qt.binding(function () {
                                return handsStatusPos.y - handsStatus.height - 40;
                            });
                    }
                }
            }
        }
        onManagerAccountIdChanged: {
            if (!bAdd) {
                if (handsStatus.visible && managerAccountId === authManager.authAccountId && membersManager.hostAccountId !== authManager.authAccountId) {
                    handsStatus.visible = false;
                    handstip.text = qsTr("HandsUp");
                }
            }
            if (managerAccountId === authManager.authAccountId) {
                if (bAdd) {
                    showFooterContainer.restart();
                    toast.show(qsTr('You have been set as manager'));
                    handsStatus.visible = false;
                    if (membersManager.handsUpCount > 0) {
                        handstip.text = Qt.binding(function () {
                                return membersManager.handsUpCount;
                            });
                        if (handsStatus.visible === false) {
                            handsStatus.visible = true;
                        }
                        if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                            const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                            handsStatus.x = Qt.binding(function () {
                                    return handsStatusPos.x + handsStatus.width / 2;
                                });
                            handsStatus.y = Qt.binding(function () {
                                    return handsStatusPos.y - handsStatus.height - 40;
                                });
                        }
                    }
                } else {
                    toast.show(qsTr('You have been unset as manager'));
                    if (managerAccountId === authManager.authAccountId && !bAdd) {
                        if (tempDynamicDialogEx !== undefined)
                            tempDynamicDialogEx.close();
                    }
                }
            }
        }
        onManagerUpdateSuccess: {
            if (set) {
                toast.show(nickname + qsTr('has been set as manager'));
            } else {
                toast.show(nickname + qsTr('has been unset as manager'));
            }
        }
        onNetWorkQualityTypeChanged: {
            // 连续三次是 MeetingStatus.NETWORKQUALITY_BAD 的情况下打印日志
            // console.log(`Network quality changed, current quality: ${netWorkQualityType}`)
            if (netWorkQualityType === MeetingStatus.NETWORKQUALITY_BAD) {
                networkQualityBadTimes += 1;
                if (networkQualityBadTimes === 3) {
                    networkQualityBadTimes = 0;
                    if (!busyContainer.visible)
                        toast.show(qsTr("Network abnormality, please check your network."));
                }
            } else {
                networkQualityBadTimes = 0;
            }
        }
        onNicknameChanged: {
            if (authManager.authAccountId === accountId) {
                globalSettings.setValue("localLastNickname", nickname);
                globalSettings.setValue('localLastModifyNickname', nickname);
            }
        }
        onUserJoinNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole)
                toast.show(qsTr('%1 joined the meeting').arg(nickname));
        }
        onUserLeftNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole)
                toast.show(qsTr('%1 left from the meeting').arg(nickname));
        }
    }
    Timer {
        id: macShareTimer
        interval: 1000
        repeat: false
        running: false

        onTriggered: {
            console.log("macShareTimer triggered.");
            if (sharedWnd !== undefined) {
                sharedWnd.show();
            }
            shareSelector.close();
            mainWindow.setVisible(true);
            mainWindow.setVisible(false);
        }
    }
    Connections {
        target: shareManager

        onCloseScreenShareByHost: {
            toast.show(qsTr('The host has terminated your sharing'));
        }
        onError: {
            toast.show(errorMessage);
        }
        onShareAccountIdChanged: {
            console.info("Screen sharing status changed:", shareManager.shareAccountId);
            if (shareManager.shareAccountId.length !== 0) {
                if (viewMode === MainPanel.ViewMode.GridViewMode)
                    mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'));
                if (shareManager.shareAccountId === authManager.authAccountId) {
                    if (Qt.platform.os === "windows") {
                        shareSelector.close();
                        mainWindow.setVisible(false);
                        if (sharedWnd !== undefined) {
                            sharedWnd.show();
                        }
                    } else {
                        if (mainWindow.visibility === Window.FullScreen) {
                            mainWindow.showNormal();
                            macShareTimer.restart();
                        } else {
                            shareSelector.close();
                            mainWindow.setVisible(false);
                            if (sharedWnd !== undefined) {
                                sharedWnd.show();
                            }
                        }
                    }
                    //if member start sharing screen, auto put his hands down
                    if (authManager.authAccountId !== membersManager.hostAccountId && !membersManager.isManagerRole && membersManager.handsUpStatus === true) {
                        if (membersManager.handsUpStatus)
                            membersManager.handsUp(false);
                    }
                } else {
                    membersManager.getMembersPaging(pageSize, currentPage, MembersStatus.VIEW_MODE_AUTO);
                }
                if (microphoneDynamicDialog != undefined && microphoneDynamicDialog.visible) {
                    microphoneDynamicDialog.close();
                }
                if (cameraDynamicDialog != undefined && cameraDynamicDialog.visible) {
                    cameraDynamicDialog.close();
                }
            } else if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                if (mainWindow.visibility !== Window.Windowed)
                    mainWindow.setVisible(true);
                if (SettingsWnd.visible)
                    SettingsWnd.raise();
                if ((membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole) && membersManager.handsUpCount > 0) {
                    handstip.text = membersManager.handsUpCount;
                    if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl && membersManager.handsUpCount > 0) {
                        const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                        handsStatus.x = Qt.binding(function () {
                                return handsStatusPos.x + handsStatus.width / 2;
                            });
                        handsStatus.y = Qt.binding(function () {
                                return handsStatusPos.y - handsStatus.height - 40;
                            });
                        handsStatus.visible = true;
                    }
                }
                if (sharedWnd !== undefined) {
                    sharedWnd.hide();
                    mainWindow.raise();
                }
                membersManager.getMembersPaging(pageSize, currentPage, MembersStatus.VIEW_MODE_AUTO);
            }
        }
    }
    Connections {
        target: caption

        onClose: {
            if (Qt.platform.os === 'osx' && MeetingStatus.MEETING_IDLE === latestMeetingStatus) {
                console.log('latestMeetingStatus is MeetingStatus.MEETING_IDLE');
                mainWindow.showNormal();
                mainWindow.setVisible(false);
                return;
            }
            if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                tempDynamicDialogEx = DialogManager.dynamicDialogEx(qsTr('End Meeting'), qsTr('Do you want to quit this meeting?'), function () {
                        meetingManager.leaveMeeting(false);
                    }, function () {
                        meetingManager.leaveMeeting(true);
                    }, function () {});
            } else {
                customDialog.confirmBtnText = qsTr("OK");
                customDialog.cancelBtnText = qsTr("Cancel");
                customDialog.text = qsTr('Exit');
                customDialog.description = qsTr('Do you want to quit this meeting?');
                customDialog.confirm.disconnect(muteLocalAudio);
                customDialog.confirm.disconnect(enableLocalVideo);
                customDialog.confirm.disconnect(endMeeting);
                customDialog.confirm.disconnect(muteHandsDown);
                customDialog.confirm.disconnect(muteHandsUp);
                customDialog.confirm.disconnect(showMaxHubTip);
                customDialog.cancel.disconnect(disableLocalVideo);
                customDialog.cancel.disconnect(unMuteLoaclAudio);
                customDialog.confirm.connect(leaveMeeting);
                customDialog.open();
            }
        }
    }
    Connections {
        target: mainWindow

        onBeforeClose: {
            if (Qt.platform.os === 'osx' && MeetingStatus.MEETING_IDLE === latestMeetingStatus) {
                console.log('latestMeetingStatus is MeetingStatus.MEETING_IDLE');
                mainWindow.showNormal();
                mainWindow.setVisible(false);
                return;
            }
            if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                tempDynamicDialogEx = DialogManager.dynamicDialogEx(qsTr('End Meeting'), qsTr('Do you want to quit this meeting?'), function () {
                        meetingManager.leaveMeeting(false);
                    }, function () {
                        meetingManager.leaveMeeting(true);
                    }, function () {});
            } else {
                customDialog.confirmBtnText = qsTr("OK");
                customDialog.cancelBtnText = qsTr("Cancel");
                customDialog.text = qsTr('Exit');
                customDialog.description = qsTr('Do you want to quit this meeting?');
                customDialog.confirm.disconnect(muteLocalAudio);
                customDialog.confirm.disconnect(enableLocalVideo);
                customDialog.confirm.disconnect(endMeeting);
                customDialog.confirm.disconnect(muteHandsDown);
                customDialog.confirm.disconnect(muteHandsUp);
                customDialog.confirm.disconnect(showMaxHubTip);
                customDialog.cancel.disconnect(unMuteLoaclAudio);
                customDialog.cancel.disconnect(disableLocalVideo);
                customDialog.confirm.connect(leaveMeeting);
                customDialog.open();
            }
        }
        onVisibilityChanged: {
            console.log("mainWindow onVisibilityChanged: ", mainWindow.visibility);
            if (mainWindow.visibility === Window.Maximized) {
            } else if (mainWindow.visibility === Window.Windowed) {
                if (extensions.visible) {
                    mainWindow.width = defaultWindowWidth + defaultSiderbarWidth;
                } else {
                    mainWindow.width = defaultWindowWidth;
                }
                adjustWindow();
            } else {
                messageField.focus = false;
            }
            if (Qt.platform.os === 'osx' && mainWindow.visibility !== Window.FullScreen && mainWindow.messageBubbleFullWindow !== undefined) {
                mainWindow.messageBubbleFullWindow.destroy();
                mainWindow.messageBubbleFullWindow = undefined;
            }
        }
        onVisibleChanged: {
            console.log("mainWindow onVisibleChanged: ", mainWindow.visible);
            if (mainWindow.visible) {
                if (chatBar.visible) {
                    if (chatroom.msglistView.atYEnd) {
                        footerBar.recvNewChatMsg(0, "", "");
                        msgCount = 0;
                        chatroom.msglistView.positionViewAtEnd();
                        if (msgTipBtn.visible) {
                            msgTipBtn.visible = false;
                        }
                    }
                }
                if (mainWindow.visibility !== Window.FullScreen && mainWindow.visibility !== Window.Maximized) {
                    adjustWindow();
                }
                // showFooterContainer.restart()
                // hideFooterBarTimer.restart()
            } else {
                //                if (chatroom.msglistView.atYEnd) {
                //                    GlobalChatManager.noNewMsgNotity()
                //                }
                chatBar.show = false;
                membersBar.show = false;
            }
            popupMeetingInfo.close();
            popupNetWorkQualityInfo.close();
            SettingsManager.setMainWindowVisible(mainWindow.visible);
        }
        onWidthChanged: {
            // Fix footer in center of window
            footerBar.y = parent.height - footerBar.height;
            if (mainWindow.visibility !== Window.FullScreen && mainWindow.visibility !== Window.Maximized) {
                const rightSide = mainWindow.x + mainWindow.width;
                if (rightSide > Screen.width) {
                    if (!adjustWindow())
                        centerInScreen();
                }
                const bottomSide = mainWindow.y + mainWindow.height;
                if (bottomSide > Screen.height - mainWindow.taskbarHeight) {
                    if (!adjustWindow())
                        centerInScreen();
                }
            }
            loaderLayout.width = Qt.binding(function () {
                    return loaderLayout.parent.width - (extensions.visible ? extensions.width : 0);
                });
        }
    }
    Connections {
        target: chatManager

        onDisconnect: {
            console.log("chatroom disconnect code : " + code + " chatbusyContainer.visible :" + chatbusyContainer.visible);
            switch (code) {
            case 0:
                chatbusyContainer.visible = false;
                messageField.focus = true;
                break;
            case 1:
                busyNotice.text = qsTr("trying to connect chatroom");
                chatbusyContainer.visible = true;
                messageField.focus = false;
                break;
            case 2:
                busyNotice.text = qsTr("trying to relogin chatroom");
                chatbusyContainer.visible = true;
                messageField.focus = false;
                chatManager.reloginChatroom();
                break;
            default:
                if (chatbusyContainer.visible) {
                    chatbusyContainer.visible = false;
                    messageField.focus = true;
                    break;
                }
            }
        }
        onError: {
            operator.show(text);
            // busyNotice.text = qsTr("chartoom errorcode: %1").arg(error_code)
            // chatbusyContainer.visible = true;
            // messageField.focus = false
        }
        onMsgSendSignal: {
            chatroom.msglistView.positionViewAtEnd();
            // messageField.text = "";
        }
        onMsgTipSignal: {
            ++msgCount;
            if (chatBar.visible) {
                if (chatroom.msglistView.atYEnd && shareManager.shareAccountId !== authManager.authAccountId) {
                    chatroom.msglistView.positionViewAtEnd();
                } else {
                    footerBar.recvNewChatMsg(msgCount, nickname, tip);
                    if (!msgTipBtn.visible) {
                        msgTipBtn.visible = true;
                    }
                }
            } else {
                footerBar.recvNewChatMsg(msgCount, nickname, tip);
            }
        }
    }
    Connections {
        target: whiteboardManager

        onWhiteboardCloseByHost: {
            toast.show(qsTr('The host has terminated your sharing'));
        }
        onWhiteboardSharingChanged: {
            if (whiteboardManager.whiteboardSharing) {
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/WhiteboardPage.qml'));
            }
        }
    }
    Timer {
        id: showChatBarTimer
        interval: 50
        repeat: false

        onTriggered: {
            if (chatBar.visible) {
                messageField.focus = true;
                footerBar.recvNewChatMsg(0, "", "");
                msgCount = 0;
                chatroom.msglistView.positionViewAtEnd();
                if (msgTipBtn.visible) {
                    msgTipBtn.visible = false;
                }
            } else {
                messageField.focus = false;
            }
        }
    }
    Connections {
        target: chatBar

        onVisibleChanged: {
            showChatBarTimer.restart();
        }
    }
    Connections {
        target: moreItemManager

        onChatItemVisibleChanged: {
            if (!moreItemManager.chatItemVisible) {
                chatBar.show = false;
                MessageBubble.hide();
                if (Qt.platform.os === 'osx' && mainWindow.messageBubbleFullWindow !== undefined) {
                    mainWindow.messageBubbleFullWindow.hide();
                }
            }
        }
        onInviteItemVisibleChanged: {
            if (invitation.visible && !moreItemManager.inviteItemVisible) {
                invitation.visible = false;
            }
        }
        onMangeParticipantsItemVisibleChanged: {
            if (!moreItemManager.mangeParticipantsItemVisible && !moreItemManager.participantsItemVisible) {
                membersBar.show = false;
                handsStatus.visible = false;
            }
        }
        onParticipantsItemVisibleChanged: {
            if (!moreItemManager.mangeParticipantsItemVisible && !moreItemManager.participantsItemVisible) {
                membersBar.show = false;
                handsStatus.visible = false;
            }
        }
    }
    Connections {
        target: GlobalChatManager

        onNoNewMsgNotity: {
            msgCount = 0;
            chatroom.msglistView.positionViewAtEnd();
            if (msgTipBtn.visible) {
                msgTipBtn.visible = false;
            }
        }
    }
    Connections {
        target: chatroom.verScrollBar

        onPositionChanged: {
            if (shareManager.shareAccountId === authManager.authAccountId) {
                if (chatroom.msglistView.atYEnd) {
                    chatroom.msglistView.positionViewAtEnd();
                    footerBar.recvNewChatMsg(0, "", "");
                }
            } else {
                if (chatroom.msglistView.atYEnd && chatBar.visible) {
                    GlobalChatManager.noNewMsgNotity();
                    chatroom.msglistView.positionViewAtEnd();
                    if (msgTipBtn.visible) {
                        msgTipBtn.visible = false;
                    }
                }
            }
        }
    }
    Connections {
        target: footerBar

        onHeightChanged: {
            if (handsStatus.visible === true) {
                if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                    const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                    handsStatus.x = Qt.binding(function () {
                            return handsStatusPos.x + handsStatus.width / 2;
                        });
                    handsStatus.y = Qt.binding(function () {
                            return handsStatusPos.y - handsStatus.height - 40;
                        });
                }
            }
        }
        onWidthChanged: {
            if (handsStatus.visible === true) {
                if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                    const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                    handsStatus.x = Qt.binding(function () {
                            return handsStatusPos.x + handsStatus.width / 2;
                        });
                    handsStatus.y = Qt.binding(function () {
                            return handsStatusPos.y - handsStatus.height - 40;
                        });
                }
            }
        }
    }
    Connections {
        target: mainWindow

        onHeightChanged: {
            if (handsStatus.visible === true) {
                if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                    const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                    handsStatus.x = Qt.binding(function () {
                            return handsStatusPos.x + handsStatus.width / 2;
                        });
                    handsStatus.y = Qt.binding(function () {
                            return handsStatusPos.y - handsStatus.height - 40;
                        });
                }
            }
        }
        onWidthChanged: {
            if (handsStatus.visible === true) {
                if (undefined !== footerBar.idMeetingToolBar.btnMembersCtrl) {
                    const handsStatusPos = footerBar.idMeetingToolBar.btnMembersCtrl.mapToItem(mainLayout, 0, 0);
                    handsStatus.x = Qt.binding(function () {
                            return handsStatusPos.x + handsStatus.width / 2;
                        });
                    handsStatus.y = Qt.binding(function () {
                            return handsStatusPos.y - handsStatus.height - 40;
                        });
                }
            }
        }
    }
    ParallelAnimation {
        id: showFooterContainer
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
            from: 0
            properties: "height"
            target: footerBar
            to: 68
        }
    }
    ParallelAnimation {
        id: hideFooterContainer
        NumberAnimation {
            duration: 300
            easing.type: Easing.Linear
            from: 68
            properties: "height"
            target: footerBar
            to: 0
        }
    }
    Connections {
        target: liveManager

        onLiveStateChanged: {
            liveTip.visible = state === 2;
            console.log("onLiveStateChanged state: ", state);
        }
    }
}
