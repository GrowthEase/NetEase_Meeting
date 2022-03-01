import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import NetEase.Meeting.RunningStatus 1.0
import NetEase.Meeting.MeetingStatus 1.0

Rectangle {
    Component.onCompleted: {
        meetingManager.isInitializd()
        checkAudio.checked = meetingManager.checkAudio()
        checkVideo.checked = meetingManager.checkVideo()
        mainWindow.width = 1088
        mainWindow.height = 680
        Qt.callLater(function() {
            meetingManager.getIsSupportRecord()
            liveTimer.start()
        })
    }

    Timer {
        id: liveTimer
        repeat: false
        running: false
        interval: 500
        onTriggered: {
             meetingManager.getIsSupportLive()
        }
    }

    ToolButton {
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        text: qsTr("⋮")
        onClicked: meetingManager.showSettings()
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 30
        ColumnLayout {
            Layout.preferredWidth: 500
            Layout.preferredHeight: 500
            Label {
                text: qsTr('Schedule Meeting')
                font.pixelSize: 24
                Layout.alignment: Qt.AlignHCenter
            }
            TextField {
                id: meetingTopic
                Layout.fillWidth: true
                placeholderText: qsTr('Meeting Topic')
            }
            TextField {
                id: meetingPassword
                Layout.fillWidth: true
                placeholderText: qsTr('Password')
            }
            RowLayout {
                TextField {
                    id: startTimestamp
                    Layout.fillWidth: true
                    placeholderText: qsTr('Start Timestamp')
                }
                Label {
                    text: qsTr('~')
                }
                TextField {
                    id: endTimestamp
                    Layout.fillWidth: true
                    placeholderText: qsTr('End Timestamp')
                }
            }
            CheckBox {
                id: muteCheckbox
                text: qsTr('Automatically mute after members join')
            }
            CheckBox {
                id: idLiveSettingCheck
                visible: meetingManager.isSupportLive
                text: qsTr("is open live")
            }
            CheckBox {
                id: idLiveAccessCheck
                text: qsTr("Only employees of company can watch")
                visible: idLiveSettingCheck.checked
            }

            Button {
                id: btnSchedule
                highlighted: true
                Layout.fillWidth: true
                text: qsTr('Schedule')
                onClicked: {
                    meetingManager.scheduleMeeting(meetingTopic.text,
                                                   startTimestamp.text,
                                                   endTimestamp.text,
                                                   meetingPassword.text,
                                                   muteCheckbox.checked,
                                                   idLiveSettingCheck.checked,
                                                   idLiveAccessCheck.checked,
                                                   idOpenRecord.checked)
                }
            }
            ListView {
                Component.onCompleted: {
                    Qt.callLater(function() { meetingManager.getMeetingList() })
                }
                Layout.preferredHeight: 280
                Layout.fillWidth: true
                spacing: 10
                clip: true
                model: ListModel {
                    id: listModel
                }
                delegate: ItemDelegate {
                    height: 280
                    width: parent.width
                    ColumnLayout {
                        width: parent.width
                        spacing: 0
                        RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: qsTr('Timestamp')
                            }
                            TextField {
                                id: startTimestamp2
                                Layout.fillWidth: true
                                text: model.startTime.toString()
                            }
                            Label {
                                text: qsTr('~')
                            }
                            TextField {
                                id: endTimestamp2
                                Layout.fillWidth: true
                                text: model.endTime.toString()
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: prettyConferenceId(model.meetingId)
                            }
                            Label {
                                text: qsTr('Password')
                            }
                            TextField {
                                id: password2
                                text: model.password
                            }

                        }

                        RowLayout {
                            Layout.fillWidth: true
                            CheckBox {
                                id: muteCheckbox2
                                text: qsTr('Automatically mute after members join')
                                checked: model.attendeeAudioOff
                            }
                        }

                        RowLayout {
                          //  Layout.fillWidth: true
                            CheckBox {
                                id: idLiveSettingCheckEdit
                                visible: meetingManager.isSupportLive
                                text: qsTr("is open live")
                                checked: model.enableLive
                            }
                            CheckBox {
                                id: idLiveAccessCheckEdit
                                text: qsTr("idLiveAccessCheckEdit")
                                checked: model.liveAccess
                            }
                            CheckBox {
                                id: idOpenRecordEdit
                                text: qsTr("is open record")
                                visible: meetingManager.isSupportRecord
                                checked: model.recordEnable
                            }
                        }

                        RowLayout {
                            TextField {
                                id: topic2
                                text: model.topic
                            }
                            Label {
                                text: {
                                    switch (model.status) {
                                    case 1:
                                        return qsTr('Prepare')
                                    case 2:
                                        return qsTr('Started')
                                    case 3:
                                        return qsTr('Finished')
                                    }
                                }

                                font.pixelSize: 12
                                color: model.status === 2 ? '#337EFF' : '#999999'
                            }
                        }
                        RowLayout {
                            Layout.preferredWidth: 40
                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                text: qsTr('Join')
                                onClicked: {
                                    meetingManager.invokeJoin(model.meetingId, textNickname.text,
                                                              checkAudio.checked, checkVideo.checked,
                                                              checkChatroom.checked, checkInvitation.checked, autoOpenWhiteboard.checked, autorename.checked)
                                }
                            }
                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                text: qsTr('Cancel')
                                onClicked: {
                                    meetingManager.cancelMeeting(model.uniqueMeetingId)
                                }
                            }
                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                text: qsTr('Edit')
                                onClicked: {
                                    meetingManager.editMeeting(model.uniqueMeetingId,
                                                               model.meetingId,
                                                               topic2.text,
                                                               startTimestamp2.text,
                                                               endTimestamp2.text,
                                                               password2.text,
                                                               muteCheckbox2.checked,
                                                               idLiveSettingCheckEdit.checked,
                                                               idLiveAccessCheckEdit.checked,
                                                               idOpenRecordEdit.checked)
                                }
                            }
                        }
                    }
                }
                ScrollBar.vertical: ScrollBar {
                    width: 7
                }
            }
        }
        ColumnLayout {
            TextField {
                id: textMeetingId
                enabled: !checkBox.checked
                text: checkBox.checked ? meetingManager.personalMeetingId : ''
                placeholderText: qsTr('Meeting ID')
                selectByMouse: true
                Layout.fillWidth: true
            }

            TextField {
                id: textNickname
                text: qsTr('nickname')
                placeholderText: qsTr('Your nickname')
                selectByMouse: true
                Layout.fillWidth: true
            }

            TextField {
                id: textpassword
                placeholderText: qsTr('meeting password')
                selectByMouse: true
                Layout.fillWidth: true
            }

            ComboBox {
                id: displayOption
                Layout.fillWidth: true
                model: ListModel {
                    id: displayModel
                }
                delegate: ItemDelegate {
                    width: parent.width
                    text: model.name
                    onClicked: {
                        displayOption.currentIndex = model.index
                    }
                }
                Component.onCompleted: {
                    displayModel.append({ name: 'Display Short Only' })
                    displayModel.append({ name: 'Display Long Only' })
                    displayModel.append({ name: 'Display All' })
                    displayOption.currentIndex = 0
                }
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: checkAudio
                    checked: true
                    text: qsTr('Enable audio')
                    onClicked: meetingManager.setCheckAudio(checkAudio.checked)
                }

                CheckBox {
                    id: checkVideo
                    checked: true
                    text: qsTr('Enable video')
                    onClicked: meetingManager.setCheckVideo(checkVideo.checked)
                }

                CheckBox {
                    id: autoOpenWhiteboard
                    checked: false
                    text: qsTr('autoOpenWhiteboard')
                }

                CheckBox {
                    id: autorename
                    checked: true
                    text: qsTr('rename')
                }
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: checkChatroom
                    checked: true
                    text: qsTr('Enable chatroom')
                }

                CheckBox {
                    id: checkInvitation
                    checked: true
                    text: qsTr('Enable invitation')
                }

                CheckBox {
                    id: idOpenRecord
                    text: qsTr("is Open record")
                    visible: meetingManager.isSupportRecord
                }
            }

            CheckBox {
                id: checkBox
                text: qsTr('Personal meeting ID: %1').arg(meetingManager.personalMeetingId)
                Layout.alignment: Qt.AlignHCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                id: subscribeAudio
                enabled: false
                TextField {
                    id: accoundList
                    placeholderText: single.checked ? qsTr('accoundId') : (multiple.checked ? qsTr('accoundId,accoundId,accoundId....') : '')
                    selectByMouse: true
                    enabled: !all.checked
                    Layout.fillWidth: true
                }
                RowLayout {
                    RadioButton {
                        id: single
                        text: qsTr('Single')
                    }
                    RadioButton {
                        id: multiple
                        text: qsTr('multiple')
                        checked: true
                    }
                    RadioButton {
                        id: all
                        text: qsTr('all')
                        onCheckedChanged: {
                            if (checked) {
                                accoundList.text = '';
                            }
                        }
                    }
                }
                RowLayout {
                    Button {
                        id: btnSubscribe
                        highlighted: true
                        text: qsTr('Subscribe Audio')
                        Layout.fillWidth: true
                        onClicked: {
                            meetingManager.subcribeAudio(accoundList.text, true, single.checked ? 0 : (multiple.checked ? 1 : 2))
                        }
                    }
                    Button {
                        id: btnUnSubscribe
                        highlighted: true
                        text: qsTr('UnSubscribe Audio')
                        Layout.fillWidth: true
                        onClicked: {
                            meetingManager.subcribeAudio(accoundList.text, false, single.checked ? 0 : (multiple.checked ? 1 : 2))
                        }
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 20
                Layout.alignment: Qt.AlignHCenter
                Button {
                    id: btnCreate
                    highlighted: true
                    text: qsTr('Create')
                    Layout.fillWidth: true
                    onClicked: {
                        meetingManager.invokeStart(checkBox.checked ? meetingManager.personalMeetingId : '', textNickname.text,
                                                   checkAudio.checked, checkVideo.checked,
                                                   checkChatroom.checked, checkInvitation.checked, autoOpenWhiteboard.checked, autorename.checked, displayOption.currentIndex,
                                                   idOpenRecord.checked)
                    }
                }
                Button {
                    id: btnJoin
                    highlighted: true
                    text: qsTr('Join')
                    Layout.fillWidth: true
                    onClicked: {
                        meetingManager.invokeJoin(textMeetingId.text, textNickname.text,
                                                  checkAudio.checked, checkVideo.checked,
                                                  checkChatroom.checked, checkInvitation.checked, autoOpenWhiteboard.checked, textpassword.text, autorename.checked, displayOption.currentIndex)
                    }
                }
                Button {
                    id: btnLeave
                    highlighted: true
                    text: qsTr('Leave')
                    Layout.fillWidth: true
                    enabled: false
                    onClicked: meetingManager.leaveMeeting(true)
                }
                Button {
                    id: btnGet
                    highlighted: true
                    enabled: false
                    Layout.fillWidth: true
                    text: qsTr('Get Info')
                    onClicked: meetingManager.getMeetingInfo()
                }
                Button {
                    id: getStatus
                    highlighted: true
                    Layout.fillWidth: true
                    text: qsTr('Get Status')
                    onClicked: {
                        toast.show('Current meeting status: ' + meetingManager.getMeetingStatus())
                    }
                }
                Button {
                    id: getHistoryMeeting
                    highlighted: true
                    Layout.fillWidth: true
                    text: qsTr('Get History Info')
                    onClicked: meetingManager.getHistoryMeetingItem()
                }
            }
        }
    }

    Dialog {
        id: meetinginfo
        standardButtons: StandardButton.Save | StandardButton.Cancel

        property int meetingUniqueId: 0
        property string meetingId: ""
        property string shortMeetingId: ""
        property string subject: ""
        property string password: ""
        property bool isHost: false
        property bool isLocked: false
        property string scheduleStartTime: ""
        property string scheduleEndTime: ""
        property string startTime: ""
        property string sipId: ""
        property int duration: 0
        property string hostUserId: ""

        contentItem: Rectangle {
            implicitHeight: 600
            implicitWidth: 500

            ColumnLayout {
                id: col
                anchors.left: parent.left
                anchors.top: parent.top
                implicitHeight: 300
                spacing: 0

                Button {
                    text: qsTr('exit')
                    onClicked: meetinginfo.close()
                }

                Label {
                    text: "meetingUniqueId: " + meetinginfo.meetingUniqueId
                }

                Label {
                    text: "meetingId: " + meetinginfo.meetingId
                }

                Label {
                    text: "shortMeetingId: " + meetinginfo.shortMeetingId
                }

                Label {
                    text: "subject: " + meetinginfo.subject
                }

                Label {
                    text: "password: " + meetinginfo.password
                }

                Label {
                    text: "isHost: " + meetinginfo.isHost
                }

                Label {
                    text: "isLocked: " + meetinginfo.isLocked
                }

                Label {
                    text: "scheduleStartTime: " + meetinginfo.scheduleStartTime
                }

                Label {
                    text: "scheduleEndTime: " + meetinginfo.scheduleEndTime
                }

                Label {
                    text: "startTime: " + meetinginfo.startTime
                }

                Label {
                    text: "sipId: " + meetinginfo.sipId
                }

                Label {
                    text: "duration: " + meetinginfo.duration
                }

                Label {
                    text: "hostUserId: " + meetinginfo.hostUserId
                }

                Label {
                    text: "user list: "
                }

            }

            ListView {
                anchors.top: col.bottom
                anchors.left: col.left
                width: parent.width
                height: 300
                model: ListModel {
                    id: listUserModel
                }
                delegate: Rectangle {
                    height: 20
                    RowLayout{
                        Label {
                            text: "userId: " + model.userId
                        }

                        Label {
                            text: "userName: " + model.userName
                        }

                    }
                }

            }
        }
    }

    Connections {
        target: meetingManager
        onStartSignal: {
            switch (errorCode) {
            case MeetingStatus.ERROR_CODE_SUCCESS:
                toast.show(qsTr('Create successfull'))
                btnLeave.enabled = true
                btnGet.enabled = true
                btnCreate.enabled = false
                btnJoin.enabled = false
                subscribeAudio.enabled = true
                break
            case MeetingStatus.MEETING_ERROR_FAILED_MEETING_ALREADY_EXIST:
                toast.show(qsTr('Meeting already started'))
                break
            case MeetingStatus.ERROR_CODE_FAILED:
                toast.show(qsTr('Failed to start meeting'))
                break
            default:
                toast.show(errorCode + '(' + errorMessage + ')')
                break
            }
        }
        onJoinSignal: {
            switch (errorCode) {
            case MeetingStatus.ERROR_CODE_SUCCESS:
                toast.show(qsTr("Join successfull"))
                btnLeave.enabled = true
                btnGet.enabled = true
                btnCreate.enabled = false
                btnJoin.enabled = false
                subscribeAudio.enabled = true
                break
            case MeetingStatus.MEETING_ERROR_LOCKED_BY_HOST:
                toast.show(qsTr('The meeting is locked'))
                break
            case MeetingStatus.MEETING_ERROR_INVALID_ID:
                toast.show(qsTr('Meeting not exist'))
                break
            case MeetingStatus.MEETING_ERROR_LIMITED:
                toast.show(qsTr('Exceeds the limit'))
                break
            case MeetingStatus.ERROR_CODE_FAILED:
                toast.show(qsTr('Failed to join meeting'))
                break
            default:
                toast.show(errorCode + '(' + errorMessage + ')')
                break
            }
        }
        onLeaveSignal: {
            toast.show('Leave meeting signal: ' + errorCode + ", " + errorMessage)
        }
        onMeetingStatusChanged: {
            switch (meetingStatus) {
            case RunningStatus.MEETING_STATUS_CONNECTING:
                break;
            case RunningStatus.MEETING_STATUS_DISCONNECTING:
                if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SELF)
                    toast.show(qsTr('You have left the meeting'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_NORMAL)
                    toast.show(qsTr('Your have been left this meeting'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_HOST)
                    toast.show(qsTr('This meeting has been ended'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_KICKOUT)
                    toast.show(qsTr('You have been removed from meeting by host'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SERVER)
                    toast.show(qsTr('You have been discconected from server'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_MULTI_SPOT)
                    toast.show(qsTr('You have been kickout by other client'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST)
                    toast.show(qsTr('You have finish this meeting'))
                btnGet.enabled = false
                btnCreate.enabled = true
                btnJoin.enabled = true
                btnLeave.enabled = false
                subscribeAudio.enabled = false
                break
            }
        }
        onMeetingInjectedMenuItemClicked: {
            toast.show('Meeting item clicked, item title: ' + itemTitle)
        }
        onGetCurrentMeetingInfo: {
            meetinginfo.meetingUniqueId = meetingBaseInfo.meetingUniqueId
            meetinginfo.meetingId = meetingBaseInfo.meetingId
            meetinginfo.shortMeetingId = meetingBaseInfo.shortMeetingId
            meetinginfo.subject = meetingBaseInfo.subject
            meetinginfo.password = meetingBaseInfo.password
            meetinginfo.isHost = meetingBaseInfo.isHost
            meetinginfo.isLocked = meetingBaseInfo.isLocked
            meetinginfo.scheduleStartTime = meetingBaseInfo.scheduleStartTime
            meetinginfo.scheduleEndTime = meetingBaseInfo.scheduleEndTime
            meetinginfo.startTime = meetingBaseInfo.startTime
            meetinginfo.sipId = meetingBaseInfo.sipId
            meetinginfo.duration = meetingBaseInfo.duration
            meetinginfo.hostUserId = meetingBaseInfo.hostUserId

            listUserModel.clear()
            for (let i = 0; i < meetingUserList.length; i++) {
                const user = meetingUserList[i]
                listUserModel.append(user)
                console.log("userid", user.userId)
                console.log("userName", user.userName)
            }

            meetinginfo.open()
        }
        onGetHistoryMeetingInfo: {
            toast.show('Get history meeting info, ID: ' + meetingId + ', meetingUniqueId: ' + meetingUniqueId + ', shortMeetingId: ' + shortMeetingId + ', subject: ' + subject + ', password: ' + password + ', nickname: ' + nickname + ', sip: ' + sipId)
        }
        onGetScheduledMeetingList: {
            listModel.clear()
            let datetimeFlag = 0;
            for (let i = 0; i < meetingList.length; i++) {
                const meeting = meetingList[i]
                listModel.append(meeting)
            }
            meetingManager.getAccountInfo()          
        }

        onDeviceStatusChanged :{
            if(type === 1){
                checkAudio.checked = status
                toast.show('audio device status is '+ status);
            }
            else if(type === 2){
                checkVideo.checked = status;
                toast.show('video device status is '+ status);
            }
        }

        onScheduleSignal: {
            switch (errorCode) {
            case 0:
                toast.show(qsTr("Schedule successfull"))
                break
            default:
                toast.show(errorCode + '(' + errorMessage + ')')
                break
            }
        }

        onCancelSignal: {
            switch (errorCode) {
            case 0:
                toast.show(qsTr("Cancel successfull"))
                break
            default:
                toast.show(errorCode + '(' + errorMessage + ')')
                break
            }
        }

        onEditSignal: {
            switch (errorCode) {
            case 0:
                toast.show(qsTr("Edit successfull"))
                break
            default:
                toast.show(errorCode + '(' + errorMessage + ')')
                break
            }
        }

        onError: {
            toast.show(errorCode + '(' + errorMessage + ')')
        }
    }

    function prettyConferenceId(conferenceId) {
        return conferenceId.substring(0, 3) + "-" +
                conferenceId.substring(3, 6) + "-" +
                conferenceId.substring(6)
    }
}
