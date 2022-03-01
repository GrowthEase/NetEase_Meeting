import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12
import NetEase.Meeting.GlobalToast 1.0
import NetEase.Meeting.MeetingStatus 1.0
import Clipboard 1.0

import "../components"
import "../utils/meetingHelpers.js" as MeetingHelpers

Window {
    id: rootWindow

    width: 410 + 20
    height: 312 + 20
    x: (Screen.width - width) / 2 + Screen.virtualX
    y: (Screen.height - height) / 2 + Screen.virtualY
    color: "#00000000"
    title: qsTr("Invitation")
    flags: Qt.Window | Qt.FramelessWindowHint

    property string meetingtopic: ""
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

    Clipboard {
        id: clipboard
    }

    ToastManager {
        id: toast
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        border.width: 1
        border.color: "#FFFFFF"
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            DragArea {
                Layout.preferredHeight: 52
                Layout.fillWidth: true
                title: qsTr("Invite Member")
                onCloseClicked: Window.window.hide()
            }

            ColumnLayout {
                spacing: 0
                Layout.topMargin: 10
                Layout.leftMargin: 40
                Layout.rightMargin: 40
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                TextArea {
                    id: meetingInfo
                    background: null
                    selectByMouse: true
                    selectByKeyboard: true
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                    persistentSelection: true
                    readOnly: true
                    verticalAlignment: TextArea.AlignVCenter
                    text: {
                        let inviteInfo = ''
                        inviteInfo += qsTr("Inviting you to join the meeting:")
                        inviteInfo += '\r\n\r\n'
                        if(meetingtopic === ''){
                            inviteInfo += qsTr("Topic:") + meetingManager.meetingTopic
                        }
                        else{
                            inviteInfo += qsTr("Topic:") + meetingtopic
                        }


                        if (getMeetingTime() !== '') {
                            inviteInfo += '\r\n'
                            inviteInfo += qsTr("Meeting time:") + getMeetingTime()
                        }

                        inviteInfo += '\r\n'

                        if (meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_LONG_ID_ONLY ||
                            meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_ALL ||
                            (meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_SHORT_ID_ONLY && meetingManager.shortMeetingId === '')) {
                            inviteInfo += '\r\n'
                            inviteInfo += qsTr("Meeting ID: ")
                            inviteInfo += MeetingHelpers.prettyConferenceId()
                        }

                        if ((meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_SHORT_ID_ONLY ||
                            meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_ALL) &&
                            meetingManager.shortMeetingId !== ''){
                            inviteInfo += '\r\n'
                            if (meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_SHORT_ID_ONLY) {
                                inviteInfo += qsTr("Meeting ID: ")
                            } else {
                                inviteInfo += qsTr("Short ID: ")
                            }
                            inviteInfo += meetingManager.shortMeetingId
                            if (meetingManager.meetingIdDisplayOption !== MeetingStatus.DISPLAY_SHORT_ID_ONLY) {
                                inviteInfo += qsTr(" (Only inner)")
                            }
                        }

                        if (meetingManager.meetingSIPChannelId !== '') {
                            inviteInfo += '\r\n'
                            inviteInfo += qsTr('SIP Channel ID:') + meetingManager.meetingSIPChannelId
                        }

                        if (meetingManager.meetingPassword !== '') {
                            inviteInfo += '\r\n'
                            inviteInfo += qsTr("Meeting password:") + meetingManager.meetingPassword
                        }

                        return inviteInfo
                    }
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: {
                            if (mouse.button === Qt.RightButton)
                                contextMenu.popup()
                        }
                        onPressAndHold: {
                            if (mouse.source === Qt.MouseEventNotSynthesized)
                                contextMenu.popup()
                        }
                    }
                    Menu {
                        id: contextMenu
                        width: 110
                        MenuItem {
                            text: qsTr('Copy')
                            height: 32
                            width: parent.width
                            onClicked: clipboard.setText(meetingInfo.selectedText)
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: "#F6F7F8"
                opacity: 1.0
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: 60-2
                radius: 10
                CustomButton {
                    id: btnCopy
                    highlighted: true
                    text: qsTr("Copy Link")
                    anchors.centerIn: parent
                    anchors.topMargin: 11
                    width:120
                    height: 36
                    onClicked: {
                        /*
                        let copytext = ""
                        copytext += tip.text + "\n"
                        copytext += meetingSubject.text + "\n"
                        if (meetingTime.visible)
                            copytext += meetingTime.text + "\n"
                        copytext += meetingId.text + "\n"
                        if (meetingPassword.visible)
                            copytext += meetingPassword.text
                        */
                        clipboard.setText(meetingInfo.text)
                        GlobalToast.displayText(qsTr('Meeting invarion has been copied'), rootWindow.screen)
                        rootWindow.hide()
                    }
                }
            }
        }
    }

    Timer {
        id: copyTimer
        repeat: false
        interval: 2000
        onTriggered: {
            btnCopy.enabled = true
            btnCopy.text = qsTr('Copy Link')
        }
    }

    Connections {
        target: rootWindow
        onClosing: {
            rootWindow.hide()
            close.accepted = false
            meetingtopic = ""
        }
    }

    Connections{
        target: meetingManager
        onMeetingStatusChanged: {
             switch (status) {
             case MeetingStatus.MEETING_DISCONNECTED:
             case MeetingStatus.MEETING_KICKOUT_BY_HOST:
             case MeetingStatus.MEETING_MULTI_SPOT_LOGIN:
             case MeetingStatus.MEETING_ENDED:
                 meetingtopic = ""
                 break
             default:
                 break
             }
        }
    }

    function getMeetingTime() {
        if (meetingManager.meetingSchdeuleStarttime === 0 || meetingManager.meetingSchdeuleEndtime === 0) {
            return ""
        }
        const myArray = new Array
        const start = new Date(meetingManager.meetingSchdeuleStarttime)
        const end = new Date(meetingManager.meetingSchdeuleEndtime)

        let startTime = ''
        startTime += start.getFullYear() + '/'
        startTime += (start.getMonth() + 1).toString().padStart(2,'0') + '/'
        startTime += start.getDate() + ' '
        startTime += start.getHours().toString().padStart(2, '0') + ':'
        startTime += start.getMinutes().toString().padStart(2, '0')


        let endTime = ''
        endTime += end.getFullYear() + '/'
        endTime += (end.getMonth() + 1).toString().padStart(2,'0') + '/'
        endTime += end.getDate() + ' '
        endTime += end.getHours().toString().padStart(2, '0') + ':'
        endTime += end.getMinutes().toString().padStart(2, '0')

        return startTime + ' - ' + endTime
    }
}
