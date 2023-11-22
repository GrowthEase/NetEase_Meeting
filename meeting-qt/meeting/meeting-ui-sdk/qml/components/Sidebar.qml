import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import NetEase.Meeting.MembersModel 1.0
import NetEase.Meeting.FilterProxyModel 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Settings.SettingsStatus 1.0
import "../components"

Rectangle {
    id: root
    enum AudioVolumeLevel {
        Level_1 = 1,
        Level_2,
        Level_3,
        Level_4,
        Level_5
    }

    property string backgroundColor: "#EF23232B"
    property string fontColor: "#333333"
    property int listviewHeight: 546
    property bool showTitle: true
    property int sidebarWidth: 280

    function closePopupMenu() {
        popupMenu.close();
    }
    function getAudioVolumeSourceImage(mute, level) {
        if (mute) {
            return "qrc:/qml/images/sidebar/voice_off.svg";
        }
        switch (level) {
        case Sidebar.AudioVolumeLevel.Level_1:
            return "qrc:/qml/images/sidebar/voice_on.png";
        case Sidebar.AudioVolumeLevel.Level_2:
            return "qrc:/qml/images/sidebar/voice_on_1.png";
        case Sidebar.AudioVolumeLevel.Level_3:
            return "qrc:/qml/images/sidebar/voice_on_2.png";
        case Sidebar.AudioVolumeLevel.Level_4:
            return "qrc:/qml/images/sidebar/voice_on_3.png";
        case Sidebar.AudioVolumeLevel.Level_5:
            return "qrc:/qml/images/sidebar/voice_on_4.png";
        default:
            return "qrc:/qml/images/sidebar/voice_on.png";
        }
    }
    function hide() {
        root.visible = false;
        sidebarStopAnim.start();
    }
    function muteAllowOpenbyself(type) {
        muteConfirmDialog.muteAllowOpenByself.disconnect(muteAllowOpenbyself);
        if (type === "audio") {
            audioManager.muteRemoteAudio("", true);
        } else if (type === "video") {
            videoManager.disableRemoteVideo("", true);
        }
    }
    function muteNotAllowOpenbyself(type) {
        muteConfirmDialog.muteNotAllowOpenByself.disconnect(muteNotAllowOpenbyself);
        if (type === "audio") {
            audioManager.muteRemoteAudio("", true, false);
        } else if (type === "video") {
            videoManager.disableRemoteVideo("", true, false);
        }
    }
    function restore() {
        searchItem.resetSearchBar();
    }
    function show() {
        root.visible = true;
        sidebarStartAnim.start();
    }
    function toggle() {
        if (!root.visible) {
            show();
        } else {
            hide();
        }
    }

    Accessible.name: "Sidebar"

    Component.onCompleted: {
        filterModel.setSortModel(membersModel);
    }

    MouseArea {
        acceptedButtons: Qt.LeftButton
        height: parent.height
        hoverEnabled: true
        width: parent.width - sidebar.width

        onClicked: {
            root.toggle();
        }
    }
    MenuEx {
        id: popupMenu
        Accessible.name: "moreMenu"
    }
    ColumnLayout {
        id: sidebar
        anchors.fill: parent
        spacing: 0

        ListModel {
            id: listModel
        }
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 0

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 40
                visible: showTitle

                Label {
                    id: title
                    Accessible.name: qsTr("Members")
                    color: fontColor
                    font.bold: true
                    font.pixelSize: 16
                    text: qsTr("Members") + " (" + listView.count.toString() + (meetingManager.maxCount > 0 ? ('/' + meetingManager.maxCount) : '') + ")"
                }
                Image {
                    height: 18
                    mipmap: true
                    mirror: true
                    source: "qrc:/qml/images/sidebar/muted_all.png"
                    visible: meetingManager.meetingMuted
                    width: 18
                }
            }
            Rectangle {
                Layout.fillWidth: true
                color: "#EBEDF0"
                height: 1
                opacity: .6
                visible: showTitle
            }
            SearchItem {
                id: searchItem
                Layout.bottomMargin: 10
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.preferredHeight: 32
                Layout.rightMargin: 20
                Layout.topMargin: 10
                color: "#F2F3F5"
                radius: 16
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#EBEDF0"
                opacity: .6
            }
            // Create filter model
            FilterProxyModel {
                id: filterModel
            }
            MembersModel {
                id: membersModel
                manager: membersManager

                onModelReset: {
                    popupMenu.close();
                }
                onRowsInserted: {
                    popupMenu.close();
                }
                onRowsRemoved: {
                    popupMenu.close();
                }
            }
            ListView {
                id: listView
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.leftMargin: 24
                Layout.rightMargin: 20
                clip: true
                model: filterModel

                ScrollBar.vertical: ScrollBar {
                    id: verScrollBar
                    width: 5
                }
                delegate: Rectangle {
                    id: delegate
                    color: "transparent"
                    height: 36

                    Rectangle {
                        id: itemMemberInfo
                        color: "transparent"
                        height: 36
                        width: listView.width - 8

                        // anchors.right: 20
                        Label {
                            id: itemNickname
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            color: fontColor
                            elide: Text.ElideRight
                            font.pixelSize: 14
                            text: {
                                let begin = "";
                                let middle = "";
                                let end = "";
                                if (roleType === 2) {
                                    begin = " (";
                                    end = ")";
                                    middle = qsTr("Host、");
                                } else if (roleType === 3) {
                                    begin = " (";
                                    end = ")";
                                    middle = qsTr("Manager、");
                                }
                                if (meetingManager.showMemberTag) {
                                    if (model.tag.length > 0) {
                                        begin = " (";
                                        end = ")";
                                        middle += (model.tag + '、');
                                    }
                                }
                                if (authManager.authAccountId === accountId) {
                                    begin = " (";
                                    end = ")";
                                    middle += qsTr("Me、");
                                }
                                middle = middle.substring(0, middle.length - 1);
                                return model.nickname + begin + middle + end;
                            }
                            width: itemMemberInfo.width - idRowLayout.width
                        }
                        RowLayout {
                            id: idRowLayout
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Image {
                                id: itemPhone
                                Layout.alignment: Qt.AlignVCenter
                                height: 14
                                mipmap: true
                                source: "qrc:/qml/images/sidebar/phone.svg"
                                visible: model.phoneStatus
                                width: 14
                            }
                            Image {
                                id: itemClientType
                                Layout.alignment: Qt.AlignVCenter
                                height: 14
                                mipmap: true
                                source: 'qrc:/qml/images/sidebar/member_sip.svg'
                                visible: model.clientType === 5
                                width: 14
                            }
                            Image {
                                id: itemHandsUp
                                Layout.alignment: Qt.AlignVCenter
                                height: 14
                                mipmap: true
                                source: "qrc:/qml/images/meeting/hand_raised_share.svg"
                                visible: model.handsUpStatus === MeetingStatus.HAND_STATUS_RAISE && (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole)
                                width: 14
                            }
                            Image {
                                id: itemWhiteboard
                                Layout.alignment: Qt.AlignVCenter
                                height: 14
                                mipmap: true
                                source: "qrc:/qml/images/sidebar/whiteboard_sharing.png"
                                visible: whiteboardManager.whiteboardSharerAccountId === model.accountId
                                width: 14

                                Connections {
                                    target: whiteboardManager

                                    onWhiteboardSharerAccountIdChanged: {
                                        itemWhiteboard.visible = Qt.binding(function () {
                                                return whiteboardManager.whiteboardSharerAccountId === model.accountId;
                                            });
                                    }
                                }
                            }
                            Image {
                                id: itemScreenSharing
                                Layout.alignment: Qt.AlignVCenter
                                height: 14
                                mipmap: true
                                source: "qrc:/qml/images/sidebar/screen_sharing.svg"
                                visible: shareManager.shareAccountId === model.accountId
                                width: 14

                                Connections {
                                    target: shareManager

                                    onShareAccountIdChanged: {
                                        itemScreenSharing.visible = Qt.binding(function () {
                                                return shareManager.shareAccountId === model.accountId;
                                            });
                                    }
                                }
                            }
                            Image {
                                id: itemVideo
                                Layout.alignment: Qt.AlignVCenter
                                height: 14
                                mipmap: true
                                source: model.videoStatus === 1 ? "qrc:/qml/images/sidebar/video_on.svg" : "qrc:/qml/images/sidebar/video_off.svg"
                                width: 14
                            }
                            Image {
                                id: itemAudio
                                Layout.alignment: Qt.AlignVCenter
                                height: 14
                                mipmap: true
                                source: getAudioVolumeSourceImage(model.audioStatus !== 1, model.audioVolume)
                                width: 14
                            }
                        }
                        Rectangle {
                            id: btnHandsUp
                            anchors.right: btnShowMore.left
                            anchors.rightMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#337EFF"
                            height: 22
                            radius: 2
                            visible: model.handsUpStatus === MeetingStatus.HAND_STATUS_RAISE && btnShowMore.visible === true && (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole)
                            width: 56

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole

                                onClicked: {
                                    membersManager.allowRemoteMemberHandsUp(model.accountId, false);
                                }
                                onEntered: {
                                    parent.color = "#649DFF";
                                }
                                onExited: {
                                    parent.color = "#337EFF";
                                }
                                onPressed: {
                                    parent.color = "#2E71E6";
                                }
                                onReleased: {
                                    if (containsMouse)
                                        parent.color = "#649DFF";
                                    else
                                        parent.color = "#337EFF";
                                }

                                Label {
                                    anchors.centerIn: parent
                                    color: "#FFFFFF"
                                    text: qsTr("Hands down")
                                }
                            }
                        }
                        Rectangle {
                            id: btnShowMore
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#337EFF"
                            height: 22
                            radius: 2
                            visible: false
                            width: SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage ? 60 : 44

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    popupMenu.accountId = model.accountId;
                                    popupMenu.nickname = model.nickname;
                                    popupMenu.audioStatus = model.audioStatus;
                                    popupMenu.videoStatus = model.videoStatus;
                                    popupMenu.isWhiteboardEnable = model.isWhiteboardEnable;
                                    popupMenu.clientType = model.clientType;
                                    popupMenu.isManagerRole = model.roleType === 3;
                                    let xTmp = -60;
                                    if (SettingsStatus.UILanguage_en === SettingsManager.uiLanguage) {
                                        xTmp = -115;
                                    } else if (SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage) {
                                        xTmp = -140;
                                    }
                                    const menuPostion = btnShowMore.mapToItem(sidebar, xTmp, btnShowMore.height + 5);
                                    popupMenu.x = menuPostion.x;
                                    popupMenu.y = menuPostion.y;
                                    popupMenu.open();
                                }
                                onEntered: {
                                    parent.color = "#649DFF";
                                }
                                onExited: {
                                    parent.color = "#337EFF";
                                }
                                onPressed: {
                                    parent.color = "#2E71E6";
                                }
                                onReleased: {
                                    if (containsMouse)
                                        parent.color = "#649DFF";
                                    else
                                        parent.color = "#337EFF";
                                }
                            }
                            Label {
                                id: more
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#FFFFFF"
                                text: qsTr("more")
                            }
                        }
                    }
                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        height: 28
                        hoverEnabled: true
                        propagateComposedEvents: true
                        visible: {
                            if (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole) {
                                return true;
                            }
                            if (authManager.authAccountId === accountId && meetingManager.reName === true) {
                                return true;
                            } else {
                                if (whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId && authManager.authAccountId !== accountId) {
                                    return true;
                                }
                                return false;
                            }
                        }
                        width: listView.width

                        onClicked: {
                            mouse.accepted = false;
                        }
                        onEntered: {
                            itemScreenSharing.visible = false;
                            itemVideo.visible = false;
                            itemAudio.visible = false;
                            itemHandsUp.visible = false;
                            itemClientType.visible = false;
                            btnShowMore.visible = true;
                            itemWhiteboard.visible = false;
                        }
                        onExited: {
                            itemScreenSharing.visible = Qt.binding(function () {
                                    return shareManager.shareAccountId === accountId;
                                });
                            itemVideo.visible = true;
                            itemAudio.visible = true;
                            itemClientType.visible = Qt.binding(function () {
                                    return model.clientType === 5;
                                });
                            itemHandsUp.visible = Qt.binding(function () {
                                    return model.handsUpStatus === MeetingStatus.HAND_STATUS_RAISE && (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole);
                                });
                            btnShowMore.visible = false;
                            itemWhiteboard.visible = Qt.binding(function () {
                                    return whiteboardManager.whiteboardSharerAccountId === model.accountId;
                                });
                        }
                        onPressed: {
                            mouse.accepted = false;
                        }
                        onReleased: {
                            mouse.accepted = false;
                        }
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#EBEDF0"
                opacity: .6
                visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole
            }
            RowLayout {
                Layout.leftMargin: 20
                Layout.preferredHeight: 46
                Layout.preferredWidth: parent.width
                Layout.rightMargin: 20
                spacing: 0
                visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole

                Label {
                    Layout.alignment: Qt.AlignLeft
                    color: fontColor
                    font.pixelSize: 14
                    text: qsTr("Lock")
                }
                CustomSwitch {
                    id: switchLock
                    Accessible.name: qsTr("Lock")
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: 48
                    checked: meetingManager.meetingLocked

                    MouseArea {
                        anchors.fill: parent

                        onClicked: meetingManager.lockMeeting(!switchLock.checked)
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#EBEDF0"
                opacity: .6
                visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole === true
            }
        }
        ColumnLayout {
            id: toolbuttonLayout
            Layout.fillHeight: true // (meetingManager.hideMuteAllVideo || meetingManager.hideMuteAllAudio) ? 56 : 102
            Layout.fillWidth: true
            spacing: 0
            visible: (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole) && (!meetingManager.hideMuteAllVideo || !meetingManager.hideMuteAllAudio)

            RowLayout {
                id: videoAllControl
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                spacing: 10
                visible: (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole) && !meetingManager.hideMuteAllVideo

                Item {
                    Layout.fillWidth: true
                }
                CustomButton {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 135
                    buttonRadius: 18
                    font.pixelSize: 15
                    highlighted: true
                    text: qsTr("Mute All Video")

                    onClicked: {
                        muteConfirmDialog.text = qsTr('all and new member video will be muted');
                        muteConfirmDialog.checkText = qsTr("allow member self video on");
                        muteConfirmDialog.controlType = "video";
                        muteConfirmDialog.muteAllowOpenByself.disconnect(muteAllowOpenbyself);
                        muteConfirmDialog.muteNotAllowOpenByself.disconnect(muteNotAllowOpenbyself);
                        muteConfirmDialog.muteAllowOpenByself.connect(muteAllowOpenbyself);
                        muteConfirmDialog.muteNotAllowOpenByself.connect(muteNotAllowOpenbyself);
                        muteConfirmDialog.open();
                    }
                }
                CustomButton {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 135
                    buttonRadius: 18
                    font.pixelSize: 15
                    highlighted: true
                    text: qsTr("Unmute All Video")

                    onClicked: {
                        videoManager.disableRemoteVideo("", false);
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
            }
            RowLayout {
                id: audioAllControl
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                spacing: 10
                visible: (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole === true) && !meetingManager.hideMuteAllAudio

                Item {
                    Layout.fillWidth: true
                }
                CustomButton {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 135
                    buttonRadius: 18
                    font.pixelSize: 15
                    highlighted: true
                    text: qsTr("Mute All")

                    onClicked: {
                        muteConfirmDialog.text = qsTr('all and new member will be muted');
                        muteConfirmDialog.checkText = qsTr("allow member self audio on");
                        muteConfirmDialog.controlType = "audio";
                        muteConfirmDialog.muteAllowOpenByself.disconnect(muteAllowOpenbyself);
                        muteConfirmDialog.muteNotAllowOpenByself.disconnect(muteNotAllowOpenbyself);
                        muteConfirmDialog.muteAllowOpenByself.connect(muteAllowOpenbyself);
                        muteConfirmDialog.muteNotAllowOpenByself.connect(muteNotAllowOpenbyself);
                        muteConfirmDialog.open();
                    }
                }
                CustomButton {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 135
                    buttonRadius: 18
                    font.pixelSize: 15
                    highlighted: true
                    text: qsTr("Unmute All")

                    onClicked: {
                        audioManager.muteRemoteAudio("", false);
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
    ParallelAnimation {
        id: sidebarStartAnim
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutQuad
            from: parent.width
            properties: "x"
            target: sidebar
            to: parent.width - sidebar.width
        }
    }
    ParallelAnimation {
        id: sidebarStopAnim
        NumberAnimation {
            duration: 100
            easing.type: Easing.Linear
            from: parent.width - sidebar.width
            properties: "x"
            target: sidebar
            to: parent.width
        }
    }
    Connections {
        target: searchItem

        onTextChanged: {
            filterModel.setFilterString(text);
        }
    }
}
