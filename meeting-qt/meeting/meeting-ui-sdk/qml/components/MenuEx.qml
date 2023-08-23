import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.14
import Qt5Compat.GraphicalEffects
import NetEase.Settings.SettingsStatus 1.0
import "../utils/dialogManager.js" as DialogManager
import "../components"

Menu {
    property string accountId: ""
    property string nickname: ""
    property int audioStatus: 1
    property int videoStatus: 1
    property int clientType: -1
    property bool isWhiteboardEnable: false
    property bool isManagerRole: false
    property var popupModifyNickname: undefined

    id: popupMenu
    width: {
        if (SettingsStatus.UILanguage_en === SettingsManager.uiLanguage) {
            return 180
        } else if (SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage) {
            return 220
        } else {
            return 120
        }
    }
    background: Rectangle {
        id: bgRectangle
        radius: 4
        layer.enabled: true
        layer.effect: DropShadow {
            width: bgRectangle.width
            height: bgRectangle.height
            x: bgRectangle.x
            y: bgRectangle.y
            visible: bgRectangle.visible
            source: bgRectangle
            horizontalOffset: 0
            verticalOffset: 0
            radius: 16
            samples: 33
            color: "#1917171a"
        }
    }

    MenuItem {
        id: modifyName
        width: parent.width
        height: authManager.authAccountId === accountId && meetingManager.reName ? 32 : 0
        visible: authManager.authAccountId === accountId && meetingManager.reName
        Label {
            id: modifyNameItem
            text: qsTr("Change Nickname")
            color: modifyName.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: modifyName.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                if (popupModifyNickname != undefined) {
                    popupModifyNickname.destroy()
                    popupModifyNickname = undefined
                }
                var object = {}
                object.nick = nickname
                popupModifyNickname = Qt.createComponent("ModifyNickname.qml").createObject(mainLayout,object)
                popupModifyNickname.open()
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: modifyNameItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: mute
        width: parent.width
        height: visible ? 32 : 0
        visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole
        Label {
            id: muteItem
            text: audioStatus === 1 ? qsTr("Mute")
                                    : qsTr("Unmute")
            color: mute.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: mute.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                if (accountId === authManager.authAccountId) {
                    audioManager.muteLocalAudio(audioStatus === 1)
                } else {
                    audioManager.muteRemoteAudio(accountId, audioStatus === 1)
                }
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: muteItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: disableVideo
        width: parent.width
        height: visible ? 32 : 0
        visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole
        Label {
            id: disableVideoItem
            text: videoStatus === 1 ? qsTr("Disable Video") : qsTr("Enable Video")
            color: disableVideo.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: disableVideo.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                videoManager.disableRemoteVideo(accountId, videoStatus === 1)
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: disableVideoItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: muteVideoAndAudio
        width: parent.width
        height: visible ? 32 : 0
        visible: membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole
        Label {
            id: muteVideoAndAudioItem
            text: (videoStatus == 1 && audioStatus == 1) ? qsTr("Mute Video/Audio") : qsTr("Unmute Video/Audio")
            color: muteVideoAndAudio.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: muteVideoAndAudio.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                if (accountId === authManager.authAccountId) {
                    if (muteVideoAndAudioItem.text === qsTr("Mute Video/Audio")) {
                        if (audioStatus === 1) {
                            audioManager.muteLocalAudio(true)
                        }
                        if (videoStatus === 1) {
                            videoManager.disableLocalVideo(true)
                        }
                    } else {
                        if (audioStatus !== 1) {
                            audioManager.muteLocalAudio(false)
                        }
                        if (videoStatus !== 1) {
                            videoManager.disableLocalVideo(false)
                        }
                    }
                } else {
                    membersManager.muteRemoteVideoAndAudio(accountId, (videoStatus === 1 && audioStatus === 1))
                }
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: muteVideoAndAudioItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: setupSpeaker
        width: parent.width
        height: visible ? 32 : 0
        visible: (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole)
                 && shareManager.shareAccountId.length === 0
        Label {
            id: setupSpeakerItem
            text: {
                if (videoManager.focusAccountId === accountId) {
                    return qsTr("Unset Speaker")
                }
                return qsTr("Set Speaker")
            }

            color: setupSpeaker.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: setupSpeaker.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                if (videoManager.focusAccountId === accountId) {
                    membersManager.setAsFocus(accountId, false)
                } else {
                    membersManager.setAsFocus(accountId, true)
                }
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: setupSpeakerItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: transferHost
        width: parent.width
        height: visible ? 32 : 0
        visible: membersManager.hostAccountId !== accountId
                 && membersManager.hostAccountId === authManager.authAccountId
                 && clientType != 5
        Label {
            id: transferHostItem
            text: qsTr("Transfer Host")
            color: transferHost.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: transferHost.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                DialogManager.dynamicDialog(qsTr("Transfer Host"), qsTr("Do you want to transfer host to %1 ?").arg(nickname), function () {
                    membersManager.setAsHost(accountId)
                }, function () {}, Window.window)
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: transferHostItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)

    }

    MenuItem {
        id: setManager
        width: parent.width
        height: visible ? 32 : 0
        visible: membersManager.hostAccountId !== accountId && (membersManager.hostAccountId === authManager.authAccountId)
        Label {
            id: setManagerItem
            text: isManagerRole ? qsTr("Remove Co-host") : qsTr("Set as Co-host")
            color: setManager.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: setManager.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                isManagerRole ? membersManager.setAsMember(accountId, nickname) : membersManager.setAsManager(accountId, nickname)
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: setManagerItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: enableWhiteboard
        width: parent.width
        height: visible ? 32 : 0
        visible: (whiteboardManager.whiteboardSharing === true)
                 && (accountId !== authManager.authAccountId)
                 && (whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId)
        Label {
            id: enableWhiteboardItem
            text: isWhiteboardEnable ? qsTr("Revoke Board Access") : qsTr("Assign Board Access")
            color: enableWhiteboard.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: enableWhiteboard.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                if(isWhiteboardEnable) {
                    whiteboardManager.disableWhiteboardDraw(accountId)
                }else{
                    whiteboardManager.enableWhiteboardDraw(accountId)
                }
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: enableWhiteboardItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: closeWhiteboardShare
        width: parent.width
        height: visible ? 32 : 0
        visible: (whiteboardManager.whiteboardSharing === true)
                 && (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole)
                 && (whiteboardManager.whiteboardSharerAccountId === accountId)
                 && (accountId !== membersManager.hostAccountId)
        Label {
            id: closeWhiteboardShareItem
            text: qsTr("End Board Collaboration")
            color: closeWhiteboardShare.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: closeWhiteboardShare.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                DialogManager.dynamicDialog(qsTr("End Board Collaboration"), qsTr("The current user is performing the whiteboard function and is sure to close its sharing ?"), function () {
                    whiteboardManager.closeWhiteboard(accountId)
                }, function () {}, Window.window)
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: closeWhiteboardShareItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: closeScreenShare
        width: parent.width
        height: visible ? 32 : 0
        visible:  (membersManager.hostAccountId === authManager.authAccountId || membersManager.isManagerRole)
                  && (shareManager.shareAccountId === accountId)
                  && (accountId !== membersManager.hostAccountId)
        Label {
            id: closeScreenShareItem
            text: qsTr("End Screen Collaboration")
            color: closeScreenShare.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: closeScreenShare.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                DialogManager.dynamicDialog(qsTr("End Screen Collaboration"), qsTr("The current user is performing the Screen sharing function and is sure to close its sharing ?"), function () {
                    shareManager.stopScreenSharing(accountId)
                }, function () {}, Window.window)
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: closeScreenShareItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: removeMember
        width: parent.width
        height: visible ? 32 : 0
        visible: (membersManager.hostAccountId === authManager.authAccountId && membersManager.hostAccountId !== accountId)
                    || (membersManager.isManagerRole && membersManager.hostAccountId !== accountId && !isManagerRole)
        Label {
            id: removeMemberItem
            text: qsTr("Remove")
            color: removeMember.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: removeMember.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                popupMenu.close()
                if (accountId === authManager.authAccountId) {
                    toast.show(qsTr("Can not remove your self."))
                } else {
                    DialogManager.dynamicDialog(qsTr("Remove Member"), qsTr("Do you want to remove %1?").arg(nickname), function () {
                        membersManager.kickMember(accountId)
                    }, function () {}, Window.window)
                }
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: removeMemberItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }
}
