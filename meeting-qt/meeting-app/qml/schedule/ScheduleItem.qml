import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.14

import '../components'

Rectangle {
    id: rootItem

    property int uniqueMeetingId
    property int meetingStatus
    property string meetingId
    property string meetingPassword
    property string meetingTopic
    property var startTime
    property var endTime
    property bool showDatetime: false
    property bool liveAccess: false
    property bool enableLive: false
    property bool recordEnable: false
    property string liveUrl: ""

    ColumnLayout {
        RowLayout {
            Layout.leftMargin: 14
            Layout.preferredHeight: 43
            Layout.alignment: Qt.AlignVCenter
            visible: showDatetime
            Label {
                id: day
                text: new Date(startTime).getDate()
                font.pixelSize: 36
                Layout.alignment: Qt.AlignBottom
                Layout.leftMargin: -8
            }
            Label {
                id: month
                text: qsTr('%1').arg(new Date(startTime).getMonth() + 1)
                font.pixelSize: 14
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 6
            }
            Label {
                id: translateDay
                font.pixelSize: 14
                text: {
                    const todayBegin = new Date().setHours(0, 0, 0, 0)
                    const todayEnd = new Date().setHours(23, 59, 59, 999)
                    const compareDate = new Date(startTime).setHours(0, 0, 0, 0)
                    const tomorrow = new Date(new Date().setDate(new Date().getDate() + 1)).setHours(23, 59, 59, 999)
                    // console.log(todayBegin, todayEnd, compareDate, startTime, tomorrow)
                    if (compareDate < todayBegin) {
                        return qsTr('Yesterday')
                    } else if (compareDate >= todayBegin && compareDate <= todayEnd) {
                        return qsTr('Today')
                    } else if (compareDate > todayEnd && compareDate <= tomorrow) {
                        return qsTr('Tomorrow')
                    } else {
                        const day = new Date(compareDate).getDay()
                        switch (day) {
                        case 0:
                            return qsTr('Sunday')
                        case 1:
                            return qsTr('Monday')
                        case 2:
                            return qsTr('Tuesday')
                        case 3:
                            return qsTr('Wednesday')
                        case 4:
                            return qsTr('Thurday')
                        case 5:
                            return qsTr('Friday')
                        case 6:
                            return qsTr('Saturday')
                        }
                    }
                }
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 6
            }
        }

        RowLayout {
            spacing: 23
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 72
            Image {
                Layout.leftMargin: 10
                Layout.preferredHeight: 21
                Layout.preferredWidth: 21
                Layout.alignment: Qt.AlignVCenter
                source: 'qrc:/qml/images/front/icon_schedule_meeting.svg'
            }
            RowLayout {
                spacing: 22
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 220
                    RowLayout {
                        spacing: 10
                        Label {
                            id: itemTime
                            font.pixelSize: 12
                            color: '#222222'
                            text: {
                                const hours = new Date(startTime).getHours()
                                const minutes = new Date(startTime).getMinutes()
                                return (hours >= 10 ? hours : '0' + hours) + ':' + (minutes >= 10 ? minutes : '0' + minutes)
                            }
                        }
                        Rectangle { height: 14; width: 1; color: '#999999' }
                        RowLayout {
                            Label {
                                id: itemMeetingId
                                text: qsTr('Meeting ID: %1').arg(prettyConferenceId(meetingId))
                                font.pixelSize: 12
                                color: '#999999'
                            }
                            Label {
                                text: {
                                    switch (meetingStatus) {
                                    case 1:
                                        return qsTr('Prepare')
                                    case 2:
                                        return qsTr('Started')
                                    case 3:
                                        return qsTr('Finished')
                                    }
                                }

                                font.pixelSize: 12
                                color: meetingStatus == 2 ? '#337EFF' : '#999999'
                            }
                        }
                    }
                    Label {
                        id: itemTopic
                        text: meetingTopic
                        font.pixelSize: 16
                        color: '#222222'
                        clip: true
                        elide: Text.ElideRight
                        Layout.preferredWidth: 230
                    }
                }

                Timer{
                    id:btnJoinTimer
                    running: false
                    repeat: false
                    interval: 3000
                    onTriggered: {
                        btnJoin.enabled = true
                        btnMore.enabled = true
                    }
                }

                RowLayout {
                    Layout.rightMargin: 10
                    CustomButton {
                        id: btnJoin
                        text: qsTr('Join')
                        normalTextColor: down ? '#FFFFFF' : '#337EFF'
                        buttonRadius: 18
                        font.pixelSize: 12
                        pushedBkColor: '#337EEE'
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 22
                        onClicked: {
                            btnJoin.enabled = false
                            btnMore.enabled = false
                            let micStatus = false
                            let cameraStatus = false
                            if (Qt.platform.os === 'windows') {
                                micStatus = globalSettings.value('localMicStatusEx') === 'true'
                                cameraStatus = globalSettings.value('localCameraStatusEx') === 'true'
                            } else {
                                micStatus = globalSettings.value('localMicStatusEx')
                                cameraStatus = globalSettings.value('localCameraStatusEx')
                            }
                            meetingManager.invokeJoin(meetingId, authManager.appUserNick, micStatus, cameraStatus)
                            btnJoinTimer.restart()
                        }
                    }
                    CustomButton {
                        id: btnMore
                        text: qsTr('···')
                        normalTextColor: down ? '#FFFFFF' : '#337EFF'
                        buttonRadius: 18
                        font.pixelSize: 12
                        pushedBkColor: '#337EEE'
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        onClicked: {
                            if (idScheduleDetailsWindow.visible) {
                                idScheduleDetailsWindow.setVisible(false)
                            }
                            idScheduleDetailsWindow.uniqueMeetingId = uniqueMeetingId
                            idScheduleDetailsWindow.meetingStatus = meetingStatus
                            idScheduleDetailsWindow.meetingId = meetingId
                            idScheduleDetailsWindow.meetingTopic = meetingTopic
                            idScheduleDetailsWindow.meetingPassword = meetingPassword
                            idScheduleDetailsWindow.startTime = startTime
                            idScheduleDetailsWindow.endTime = endTime
                            idScheduleDetailsWindow.attendeeAudioOff = attendeeAudioOff
                            idScheduleDetailsWindow.liveEanble = enableLive
                            idScheduleDetailsWindow.liveUrl = liveUrl
                            idScheduleDetailsWindow.liveAccess = liveAccess
                            idScheduleDetailsWindow.recordEnable = recordEnable
                            const screenTmp = mainWindow.screen
                            idScheduleDetailsWindow.screen = screenTmp
                            idScheduleDetailsWindow.showNormal()
                            idScheduleDetailsWindow.x = (screenTmp.width - idScheduleDetailsWindow.width) / 2 + screenTmp.virtualX
                            idScheduleDetailsWindow.y = (screenTmp.height - idScheduleDetailsWindow.height) / 2 + screenTmp.virtualY
                        }
                    }
                }
            }
        }
    }

    Connections{
        target: idScheduleDetailsWindow
        onJoinMeeting: {
            if(idScheduleDetailsWindow.meetingId === rootItem.meetingId) {
                btnJoin.enabled = false
                btnMore.enabled = false
                btnJoinTimer.restart()
            }
        }
    }
}
