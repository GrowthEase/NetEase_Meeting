import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import NetEase.Meeting.RunningStatus 1.0
import NetEase.Meeting.MeetingStatus 1.0

Rectangle {
    id: root
    anchors.centerIn: parent
    Component.onCompleted: {
        meetingManager.isInitializd()
        checkAudio.checked = meetingManager.checkAudio()
        checkVideo.checked = meetingManager.checkVideo()
        let w = mainWindow.width;
        let h = mainWindow.height;
        mainWindow.width = 1300
        mainWindow.height = 800
        mainWindow.x -= (mainWindow.width - w) / 2
        mainWindow.y -= (mainWindow.height - h) / 2
        mainWindow.showMaximized()
        Qt.callLater(function () {
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

    RowLayout {
        //anchors.centerIn: parent
        anchors.fill: parent
        spacing: 10
        ColumnLayout {
            Layout.preferredWidth: 300
            Layout.preferredHeight: 500
            spacing: 0
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
            RowLayout {
                TextField {
                    id: meetingPassword
                    Layout.fillWidth: true
                    placeholderText: qsTr('Password')
                }

                TextField {
                    id: preExtraData
                    placeholderText: qsTr('preExtraData')
                    selectByMouse: true
                    Layout.fillWidth: true
                }
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
            RowLayout {
                CheckBox {
                    id: idLiveSettingCheck
                    visible: meetingManager.isSupportLive
                    text: qsTr("is open live")
                }

                CheckBox {
                    id: idRecord
                    visible: meetingManager.isSupportRecord
                    text: qsTr("is open record")
                }
                CheckBox {
                    id: idSip
                    checked: false
                    text: qsTr('Enable sip')
                }
            }
            CheckBox {
                id: idLiveAccessCheck
                text: qsTr("Only employees of company can watch")
                visible: idLiveSettingCheck.checked
            }

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: idPreAudioCcontrol
                    text: qsTr("use audio control")
                    Layout.alignment: Qt.AlignHCenter
                }

                CheckBox {
                    id: idPreAudioAttendeeOff
                    text: qsTr('audioAttendeeOff')
                    Layout.alignment: Qt.AlignHCenter
                    visible: idPreAudioCcontrol.checked
                }

                CheckBox {
                    id: idPreAudioAllowSelfOn
                    text: qsTr('audioAllowSelfOn')
                    Layout.alignment: Qt.AlignHCenter
                    visible: idPreAudioCcontrol.checked
                }
            }

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: idPreVideoCcontrol
                    text: qsTr("use video control")
                    Layout.alignment: Qt.AlignHCenter
                }

                CheckBox {
                    id: idPreVideoAttendeeOff
                    text: qsTr('videoAttendeeOff')
                    Layout.alignment: Qt.AlignHCenter
                    visible: idPreVideoCcontrol.checked
                }

                CheckBox {
                    id: idPreVideoAllowSelfOn
                    text: qsTr('videoAllowSelfOn')
                    Layout.alignment: Qt.AlignHCenter
                    visible: idPreVideoCcontrol.checked
                }
            }

            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: preRoleBinds
                    placeholderText: "roleBinds"
                    selectByMouse: true
                    enabled: true
                    Layout.fillWidth: true
                }
            }

            Button {
                id: btnSchedule
                highlighted: true
                Layout.preferredWidth: 100
                //Layout.fillWidth: true
                text: qsTr('Schedule')
                onClicked: {
                    var controls = []
                    if(idPreAudioCcontrol.checked) {
                        var audiocontrol = {}
                        audiocontrol["attendeeOff"] = idPreAudioAttendeeOff.checked
                        audiocontrol["allowSelfOn"] = idPreAudioAllowSelfOn.checked
                        audiocontrol["type"] = 0
                        controls.push(audiocontrol)
                    }
                    if(idPreVideoCcontrol.checked) {
                        var videocontrol = {}
                        videocontrol["attendeeOff"] = idPreVideoAttendeeOff.checked
                        videocontrol["allowSelfOn"] = idPreVideoAllowSelfOn.checked
                        videocontrol["type"] = 1
                        controls.push(videocontrol)
                    }

                    meetingManager.scheduleMeeting(meetingTopic.text,
                                                   startTimestamp.text,
                                                   endTimestamp.text,
                                                   meetingPassword.text,
                                                   textScene.text,
                                                   muteCheckbox.checked,
                                                   idLiveSettingCheck.checked,
                                                   idSip.checked,
                                                   idLiveAccessCheck.checked,
                                                   idRecord.checked,
                                                   preExtraData.text,
                                                   controls,
                                                   preRoleBinds.text)
                }
            }
            ListView {
                Component.onCompleted: {
                    Qt.callLater(function () {
                        meetingManager.getMeetingList()
                    })
                }
                Layout.preferredHeight: 400
                Layout.fillWidth: true
                spacing: 10
                clip: true
                model: ListModel {
                    id: listModel
                }
                delegate: ItemDelegate {
                    height: 400
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
                            CheckBox {
                                id: idSipEdit
                                text: qsTr('Enable Sip')
                                checked: model.enableSip
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
                            Label {
                                text: "extraData: "
                            }
                            TextField {
                                id: editExtraData
                                text: model.extraData
                            }
                            TextField {
                                id: editRoleBinds
                                placeholderText: "roleBinds"
                                text: model.roleBinds
                                selectByMouse: true
                                enabled: true
                                Layout.fillWidth: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            CheckBox {
                                id: idEditAudioCcontrol
                                text: qsTr("use audio control")
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.audioControl !== undefined
                            }

                            CheckBox {
                                id: idEditAudioAttendeeOff
                                text: qsTr('audioAttendeeOff')
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.audioControl.attendeeOff
                            }

                            CheckBox {
                                id: idEditAudioAllowSelfOn
                                text: qsTr('audioAllowSelfOn')
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.audioControl.allowSelfOn
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            CheckBox {
                                id: idEditVideoCcontrol
                                text: qsTr("use video control")
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.videoControl !== undefined
                            }

                            CheckBox {
                                id: idEditVideoAttendeeOff
                                text: qsTr('videoAttendeeOff')
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.videoControl !== undefined && model.videoControl.attendeeOff
                            }

                            CheckBox {
                                id: idEditVideoAllowSelfOn
                                text: qsTr('videoAllowSelfOn')
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.videoControl !== undefined && model.videoControl.allowSelfOn
                            }
                        }

                        RowLayout {
                            Layout.preferredWidth: 40
                            Button {
                                //Layout.fillWidth: true
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 30
                                text: qsTr('Join')
                                onClicked: {
                                    var meetinginfoObj = {}
                                    meetinginfoObj["anonymous"] = false
                                    meetinginfoObj["meetingId"] = model.meetingId
                                    meetinginfoObj["nickname"] = textNickname.text
                                    meetinginfoObj["tag"] = textTag.text
                                    meetinginfoObj["timeOut"] = textTimeout.text
                                    meetinginfoObj["audio"] = checkAudio.checked
                                    meetinginfoObj["video"] = checkVideo.checked
                                    meetinginfoObj["enableChatroom"] = checkChatroom.checked
                                    meetinginfoObj["enableInvitation"] = checkInvitation.checked
                                    meetinginfoObj["enableScreenShare"] = checkScreenShare.checked
                                    meetinginfoObj["enableView"] = checkView.checked
                                    meetinginfoObj["autoOpenWhiteboard"] = autoOpenWhiteboard.checked
                                    meetinginfoObj["password"] = password2.text
                                    meetinginfoObj["rename"] = autorename.checked
                                    meetinginfoObj["sip"] = idSipEdit.checked

                                    meetingManager.invokeJoin(meetinginfoObj)
                                }
                            }
                            Button {
                                //Layout.fillWidth: true
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 30
                                text: qsTr('Cancel')
                                onClicked: {
                                    meetingManager.cancelMeeting(
                                                model.uniqueMeetingId)
                                }
                            }
                            Button {
                                //Layout.fillWidth: true
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 30
                                text: qsTr('Edit')
                                onClicked: {
                                    var controls = []
                                    if(idEditAudioCcontrol.checked) {
                                        var audiocontrol = {}
                                        audiocontrol["attendeeOff"] = idEditAudioAttendeeOff.checked
                                        audiocontrol["allowSelfOn"] = idEditAudioAllowSelfOn.checked
                                        audiocontrol["type"] = 0
                                        controls.push(audiocontrol)
                                    }
                                    if(idEditVideoCcontrol.checked) {
                                        var videocontrol = {}
                                        videocontrol["attendeeOff"] = idEditVideoAttendeeOff.checked
                                        videocontrol["allowSelfOn"] = idEditVideoAllowSelfOn.checked
                                        videocontrol["type"] = 1
                                        controls.push(videocontrol)
                                    }

                                    meetingManager.editMeeting(
                                                model.uniqueMeetingId,
                                                model.meetingId, topic2.text,
                                                startTimestamp2.text,
                                                endTimestamp2.text,
                                                password2.text, textScene.text,
                                                muteCheckbox2.checked,
                                                idLiveSettingCheckEdit.checked,
                                                idSipEdit.checked,
                                                idLiveAccessCheckEdit.checked,
                                                idOpenRecordEdit.checked,
                                                editExtraData.text,
                                                controls,
                                                editRoleBinds.text)
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
            spacing: 0
            RowLayout {
                TextField {
                    id: textMeetingId
                    enabled: !checkBox.checked
                    text: checkBox.checked ? meetingManager.personalMeetingId : ''
                    placeholderText: qsTr('Meeting ID')
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
                        displayModel.append({
                                                "name": 'Display Short Only'
                                            })
                        displayModel.append({
                                                "name": 'Display Long Only'
                                            })
                        displayModel.append({
                                                "name": 'Display All'
                                            })
                        displayOption.currentIndex = 2
                    }
                }
                ToolButton {
                    id: idgetPMId
                    Layout.topMargin: 10
                    text: qsTr("getPMId")
                    onClicked: { meetingManager.getPersonalMeetingId() }
                }
                ToolButton {
                    id: idSettings
                    Layout.topMargin: 10
                    Layout.rightMargin: 10
                    text: qsTr("settings")
                    onClicked: { idSettings.enabled=false; meetingManager.showSettings() }
                }
            }

            RowLayout {
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

                TextField {
                    id: textTimeout
                    placeholderText: qsTr('enter meeting timeout(ms)')
                    text: 45 * 1000
                    selectByMouse: true
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                TextField {
                    id: textTag
                    placeholderText: qsTr('user tag')
                    selectByMouse: true
                    Layout.fillWidth: true
                }

                TextField {
                    id: extraData
                    placeholderText: qsTr('extraData')
                    selectByMouse: true
                    Layout.fillWidth: true
                }

                TextField {
                    id: textScene
                    placeholderText: qsTr('scene setting')
                    selectByMouse: true
                    Layout.fillWidth: true
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

                CheckBox {
                    id: enableMuteAllVideo
                    checked: false
                    text: qsTr('Enable muteAllVideo')
                }

                CheckBox {
                    id: enableMuteAllAudio
                    checked: true
                    text: qsTr('Enable muteAllAudio')
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
                    id: checkSip
                    checked: false
                    text: qsTr('Enable sip')
                }

                CheckBox {
                    id: idOpenRecord
                    text: qsTr("is Open record")
                    visible: meetingManager.isSupportRecord
                }

                CheckBox {
                    id: idAudioAINS
                    text: qsTr("is AudioAINS")
                    checked: meetingManager.isAudioAINS
                    onClicked: meetingManager.isAudioAINS = checked
                }

                CheckBox {
                    id: checkScreenShare
                    checked: true
                    text: qsTr('Enable ScreenShare')
                }
            }

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: idOpenWhiteboard
                    text: qsTr("Enable whiteboard")
                    visible:true
                }

                CheckBox {
                    id: checkBox
                    text: qsTr('Personal meeting ID: %1').arg(
                              meetingManager.personalMeetingId)
                    Layout.alignment: Qt.AlignHCenter
                }

                CheckBox {
                    id: idShowMemberTag
                    text: qsTr('Show MemberTag')
                }

                CheckBox {
                    id: idShowRemainingTip
                    text: qsTr('Show RemainingTip')
                }

                CheckBox {
                    id: checkView
                    checked: true
                    text: qsTr('Enable View')
                }
            }

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: idEnableFileMessage
                    text: qsTr('Enable FileMessage')
                }

                CheckBox {
                    id: idEnableImageMessage
                    text: qsTr('Enable ImageMessage')
                }

                CheckBox {
                    id: idAudioCcontrol
                    text: qsTr("use audio control")
                    Layout.alignment: Qt.AlignHCenter
                }

                CheckBox {
                    id: idAudioAttendeeOff
                    text: qsTr('audioAttendeeOff')
                    Layout.alignment: Qt.AlignHCenter
                    visible: idAudioCcontrol.checked
                }

                CheckBox {
                    id: idAudioAllowSelfOn
                    text: qsTr('audioAllowSelfOn')
                    Layout.alignment: Qt.AlignHCenter
                    visible: idAudioCcontrol.checked
                }

            }

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: idVideoCcontrol
                    text: qsTr("use video control")
                    Layout.alignment: Qt.AlignHCenter
                }

                CheckBox {
                    id: idVideoAttendeeOff
                    text: qsTr('videoAttendeeOff')
                    Layout.alignment: Qt.AlignHCenter
                    visible: idVideoCcontrol.checked
                }

                CheckBox {
                    id: idVideoAllowSelfOn
                    text: qsTr('videoAllowSelfOn')
                    Layout.alignment: Qt.AlignHCenter
                    visible: idVideoCcontrol.checked
                }
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: idAudioDeviceAutoSelectType
                    text: qsTr('AudioDeviceAutoSelectType Available')
                    checked: meetingManager.audodeviceAutoSelectType
                    onClicked: meetingManager.setAudodeviceAutoSelectType(checked);
                }
                CheckBox {
                    id: idBeauty
                    text: qsTr("Show Beauty")
                    checked: meetingManager.beauty
                    onClicked: meetingManager.beauty = checked
                }
                TextField {
                    id: idBeautyValue
                    placeholderText: qsTr('Beauty Value')
                    selectByMouse: true
                    Layout.preferredWidth: 100
                    maximumLength: 2
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: meetingManager.beautyValue
                    onAccepted: meetingManager.beautyValue = parseInt(idBeautyValue.text)
                }
                CheckBox {
                    id: idVirtualBackground
                    text: qsTr("Show VB")
                    checked: meetingManager.virtualBackground
                    onClicked: meetingManager.virtualBackground = checked
                }
                Button {
                    id: btnDefaultVB
                    highlighted: true
                    text: qsTr('Default VB')
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    onClicked: {
                        meetingManager.getVirtualBackgroundList()
                    }
                }
                TextField {
                    id: vbList
                    placeholderText: qsTr('vb path,vb path,vb path....')
                    selectByMouse: true
                    Layout.fillWidth: true
                }
                Button {
                    id: btnSetVB
                    highlighted: true
                    text: qsTr('Set VB')
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    onClicked: {
                        meetingManager.setVirtualBackgroundList(vbList.text)
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: roleBinds
                    placeholderText: "roleBinds"
                    selectByMouse: true
                    enabled: true
                    Layout.fillWidth: true
                }
            }
            RowLayout {
                id: subscribeAudio
                enabled: false
                TextField {
                    id: accoundList
                    placeholderText: single.checked ? qsTr('accoundId') : (multiple.checked ? qsTr('accoundId,accoundId,accoundId....') : '')
                    selectByMouse: true
                    enabled: !all.checked
                    Layout.fillWidth: true
                }
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
                            accoundList.text = ''
                        }
                    }
                }

                RowLayout {
                    Button {
                        id: btnSubscribe
                        highlighted: true
                        text: qsTr('Subscribe Audio')
                        //Layout.fillWidth: true
                        Layout.preferredWidth: 150
                        onClicked: {
                            meetingManager.subcribeAudio(
                                        accoundList.text, true,
                                        single.checked ? 0 : (multiple.checked ? 1 : 2))
                        }
                    }
                    Button {
                        id: btnUnSubscribe
                        highlighted: true
                        text: qsTr('UnSubscribe Audio')
                        //Layout.fillWidth: true
                        Layout.preferredWidth: 170
                        onClicked: {
                            meetingManager.subcribeAudio(
                                        accoundList.text, false,
                                        single.checked ? 0 : (multiple.checked ? 1 : 2))
                        }
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 0
                Layout.alignment: Qt.AlignLeft
                Button {
                    id: btnCreate
                    highlighted: true
                    text: qsTr('Create')
                    Layout.preferredWidth: 100
                    //Layout.fillWidth: true
                    onClicked: {
                        btnCreate.enabled = false

                        var controls = []
                        if(idAudioCcontrol.checked) {
                            var audiocontrol = {}
                            audiocontrol["attendeeOff"] = idAudioAttendeeOff.checked
                            audiocontrol["allowSelfOn"] = idAudioAllowSelfOn.checked
                            audiocontrol["type"] = 0
                            controls.push(audiocontrol)
                        }
                        if(idVideoCcontrol.checked) {
                            var videocontrol = {}
                            videocontrol["attendeeOff"] = idVideoAttendeeOff.checked
                            videocontrol["allowSelfOn"] = idVideoAllowSelfOn.checked
                            videocontrol["type"] = 1
                            controls.push(videocontrol)
                        }

                        var meetinginfoObj = {}
                        meetinginfoObj["meetingId"] = checkBox.checked ? meetingManager.personalMeetingId : ''
                        meetinginfoObj["nickname"] = textNickname.text
                        meetinginfoObj["tag"] = textTag.text
                        meetinginfoObj["textScene"] = textScene.text
                        meetinginfoObj["timeOut"] = textTimeout.text
                        meetinginfoObj["audio"] = checkAudio.checked
                        meetinginfoObj["video"] = checkVideo.checked
                        meetinginfoObj["enableChatroom"] = checkChatroom.checked
                        meetinginfoObj["enableInvitation"] = checkInvitation.checked
                        meetinginfoObj["enableScreenShare"] = checkScreenShare.checked
                        meetinginfoObj["enableView"] = checkView.checked
                        meetinginfoObj["autoOpenWhiteboard"] = autoOpenWhiteboard.checked
                        meetinginfoObj["rename"] = autorename.checked
                        meetinginfoObj["displayOption"] = displayOption.currentIndex
                        meetinginfoObj["enableRecord"] = idOpenRecord.checked
                        meetinginfoObj["openWhiteboard"] = idOpenWhiteboard.checked
                        meetinginfoObj["audioAINS"] = idAudioAINS.checked
                        meetinginfoObj["sip"] = checkSip.checked
                        meetinginfoObj["showMemberTag"] = idShowMemberTag.checked
                        meetinginfoObj["extraData"] = extraData.text
                        meetinginfoObj["controls"] = controls
                        meetinginfoObj["enableMuteAllVideo"] = enableMuteAllVideo.checked
                        meetinginfoObj["enableMuteAllAudio"] = enableMuteAllAudio.checked
                        meetinginfoObj["strRoleBinds"] = roleBinds.text
                        meetinginfoObj["showRemainingTip"] = idShowRemainingTip.checked
                        meetinginfoObj["password"] = textpassword.text
                        meetinginfoObj["enableFileMessage"] = idEnableFileMessage.checked
                        meetinginfoObj["enableImageMessage"] = idEnableImageMessage.checked

                        meetingManager.invokeStart(meetinginfoObj)
                    }
                }
                Button {
                    id: btnJoin
                    highlighted: true
                    text: qsTr('Join')
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    onClicked: {
                        btnJoin.enabled = false

                        var meetinginfoObj = {}
                        meetinginfoObj["anonymous"] = false
                        meetinginfoObj["meetingId"] = textMeetingId.text.split("-").join("")
                        meetinginfoObj["nickname"] = textNickname.text
                        meetinginfoObj["tag"] = textTag.text
                        meetinginfoObj["timeOut"] = textTimeout.text
                        meetinginfoObj["audio"] = checkAudio.checked
                        meetinginfoObj["video"] = checkVideo.checked
                        meetinginfoObj["enableChatroom"] = checkChatroom.checked
                        meetinginfoObj["enableInvitation"] = checkInvitation.checked
                        meetinginfoObj["enableScreenShare"] = checkScreenShare.checked
                        meetinginfoObj["enableView"] = checkView.checked
                        meetinginfoObj["autoOpenWhiteboard"] = autoOpenWhiteboard.checked
                        meetinginfoObj["password"] = textpassword.text
                        meetinginfoObj["rename"] = autorename.checked
                        meetinginfoObj["displayOption"] = displayOption.currentIndex
                        meetinginfoObj["enableRecord"] = idOpenRecord.checked
                        meetinginfoObj["openWhiteboard"] = idOpenWhiteboard.checked
                        meetinginfoObj["audioAINS"] = idAudioAINS.checked
                        meetinginfoObj["sip"] = checkSip.checked
                        meetinginfoObj["showMemberTag"] = idShowMemberTag.checked
                        meetinginfoObj["enableMuteAllVideo"] = enableMuteAllVideo.checked
                        meetinginfoObj["enableMuteAllAudio"] = enableMuteAllAudio.checked
                        meetinginfoObj["showRemainingTip"] = idShowRemainingTip.checked
                        meetinginfoObj["enableFileMessage"] = idEnableFileMessage.checked
                        meetinginfoObj["enableImageMessage"] = idEnableImageMessage.checked

                        meetingManager.invokeJoin(meetinginfoObj)
                    }
                }
                Button {
                    id: btnLeave
                    highlighted: true
                    text: qsTr('Leave')
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    enabled: false
                    onClicked: meetingManager.leaveMeeting(false)
                }
                Button {
                    id: btnFinish
                    highlighted: true
                    text: qsTr('Finish')
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    enabled: false
                    onClicked: meetingManager.leaveMeeting(true)
                }
            }
            RowLayout {
                Layout.topMargin: 0
                Layout.alignment: Qt.AlignLeft
                Button {
                    id: btnGet
                    highlighted: true
                    enabled: false
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    text: qsTr('Get Info')
                    onClicked: meetingManager.getMeetingInfo()
                }
                Button {
                    id: getStatus
                    highlighted: true
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    text: qsTr('Get Status')
                    onClicked: {
                        toast.show('Current meeting status: ' + meetingManager.getMeetingStatus(
                                       ))
                    }
                }
                Button {
                    id: getHistoryMeeting
                    highlighted: true
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 150
                    text: qsTr('Get History Info')
                    onClicked: meetingManager.getHistoryMeetingItem()
                }
            }
        }
    }

    Dialog {
        id: showInfoDialog
        standardButtons: Dialog.Cancel
        property string tipInfo: ""

        contentItem: Rectangle {
            implicitHeight: 500
            implicitWidth: 830
            anchors.fill: parent
            Text {
                anchors.fill: parent
                text: showInfoDialog.tipInfo
                wrapMode: Text.Wrap
                font.pixelSize: 16
            }
            Button {
                anchors.bottom: parent.bottom
                text: qsTr('exit')
                onClicked: showInfoDialog.close()
            }
        }

        onVisibleChanged: {
            if (!visible) {
                tipInfo = ""
            }
        }
    }

    Dialog {
        id: meetinginfo
        standardButtons: Dialog.Save | Dialog.Cancel

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
        property string extraData: ""

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
                    text: "extraData: " + meetinginfo.extraData
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
                    RowLayout {
                        Label {
                            text: "userId: " + model.userId
                        }

                        Label {
                            text: "userName: " + model.userName
                        }

                        Label {
                            text: "tag: " + model.tag
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
                btnFinish.enabled = true
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
            if (MeetingStatus.ERROR_CODE_SUCCESS !== errorCode) {
                btnCreate.enabled = true
            }
        }
        onJoinSignal: {
            switch (errorCode) {
            case MeetingStatus.ERROR_CODE_SUCCESS:
                toast.show(qsTr("Join successfull"))
                btnLeave.enabled = true
                btnFinish.enabled = true
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
            if (MeetingStatus.ERROR_CODE_SUCCESS !== errorCode) {
                btnJoin.enabled = true
            }
        }
        onLeaveSignal: {
            toast.show('Leave meeting signal: ' + errorCode + ", " + errorMessage)

            if(errorCode == 0) {
                btnGet.enabled = false
                btnCreate.enabled = true
                btnJoin.enabled = true
                btnLeave.enabled = false
                btnFinish.enabled = false
                subscribeAudio.enabled = false
            }
        }
        onFinishSignal: {
            toast.show('Finsh meeting signal: ' + errorCode + ", " + errorMessage)
            if(errorCode == 0) {
                btnGet.enabled = false
                btnCreate.enabled = true
                btnJoin.enabled = true
                btnLeave.enabled = false
                btnFinish.enabled = false
                subscribeAudio.enabled = false
            }
        }
        onMeetingStatusChanged: {
            toast.show(qsTr('MeetingStatus: ') + meetingStatus)
            switch (meetingStatus) {
            case RunningStatus.MEETING_STATUS_CONNECTING:
                break
            case RunningStatus.MEETING_STATUS_IDLE:
            case RunningStatus.MEETING_STATUS_DISCONNECTING:
                if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SELF)
                    toast.show(qsTr('You have left the meeting'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_NORMAL)
                    toast.show(qsTr('Your have been left this meeting'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_HOST)
                    toast.show(qsTr('This meeting has been ended'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_KICKOUT)
                    toast.show(qsTr('You have been removed from meeting by host'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_MULTI_SPOT)
                    toast.show(qsTr('You have been kickout by other client'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST)
                    toast.show(qsTr('You have finish this meeting'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_AUTH_INFO_EXPIRED)
                    toast.show(qsTr('Disconnected by auth info expored'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SERVER)
                    toast.show(qsTr('You have been discconected from server'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_ROOMNOTEXIST)
                    toast.show(qsTr('The meeting does not exist'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SYNCDATAERROR)
                    toast.show(qsTr(
                                   'Failed to synchronize meeting information'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_RTCINITERROR)
                    toast.show(qsTr('The RTC module fails to be initialized'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_JOINCHANNELERROR)
                    toast.show(qsTr('Failed to join the channel of RTC'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_TIMEOUT)
                    toast.show(qsTr('Meeting timeout'))
                else if (extCode === RunningStatus.MEETING_WAITING_VERIFY_PASSWORD)
                    toast.show(qsTr('need meeting password'))

                btnGet.enabled = false
                btnCreate.enabled = true
                btnJoin.enabled = true
                btnLeave.enabled = false
                btnFinish.enabled = false
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
            meetinginfo.extraData = meetingBaseInfo.extraData

            listUserModel.clear()
            for (var i = 0; i < meetingUserList.length; i++) {
                const user = meetingUserList[i]
                listUserModel.append(user)
                console.log("userid", user.userId)
                console.log("userName", user.userName)
                console.log("tag", user.tag)
            }

            meetinginfo.open()
        }
        onGetHistoryMeetingInfo: {
            toast.show('Get history meeting info, ID: ' + meetingId
                       + ', meetingUniqueId: ' + meetingUniqueId
                       + ', shortMeetingId: ' + shortMeetingId + ', subject: ' + subject
                       + ', password: ' + password + ', nickname: ' + nickname + ', sip: ' + sipId)
        }
        onGetScheduledMeetingList: {
            listModel.clear()
            let datetimeFlag = 0
            for (var i = 0; i < meetingList.length; i++) {
                const meeting = meetingList[i]
                listModel.append(meeting)
            }
            meetingManager.getAccountInfo()
        }

        onDeviceStatusChanged: {
            if (type === 1) {
                checkAudio.checked = status
                toast.show('audio device status is ' + status)
            } else if (type === 2) {
                checkVideo.checked = status
                toast.show('video device status is ' + status)
            } else if (type === 3) {
                toast.show('audio AINS status is ' + status)
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

        onShowSettingsSignal: {
            idSettings.enabled = true
        }

        onVirtualBackgroundList: {
            if (vbList === "") {
                toast.show(qsTr("success"))
            } else {
                showInfoDialog.tipInfo = vbList
                showInfoDialog.open()
            }
        }

        onLogoutSignal: {
            mainWindow.close()
        }

        onGetPersonalMeetingIdChanged: {
            toast.show('GetPersonalMeetingId: ' + message)
        }
    }

    function prettyConferenceId(conferenceId) {
        return conferenceId.substring(0, 3) + "-" + conferenceId.substring(
                    3, 6) + "-" + conferenceId.substring(6)
    }
}
