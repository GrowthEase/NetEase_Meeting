import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.14
import QtGraphicalEffects 1.12

import "../utils/dialogManager.js" as DialogManager
import "../components"

Menu {
    property string accountId: ""
    property string nickname: ""
    property int audioStatus: 1
    property int videoStatus: 1
    property bool isWhiteboardEnable: false
    property var popupModifyNickname: undefined

    id: popupMenu
    width: 108
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
            text: qsTr("modifyName")
            color: modifyName.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: modifyName.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        onClicked: {
            if (popupModifyNickname != undefined) {
                popupModifyNickname.destroy()
                popupModifyNickname = undefined
            }
            var object = {}
            object.nick = nickname
            popupModifyNickname = Qt.createComponent("ModifyNickname.qml").createObject(mainLayout,object)
            popupModifyNickname.open()
        }
        Accessible.role: Accessible.Button
        Accessible.name: modifyNameItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: mute
        width: parent.width
        height: visible ? 32 : 0
        visible: membersManager.hostAccountId === authManager.authAccountId
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
        onClicked: {
            audioManager.muteRemoteAudio(accountId, audioStatus === 1)
        }
        Accessible.role: Accessible.Button
        Accessible.name: muteItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: disableVideo
        width: parent.width
        height: visible ? 32 : 0
        visible: shareManager.shareAccountId !== accountId && membersManager.hostAccountId === authManager.authAccountId
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
        onClicked: {
            videoManager.disableRemoteVideo(accountId, videoStatus === 1)
        }
        Accessible.role: Accessible.Button
        Accessible.name: disableVideoItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: setupSpeaker
        width: parent.width
        height: visible ? 32 : 0
        visible: membersManager.hostAccountId === authManager.authAccountId && shareManager.shareAccountId.length === 0
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
        onClicked: {
            if (videoManager.focusAccountId === accountId) {
                membersManager.setAsFocus(accountId, false)
            } else {
                membersManager.setAsFocus(accountId, true)
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
        visible: membersManager.hostAccountId !== accountId &&  membersManager.hostAccountId === authManager.authAccountId
        Label {
            id: transferHostItem
            text: qsTr("TransferHost")
            color: transferHost.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: transferHost.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        onClicked: {
            DialogManager.dynamicDialog(qsTr("Transfer Host"), qsTr("Do you want to transfer host to %1 ?").arg(nickname), function () {
                membersManager.setAsHost(accountId)
            }, function () {}, Window.window)
        }
        Accessible.role: Accessible.Button
        Accessible.name: transferHostItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: removeMember
        width: parent.width
        height: visible ? 32 : 0
        visible: membersManager.hostAccountId !== accountId && membersManager.hostAccountId === authManager.authAccountId
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
        onClicked: {
            if (accountId === authManager.authAccountId) {
                toast.show(qsTr("Can not remove your self."))
            } else {
                DialogManager.dynamicDialog(qsTr("Remove Member"), qsTr("Do you want to remove %1?").arg(nickname), function () {
                    membersManager.kickMember(accountId)
                }, function () {}, Window.window)
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: removeMemberItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: enableWhiteboard
        width: parent.width
        height: visible ? 32 : 0
        visible: (whiteboardManager.whiteboardSharing == true)
                 && (accountId !== authManager.authAccountId)
                 && (whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId)
        Label {
            id: enableWhiteboardItem
            text: isWhiteboardEnable ? qsTr("disableWhiteboard") : qsTr("enableWhiteboard")
            color: enableWhiteboard.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: enableWhiteboard.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        onClicked: {
            if(isWhiteboardEnable) {
                whiteboardManager.disableWhiteboardDraw(accountId)
            }else{
                whiteboardManager.enableWhiteboardDraw(accountId)
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
        visible: (whiteboardManager.whiteboardSharing == true)
                 && (membersManager.hostAccountId === authManager.authAccountId)
                 && (whiteboardManager.whiteboardSharerAccountId === accountId)
                 && (accountId !== membersManager.hostAccountId)
        Label {
            id: closeWhiteboardShareItem
            text: qsTr("closeWhiteboardShare")
            color: closeWhiteboardShare.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: closeWhiteboardShare.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        onClicked: {
            DialogManager.dynamicDialog(qsTr("close whiteboard"), qsTr("The current user is performing the whiteboard function and is sure to close its sharing ?"), function () {
                whiteboardManager.closeWhiteboard(accountId)
            }, function () {}, Window.window)
        }
        Accessible.role: Accessible.Button
        Accessible.name: closeWhiteboardShareItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    MenuItem {
        id: closeScreenShare
        width: parent.width
        height: visible ? 32 : 0
        visible:  (membersManager.hostAccountId === authManager.authAccountId)
                  && (shareManager.shareAccountId === accountId)
                  && (accountId !== membersManager.hostAccountId)
        Label {
            id: closeScreenShareItem
            text: qsTr("closeScreenShare")
            color: closeScreenShare.hovered ? "#337EFF" : "#333333"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: closeScreenShare.hovered ? "#F2F3F5" : "#FFFFFF"
        }
        onClicked: {
            DialogManager.dynamicDialog(qsTr("close ScreenShare"), qsTr("The current user is performing the Screen sharing function and is sure to close its sharing ?"), function () {
                shareManager.stopScreenSharing(accountId)
            }, function () {}, Window.window)
        }
        Accessible.role: Accessible.Button
        Accessible.name: closeScreenShareItem.text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }
}
