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

    property int sidebarWidth: 280
    property string backgroundColor: "#EF23232B"
    property string fontColor: "#333333"
    property int  listviewHeight: 546
    property bool showTitle: true

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
                    text: qsTr("Members") + " (" + listView.count.toString() + ")"
                    color: fontColor
                    font.pixelSize: 16
                    font.bold: true
                }

                Image {
                    width: 18
                    height: 18
                    mirror: true
                    visible: meetingManager.meetingMuted
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
                                if (membersManager.hostAccountId === accountId) {
                                    begin = " ("
                                    end = ")"
                                    middle = qsTr("Host、")
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
                            anchors.left: itemNickname.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            source: 'qrc:/qml/images/sidebar/member_sip.svg'
                            visible: model.clientType === MembersModel.CLIENT_TYPE_SIP
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
                            visible: model.handsUpStatus === MeetingStatus.HAND_STATUS_RAISE && membersManager.hostAccountId === authManager.authAccountId
                            source: "qrc:/qml/images/meeting/hand_raised_share.svg"
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
                            Layout.alignment: Qt.AlignHRight | Qt.AlignVCenter
                        }
                        Image {
                            id: itemAudio
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            source: model.audioStatus === 1 ? "qrc:/qml/images/sidebar/voice_on.svg" : "qrc:/qml/images/sidebar/voice_off.svg"
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
                            visible:  model.handsUpStatus === MeetingStatus.HAND_STATUS_RAISE && btnShowMore.visible === true && membersManager.hostAccountId === authManager.authAccountId
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                visible: membersManager.hostAccountId === authManager.authAccountId
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
                                    audioManager.allowRemoteMemberHandsUp( model.accountId, false)
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
                                    if(membersManager.hostAccountId === authManager.authAccountId){
                                        return true
                                    }
                                    else{
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
                            itemClientType.visible = Qt.binding(function() { return model.clientType === MembersModel.CLIENT_TYPE_SIP })
                            itemHandsUp.visible = Qt.binding(function(){return model.handsUpStatus === MeetingStatus.HAND_STATUS_RAISE && membersManager.hostAccountId === authManager.authAccountId })
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
                visible: membersManager.hostAccountId === authManager.authAccountId
            }

            RowLayout {
                spacing: 0
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 46
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                visible: membersManager.hostAccountId === authManager.authAccountId
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
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: "#EBEDF0"
                opacity: .6
                visible: membersManager.hostAccountId === authManager.authAccountId
            }
        }

        RowLayout {
            id: toolbuttonLayout
            spacing: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 68
            visible: membersManager.hostAccountId === authManager.authAccountId
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


    function muteAllowOpenbyself(){
        muteConfirmDialog.muteAllowOpenByself.disconnect(muteAllowOpenbyself)
        audioManager.muteRemoteAudio("", true)
    }

    function muteNotAllowOpenbyself(){
        muteConfirmDialog.muteNotAllowOpenByself.disconnect(muteNotAllowOpenbyself)
        audioManager.muteRemoteAudio("", true, false);
    }
}
