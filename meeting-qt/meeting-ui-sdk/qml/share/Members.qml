import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "../components"

Window {
    id: membersWindow
    width: 800
    height: 500
    flags: Qt.Window | Qt.FramelessWindowHint
    color: 'transparent'

    Material.theme: Material.Light

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        color: "#3217171A"
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    ToastManager {
        id: toast
    }

    MuteConfirmDialog {
        id:muteConfirmDialog;
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        border.width: 1
        border.color: '#FFFFFF'
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            DragArea {
                id: idDragArea
                title: qsTr('Members')
                Layout.preferredHeight: 54
                Layout.fillWidth: true
                onCloseClicked: Window.window.hide()
            }
            Sidebar {
                radius: 10
                showTitle: false
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    Connections {
        target: meetingManager
        onMuteStatusNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId) {
                if (meetingManager.meetingMuted)
                    toast.show(qsTr('You have turned on all mute'))
                else
                    toast.show(qsTr('You have turned off all mute'))
            } else {
                if (meetingManager.meetingMuted && audioManager.localAudioStatus !== 3 && audioManager.localAudioStatus !== 2)
                    toast.show(qsTr('This meeting has been turned on all mute by host'))
            }
        }
        onLockStatusNotify: {
            if (authManager.authAccountId === membersManager.hostAccountId) {
                if (meetingManager.meetingLocked)
                toast.show(qsTr('You have been locked this meeting'))
                else
                toast.show(qsTr('You have been unlocked this meeting'))
            }
        }
    }
}
