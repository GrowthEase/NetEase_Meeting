import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import Qt5Compat.GraphicalEffects
import "../components"

Window {
    id: membersWindow
    Material.theme: Material.Light
    color: 'transparent'
    flags: Qt.Window | Qt.FramelessWindowHint
    height: 500
    width: 800

    onVisibleChanged: {
        if (!visible) {
            sidebar.closePopupMenu();
        }
    }

    DropShadow {
        anchors.fill: mainLayout
        color: "#3217171A"
        horizontalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        verticalOffset: 0
        visible: Qt.platform.os === 'windows'

        Behavior on radius  {
            PropertyAnimation {
                duration: 100
            }
        }
    }
    ToastManager {
        id: toast
    }
    MuteConfirmDialog {
        id: muteConfirmDialog
    }
    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        border.color: '#FFFFFF'
        border.width: 1
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            DragArea {
                id: idDragArea
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                title: qsTr('Members')

                onCloseClicked: Window.window.hide()
            }
            Sidebar {
                id: sidebar
                Layout.fillHeight: true
                Layout.fillWidth: true
                radius: 10
                showTitle: false
            }
        }
    }
    Connections {
        target: meetingManager

        onLockStatusNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) {
                if (meetingManager.meetingLocked)
                    toast.show(qsTr('You have been locked this meeting'));
                else
                    toast.show(qsTr('You have been unlocked this meeting'));
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
    }
    Connections {
        target: membersManager

        onManagerUpdateSuccess: {
            if (set) {
                toast.show(nickname + qsTr('has been set as manager'));
            } else {
                toast.show(nickname + qsTr('has been unset as manager'));
            }
        }
    }
}
