import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import NetEase.Meeting.MembersModel 1.0
import NetEase.Meeting.FilterProxyModel 1.0
import NetEase.Meeting.MeetingStatus 1.0

import '../components'
Rectangle {
    id: root

    Accessible.name: "Sidebar"

    property int sidebarWidth: 280
    property string backgroundColor: "#EF23232B"
    property string fontColor: "#333333"
    property int  listviewHeight: 546
    property bool showTitle: true

    enum AudioVolumeLevel {
        Level_1 = 1,
        Level_2,
        Level_3,
        Level_4,
        Level_5
    }

    MouseArea {
        width: parent.width - sidebar.width
        height: parent.height
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: {
            toggle()
        }
    }

    MenuEx {
        id: popupMenu
        Accessible.name: "moreMenu"
    }

    Component.onCompleted: {
        filterModel.setSortModel(membersModel);
    }

    ColumnLayout {
        id: sidebar
        anchors.fill: parent
        spacing: 0

        ListModel {
            id: listModel
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            RowLayout {
                visible: showTitle
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 40
                Label {
                    id: title
                    text: qsTr("Members") + " (" + listView.count.toString() + (meetingManager.maxCount > 0 ? ('/' + meetingManager.maxCount) : '')  + ")"
                    color: fontColor
                    font.pixelSize: 16
                    font.bold: true
                    Accessible.name: qsTr("Members")
                }

                Image {
                    width: 18
                    height: 18
                    mirror: true
                    visible: meetingManager.meetingMuted
                    mipmap: true
                    source: "qrc:/qml/images/sidebar/muted_all.png"
                }
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: "#EBEDF0"
                opacity: .6
                visible: showTitle
            }

            SearchItem {
                id: searchItem
                Layout.preferredHeight: 32
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                color: "#F2F3F5"
                radius: 16
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: "#EBEDF0"
                opacity: .6
            }
            //Create filter model
            FilterProxyModel {
                id: filterModel
            }

            MembersModel {
                id: membersModel
                manager: membersManager
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 24
                Layout.rightMargin: 20
                clip: true
                model: filterModel

                delegate: Rectangle {
                    id: delegate
                    height: 36
                    color: "transparent"
                    Rectangle {
                        id: itemMemberInfo
                        width: listView.width - 8
                        height: 36
                        color: "transparent"
                        // anchors.right: 20
                        Label {
                            id: itemNickname
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: 60
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            text: {
                                let begin = ""
                                let middle = ""
                                let end = ""
                                if(roleType == 2){
                                    begin = " ("
                                    end = ")"
                                    middle = qsTr("Host、")
                                } else if(roleType == 3){
                                    begin = " ("
                                    end = ")"
                                    middle = qsTr("Manager、")
                                }

                                if(meetingManager.showMemberTag) {
                                    middle += model.tag.length > 0 ? (model.tag + '、') : ''
                                }

                                if (authManager.authAccountId === accountId) {
                                    begin = " ("
                                    end = ")"
                                    middle += qsTr("Me、")
                                }
                                middle = middle.substring(0, middle.length - 1)
                                return model.nickname + begin + middle + end
                            }
                            font.pixelSize: 14
                            color: fontColor
                        }
                        Image {
                            id: itemClientType
                            width: 14
                            height: 14
                            anchors.right: itemHandsUp.visible ? itemHandsUp.left : itemVideo.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            source: 'qrc:/qml/images/sidebar/member_sip.svg'
                            mipmap: true
                            visible: model.clientType === 5
                        }
                        Image {
                            id: itemScreenSharing
                            anchors.right: itemHandsUp.visible ? itemHandsUp.left : itemVideo.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            visible: shareManager.shareAccountId === model.accountId
                            width: 14
                            height: 14
                            source: "qrc:/qml/images/sidebar/screen_sharing.svg"
                            mipmap: true
                            Layout.alignment: Qt.AlignHRight | Qt.AlignVCenter
                            Connections {
                                target: shareManager
                                onShareAccountIdChanged: {
                                    itemScreenSharing.visible = Qt.binding(function(){return shareManager.shareAccountId === model.accountId})
                                }
                            }
                        }
                        Image {
                            id: itemHandsUp
                            anchors.right: itemVideo.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            visible: model.handsUpStatus === MeetingStatus.HAND_STATUS_RAISE &&
                                     (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole)
                            source: "qrc:/qml/images/meeting/hand_raised_share.svg"
                            mipmap: true
                            Layout.alignment: Qt.AlignHRight | Qt.AlignVCenter
                        }
                        Image {
                            id: itemVideo
                            anchors.right: itemAudio.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            source: model.videoStatus === 1 ? "qrc:/qml/images/sidebar/video_on.svg" : "qrc:/qml/images/sidebar/video_off.svg"
                            mipmap: true
                            Layout.alignment: Qt.AlignHRight | Qt.AlignVCenter
                        }
                        Image {
                            id: itemAudio
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            source: getAudioVolumeSourceImage(model.audioStatus !== 1, model.audioVolume)
                            mipmap: true
                        }
                        Image {
                            id: itemWhiteboard
                            anchors.right: itemHandsUp.visible ? itemHandsUp.left : itemVideo.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            visible: whiteboardManager.whiteboardSharerAccountId === model.accountId
                            width: 14
                            height: 14
                            source: "qrc:/qml/images/sidebar/whiteboard_sharing.png"
                            mipmap: true
                            Layout.alignment: Qt.AlignHRight | Qt.AlignVCenter
                            Connections {
                                target: whiteboardManager
                                onWhiteboardSharerAccountIdChanged: {
                                    itemWhiteboard.visible = Qt.binding(function(){return whiteboardManager.whiteboardSharerAccountId === model.accountId})
                                }
                            }
                        }
                        Rectangle{
                            id:btnHandsUp
                            anchors.right:btnShowMore.left
                            anchors.rightMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            width: 56
                            height: 22
                            radius: 2
                            color: "#337EFF"
                            visible:  model.handsUpStatus === MeetingStatus.HAND_STATUS_RAISE && btnShowMore.visible === true &&
                                      (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole)
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                visible: membersManager.hostAccountId === authManager.authAccountId
                                         || membersManager.isManagerRole
                                onEntered: {
                                    parent.color = "#649DFF"
                                }
                                onExited: {
                                    parent.color = "#337EFF"
                                }
                                onPressed: {
                                    parent.color = "#2E71E6"
                                }
                                onReleased: {
                                    if (containsMouse)
                                        parent.color = "#649DFF"
                                    else
                                        parent.color = "#337EFF"
                                }
                                onClicked: {
                                    membersManager.allowRemoteMemberHandsUp(model.accountId, false)
                                }

                                Label {
                                    text: qsTr("Hands down")
                                    color: "#FFFFFF"
                                    anchors.centerIn: parent
                                }
                            }
                        }

                        Rectangle {
                            id: btnShowMore
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 44
                            height: 22
                            radius: 2
                            color: "#337EFF"
                            visible: false
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onEntered: {
                                    parent.color = "#649DFF"
                                }
                                onExited: {
                                    parent.color = "#337EFF"
                                }
                                onPressed: {
                                    parent.color = "#2E71E6"
                                }
                                onReleased: {
                                    if (containsMouse)
                                        parent.color = "#649DFF"
                                    else
                                        parent.color = "#337EFF"
                                }
                                onClicked: {
                                    popupMenu.accountId = model.accountId
                                    popupMenu.nickname = model.nickname
                                    popupMenu.audioStatus = model.audioStatus
                                    popupMenu.videoStatus = model.videoStatus
                                    popupMenu.isWhiteboardEnable = model.isWhiteboardEnable
                                    popupMenu.clientType = model.clientType
                                    popupMenu.isManagerRole = model.roleType === 3
                                    const menuPostion = btnShowMore.mapToItem(sidebar, -60, btnShowMore.height + 5)
                                    popupMenu.x = menuPostion.x
                                    popupMenu.y = menuPostion.y
                                    popupMenu.open()
                                }

                            }

                            Label {
                                id:more
                                text: qsTr("more")
                                color: "#FFFFFF"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    MouseArea {
                        height: 28
                        width: listView.width
                        hoverEnabled: true
                        propagateComposedEvents: true
                        visible: {
                            if(membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole){
                                return true
                            }
                            if(authManager.authAccountId === accountId && meetingManager.reName === true){
                                return true
                            }
                            else{
                                if(whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId && authManager.authAccountId !== accountId){
                                    return true
                                }
                                return false
                            }
                        }
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            itemScreenSharing.visible = false
                            itemVideo.visible = false
                            itemAudio.visible = false
                            itemHandsUp.visible = false
                            itemClientType.visible = false
                            btnShowMore.visible = true
                            itemWhiteboard.visible = false

                        }
                        onExited: {
                            itemScreenSharing.visible = Qt.binding(function(){ return shareManager.shareAccountId === accountId })
                            itemVideo.visible = true
                            itemAudio.visible = true
                            itemClientType.visible = Qt.binding(function() { return model.clientType === 5 })
                            itemHandsUp.visible = Qt.binding(function(){
                                return model.handsUpStatus === MeetingStatus.HAND_STATUS_RAISE
                                        && (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole) })
                            btnShowMore.visible = false
                            itemWhiteboard.visible = Qt.binding(function(){return whiteboardManager.whiteboardSharerAccountId === model.accountId})
                        }
                        onClicked: {
                            mouse.accepted = false
                        }
                        onPressed: {
                            mouse.accepted = false
                        }
                        onReleased: {
                            mouse.accepted = false
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    id: verScrollBar
                    width: 5
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: "#EBEDF0"
                opacity: .6
                visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole
            }

            RowLayout {
                spacing: 0
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 46
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole
                Label {
                    Layout.alignment: Qt.AlignLeft
                    text: qsTr("Lock")
                    color: fontColor
                    font.pixelSize: 14
                }
                CustomSwitch {
                    id: switchLock
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 28
                    Layout.alignment: Qt.AlignRight
                    checked: meetingManager.meetingLocked
                    MouseArea {
                        anchors.fill: parent
                        onClicked: meetingManager.lockMeeting(!switchLock.checked)
                    }
                    Accessible.name: qsTr("Lock")
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: "#EBEDF0"
                opacity: .6
                visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole === true
            }
        }

        ColumnLayout {
            id: toolbuttonLayout
            spacing: 0
            Layout.fillWidth: true
            Layout.preferredHeight: (meetingManager.hideMuteAllVideo || meetingManager.hideMuteAllAudio) ? 56 : 102
            visible: (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole)
                     && (!meetingManager.hideMuteAllVideo || !meetingManager.hideMuteAllAudio)

            RowLayout {
                id: videoAllControl
                spacing: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight:46
                visible: (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole)
                         && !meetingManager.hideMuteAllVideo
                Item { Layout.fillWidth: true }
                CustomButton {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 135
                    highlighted: true
                    text: qsTr("Mute All Video")
                    font.pixelSize: 15
                    buttonRadius: 18
                    onClicked: {
                        muteConfirmDialog.text = qsTr('all and new member video will be muted')
                        muteConfirmDialog.checkText = qsTr("allow member self video on");
                        muteConfirmDialog.controlType = "video"
                        muteConfirmDialog.muteAllowOpenByself.disconnect(muteAllowOpenbyself)
                        muteConfirmDialog.muteNotAllowOpenByself.disconnect(muteNotAllowOpenbyself)
                        muteConfirmDialog.muteAllowOpenByself.connect(muteAllowOpenbyself)
                        muteConfirmDialog.muteNotAllowOpenByself.connect(muteNotAllowOpenbyself)
                        muteConfirmDialog.open()
                    }
                }
                CustomButton {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 135
                    highlighted: true
                    text: qsTr("Unmute All Video")
                    font.pixelSize: 15
                    buttonRadius: 18
                    onClicked: {
                        videoManager.disableRemoteVideo("", false)
                    }
                }
                Item { Layout.fillWidth: true }
            }

            RowLayout {
                id: audioAllControl
                spacing: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 46
                visible: (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole === true) && !meetingManager.hideMuteAllAudio

//                    console.log("audioAllControl visible")

                Item { Layout.fillWidth: true }
                CustomButton {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 135
                    highlighted: true
                    text: qsTr("Mute All")
                    font.pixelSize: 15
                    buttonRadius: 18
                    onClicked: {
                        muteConfirmDialog.text = qsTr('all and new member will be muted')
                        muteConfirmDialog.checkText = qsTr("allow member self audio on");
                        muteConfirmDialog.controlType = "audio"
                        muteConfirmDialog.muteAllowOpenByself.disconnect(muteAllowOpenbyself)
                        muteConfirmDialog.muteNotAllowOpenByself.disconnect(muteNotAllowOpenbyself)
                        muteConfirmDialog.muteAllowOpenByself.connect(muteAllowOpenbyself)
                        muteConfirmDialog.muteNotAllowOpenByself.connect(muteNotAllowOpenbyself)
                        muteConfirmDialog.open()
                    }
                }
                CustomButton {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 135
                    highlighted: true
                    text: qsTr("Unmute All")
                    font.pixelSize: 15
                    buttonRadius: 18
                    onClicked: {
                        audioManager.muteRemoteAudio("", false)
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }
    }

    ParallelAnimation {
        id: sidebarStartAnim
        NumberAnimation {
            target: sidebar
            properties: "x"
            from: parent.width
            to: parent.width - sidebar.width
            duration: 500
            easing.type: Easing.OutQuad
        }
    }

    ParallelAnimation {
        id: sidebarStopAnim

        NumberAnimation {
            target: sidebar
            properties: "x"
            from: parent.width - sidebar.width
            to: parent.width
            duration: 100;
            easing.type: Easing.Linear
        }
    }

    Connections {
        target: searchItem
        onTextChanged: {
            filterModel.setFilterString(text)
        }
    }

    function toggle() {
        if (!root.visible) {
            show()
        } else {
            hide()
        }
    }

    function show() {
        root.visible = true
        sidebarStartAnim.start()
    }

    function hide() {
        root.visible = false
        sidebarStopAnim.start()
    }

    function restore() {
        searchItem.resetSearchBar()
    }

    function muteAllowOpenbyself(type){
        muteConfirmDialog.muteAllowOpenByself.disconnect(muteAllowOpenbyself)
        if(type === "audio") {
            audioManager.muteRemoteAudio("", true)
        } else if(type === "video") {
            videoManager.disableRemoteVideo("",true)
        }
    }

    function muteNotAllowOpenbyself(type){
        muteConfirmDialog.muteNotAllowOpenByself.disconnect(muteNotAllowOpenbyself)
        if(type === "audio") {
            audioManager.muteRemoteAudio("", true, false);
        } else if(type === "video") {
            videoManager.disableRemoteVideo("",true, false)
        }

    }

    function getAudioVolumeSourceImage(mute,level) {
        if(mute) {
            return "qrc:/qml/images/sidebar/voice_off.svg"
        }

        switch (level) {
            case Sidebar.AudioVolumeLevel.Level_1:
                return "qrc:/qml/images/sidebar/voice_on.png"
            case Sidebar.AudioVolumeLevel.Level_2:
                return "qrc:/qml/images/sidebar/voice_on_1.png"
            case Sidebar.AudioVolumeLevel.Level_3:
                return "qrc:/qml/images/sidebar/voice_on_2.png"
            case Sidebar.AudioVolumeLevel.Level_4:
                return "qrc:/qml/images/sidebar/voice_on_3.png"
            case Sidebar.AudioVolumeLevel.Level_5:
                return "qrc:/qml/images/sidebar/voice_on_4.png"
            default:
                return "qrc:/qml/images/sidebar/voice_on.png"
        }
    }
}
