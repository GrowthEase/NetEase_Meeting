import QtQuick 2.0
import QtQuick.Controls
import QtQuick.Layouts
import NetEase.Meeting.RunningStatus 1.0
import NetEase.Meeting.MeetingStatus 1.0

Rectangle {
    id: root
    function prettyConferenceId(conferenceId) {
        return conferenceId.substring(0, 3) + "-" + conferenceId.substring(3, 6) + "-" + conferenceId.substring(6);
    }

    anchors.centerIn: parent

    Component.onCompleted: {
        meetingManager.isInitializd();
        checkAudio.checked = meetingManager.checkAudio();
        checkVideo.checked = meetingManager.checkVideo();
        let w = mainWindow.width;
        let h = mainWindow.height;
        mainWindow.width = 1300;
        mainWindow.height = 800;
        mainWindow.x -= (mainWindow.width - w) / 2;
        mainWindow.y -= (mainWindow.height - h) / 2;
        mainWindow.showMaximized();
        Qt.callLater(function () {
                meetingManager.getIsSupportRecord();
                liveTimer.start();
            });
    }

    Timer {
        id: liveTimer
        interval: 500
        repeat: false
        running: false

        onTriggered: {
            meetingManager.getIsSupportLive();
        }
    }
    RowLayout {
        //anchors.centerIn: parent
        anchors.fill: parent
        spacing: 10

        ColumnLayout {
            Layout.preferredHeight: 500
            Layout.preferredWidth: 300
            spacing: 0

            Label {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 24
                text: qsTr('Schedule Meeting')
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
                    Layout.fillWidth: true
                    placeholderText: qsTr('preExtraData')
                    selectByMouse: true
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
                    text: qsTr("is open live")
                    visible: meetingManager.isSupportLive
                }
                CheckBox {
                    id: idRecord
                    text: qsTr("is open record")
                    visible: meetingManager.isSupportRecord
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
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("use audio control")
                }
                CheckBox {
                    id: idPreAudioAttendeeOff
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('audioAttendeeOff')
                    visible: idPreAudioCcontrol.checked
                }
                CheckBox {
                    id: idPreAudioAllowSelfOn
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('audioAllowSelfOn')
                    visible: idPreAudioAttendeeOff.checked
                }
            }
            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: idPreVideoCcontrol
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("use video control")
                }
                CheckBox {
                    id: idPreVideoAttendeeOff
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('videoAttendeeOff')
                    visible: idPreVideoCcontrol.checked
                }
                CheckBox {
                    id: idPreVideoAllowSelfOn
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('videoAllowSelfOn')
                    visible: idPreVideoAttendeeOff.checked
                }
            }
            RowLayout {
                Layout.fillWidth: true

                TextField {
                    id: preRoleBinds
                    Layout.fillWidth: true
                    enabled: true
                    placeholderText: "roleBinds"
                    selectByMouse: true
                }
            }
            Button {
                id: btnSchedule
                Layout.preferredWidth: 100
                highlighted: true
                //Layout.fillWidth: true
                text: qsTr('Schedule')

                onClicked: {
                    var controls = [];
                    if (idPreAudioCcontrol.checked) {
                        var audiocontrol = {};
                        audiocontrol["attendeeOff"] = idPreAudioAttendeeOff.checked;
                        audiocontrol["allowSelfOn"] = idPreAudioAllowSelfOn.checked;
                        audiocontrol["type"] = 0;
                        controls.push(audiocontrol);
                    }
                    if (idPreVideoCcontrol.checked) {
                        var videocontrol = {};
                        videocontrol["attendeeOff"] = idPreVideoAttendeeOff.checked;
                        videocontrol["allowSelfOn"] = idPreVideoAllowSelfOn.checked;
                        videocontrol["type"] = 1;
                        controls.push(videocontrol);
                    }
                    meetingManager.scheduleMeeting(meetingTopic.text, startTimestamp.text, endTimestamp.text, meetingPassword.text, textScene.text, muteCheckbox.checked, idLiveSettingCheck.checked, idSip.checked, idLiveAccessCheck.checked, idRecord.checked, preExtraData.text, controls, preRoleBinds.text);
                }
            }
            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                clip: true
                spacing: 10

                ScrollBar.vertical: ScrollBar {
                    width: 7
                }
                delegate: ItemDelegate {
                    height: 400
                    width: parent.width

                    ColumnLayout {
                        spacing: 0
                        width: parent.width

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
                                checked: model.attendeeAudioOff
                                text: qsTr('Automatically mute after members join')
                            }
                            CheckBox {
                                id: idSipEdit
                                checked: model.enableSip
                                text: qsTr('Enable Sip')
                            }
                        }
                        RowLayout {
                            //  Layout.fillWidth: true
                            CheckBox {
                                id: idLiveSettingCheckEdit
                                checked: model.enableLive
                                text: qsTr("is open live")
                                visible: meetingManager.isSupportLive
                            }
                            CheckBox {
                                id: idLiveAccessCheckEdit
                                checked: model.liveAccess
                                text: qsTr("idLiveAccessCheckEdit")
                            }
                            CheckBox {
                                id: idOpenRecordEdit
                                checked: model.recordEnable
                                text: qsTr("is open record")
                                visible: meetingManager.isSupportRecord
                            }
                        }
                        RowLayout {
                            TextField {
                                id: topic2
                                text: model.topic
                            }
                            Label {
                                color: model.status === 2 ? '#337EFF' : '#999999'
                                font.pixelSize: 12
                                text: {
                                    switch (model.status) {
                                    case 1:
                                        return qsTr('Prepare');
                                    case 2:
                                        return qsTr('Started');
                                    case 3:
                                        return qsTr('Finished');
                                    }
                                }
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
                                Layout.fillWidth: true
                                enabled: true
                                placeholderText: "roleBinds"
                                selectByMouse: true
                                text: model.roleBinds
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true

                            CheckBox {
                                id: idEditAudioCcontrol
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.audioControl !== undefined
                                text: qsTr("use audio control")
                            }
                            CheckBox {
                                id: idEditAudioAttendeeOff
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.audioControl.attendeeOff
                                text: qsTr('audioAttendeeOff')
                            }
                            CheckBox {
                                id: idEditAudioAllowSelfOn
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.audioControl.allowSelfOn
                                text: qsTr('audioAllowSelfOn')
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true

                            CheckBox {
                                id: idEditVideoCcontrol
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.videoControl !== undefined
                                text: qsTr("use video control")
                            }
                            CheckBox {
                                id: idEditVideoAttendeeOff
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.videoControl !== undefined && model.videoControl.attendeeOff
                                text: qsTr('videoAttendeeOff')
                            }
                            CheckBox {
                                id: idEditVideoAllowSelfOn
                                Layout.alignment: Qt.AlignHCenter
                                checked: model.videoControl !== undefined && model.videoControl.allowSelfOn
                                text: qsTr('videoAllowSelfOn')
                            }
                        }
                        RowLayout {
                            Layout.preferredWidth: 40

                            Button {
                                Layout.preferredHeight: 30
                                //Layout.fillWidth: true
                                Layout.preferredWidth: 100
                                text: qsTr('Join')

                                onClicked: {
                                    var meetinginfoObj = {};
                                    meetinginfoObj["anonymous"] = false;
                                    meetinginfoObj["meetingId"] = model.meetingId;
                                    meetinginfoObj["nickname"] = textNickname.text;
                                    meetinginfoObj["tag"] = textTag.text;
                                    meetinginfoObj["timeOut"] = textTimeout.text;
                                    meetinginfoObj["audio"] = checkAudio.checked;
                                    meetinginfoObj["video"] = checkVideo.checked;
                                    meetinginfoObj["enableChatroom"] = checkChatroom.checked;
                                    meetinginfoObj["enableInvitation"] = checkInvitation.checked;
                                    meetinginfoObj["enableScreenShare"] = checkScreenShare.checked;
                                    meetinginfoObj["enableView"] = checkView.checked;
                                    meetinginfoObj["autoOpenWhiteboard"] = autoOpenWhiteboard.checked;
                                    meetinginfoObj["password"] = password2.text;
                                    meetinginfoObj["rename"] = autorename.checked;
                                    meetinginfoObj["sip"] = idSipEdit.checked;
                                    meetinginfoObj["showRemainingTip"] = idShowRemainingTip.checked;
                                    meetingManager.invokeJoin(meetinginfoObj);
                                }
                            }
                            Button {
                                Layout.preferredHeight: 30
                                //Layout.fillWidth: true
                                Layout.preferredWidth: 100
                                text: qsTr('Cancel')

                                onClicked: {
                                    meetingManager.cancelMeeting(model.uniqueMeetingId);
                                }
                            }
                            Button {
                                Layout.preferredHeight: 30
                                //Layout.fillWidth: true
                                Layout.preferredWidth: 100
                                text: qsTr('Edit')

                                onClicked: {
                                    var controls = [];
                                    if (idEditAudioCcontrol.checked) {
                                        var audiocontrol = {};
                                        audiocontrol["attendeeOff"] = idEditAudioAttendeeOff.checked;
                                        audiocontrol["allowSelfOn"] = idEditAudioAllowSelfOn.checked;
                                        audiocontrol["type"] = 0;
                                        controls.push(audiocontrol);
                                    }
                                    if (idEditVideoCcontrol.checked) {
                                        var videocontrol = {};
                                        videocontrol["attendeeOff"] = idEditVideoAttendeeOff.checked;
                                        videocontrol["allowSelfOn"] = idEditVideoAllowSelfOn.checked;
                                        videocontrol["type"] = 1;
                                        controls.push(videocontrol);
                                    }
                                    meetingManager.editMeeting(model.uniqueMeetingId, model.meetingId, topic2.text, startTimestamp2.text, endTimestamp2.text, password2.text, textScene.text, muteCheckbox2.checked, idLiveSettingCheckEdit.checked, idSipEdit.checked, idLiveAccessCheckEdit.checked, idOpenRecordEdit.checked, editExtraData.text, controls, editRoleBinds.text);
                                }
                            }
                        }
                    }
                }
                model: ListModel {
                    id: listModel
                }

                Component.onCompleted: {
                    Qt.callLater(function () {
                            meetingManager.getMeetingList();
                        });
                }
            }
        }
        ColumnLayout {
            spacing: 0

            RowLayout {
                TextField {
                    id: textMeetingId
                    Layout.fillWidth: true
                    enabled: !checkBox.checked
                    placeholderText: qsTr('Meeting ID')
                    selectByMouse: true
                    text: checkBox.checked ? meetingManager.personalMeetingId : ''
                }
                ComboBox {
                    id: displayOption
                    Layout.fillWidth: true

                    delegate: ItemDelegate {
                        text: model.name
                        width: parent.width

                        onClicked: {
                            displayOption.currentIndex = model.index;
                        }
                    }
                    model: ListModel {
                        id: displayModel
                    }

                    Component.onCompleted: {
                        displayModel.append({
                                "name": 'Display Short Only'
                            });
                        displayModel.append({
                                "name": 'Display Long Only'
                            });
                        displayModel.append({
                                "name": 'Display All'
                            });
                        displayOption.currentIndex = 2;
                    }
                }
                ToolButton {
                    id: idgetPMId
                    Layout.topMargin: 10
                    text: qsTr("getPMId")

                    onClicked: {
                        meetingManager.getPersonalMeetingId();
                    }
                }
                ToolButton {
                    id: idSettings
                    Layout.rightMargin: 10
                    Layout.topMargin: 10
                    text: qsTr("settings")

                    onClicked: {
                        idSettings.enabled = false;
                        meetingManager.showSettings();
                    }
                }
            }
            RowLayout {
                TextField {
                    id: textNickname
                    Layout.fillWidth: true
                    placeholderText: qsTr('Your nickname')
                    selectByMouse: true
                    text: qsTr('nickname')
                }
                TextField {
                    id: textpassword
                    Layout.fillWidth: true
                    placeholderText: qsTr('meeting password')
                    selectByMouse: true
                }
                TextField {
                    id: textTimeout
                    Layout.fillWidth: true
                    placeholderText: qsTr('enter meeting timeout(ms)')
                    selectByMouse: true
                    text: 45 * 1000
                }
            }
            RowLayout {
                TextField {
                    id: textTag
                    Layout.fillWidth: true
                    placeholderText: qsTr('user tag')
                    selectByMouse: true
                }
                TextField {
                    id: subject
                    Layout.fillWidth: true
                    placeholderText: qsTr('subject')
                    selectByMouse: true
                }
                TextField {
                    id: extraData
                    Layout.fillWidth: true
                    placeholderText: qsTr('extraData')
                    selectByMouse: true
                }
                TextField {
                    id: textScene
                    Layout.fillWidth: true
                    placeholderText: qsTr('scene setting')
                    selectByMouse: true
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
                    checked: meetingManager.isAudioAINS
                    text: qsTr("is AudioAINS")

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
                    visible: true
                }
                CheckBox {
                    id: checkBox
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('Personal meeting ID: %1').arg(meetingManager.personalMeetingId)
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
                    id: idEnableDetectMutedMic
                    checked: true
                    text: qsTr('Enable DetectMutedMic')
                }
                CheckBox {
                    id: idEnableUnpubAudioOnMute
                    checked: true
                    text: qsTr('Enable UnpubAudioOnMute')
                }
                CheckBox {
                    id: idAudioCcontrol
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("use audio control")
                }
                CheckBox {
                    id: idAudioAttendeeOff
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('audioAttendeeOff')
                    visible: idAudioCcontrol.checked
                }
                CheckBox {
                    id: idAudioAllowSelfOn
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('audioAllowSelfOn')
                    visible: idAudioAttendeeOff.checked
                }
            }
            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: idVideoCcontrol
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("use video control")
                }
                CheckBox {
                    id: idVideoAttendeeOff
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('videoAttendeeOff')
                    visible: idVideoCcontrol.checked
                }
                CheckBox {
                    id: idVideoAllowSelfOn
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('videoAllowSelfOn')
                    visible: idVideoAttendeeOff.checked
                }
                CheckBox {
                    id: idEnableStreamEncryption
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Enable stream encryption")
                }
                TextField {
                    id: idEncryptionKey
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: qsTr("Sidebar view")
                }
                ComboBox {
                    id: idSharingSidebarViewMode
                    currentIndex: 0
                    model: ["0", "1", "2"]

                    onCurrentTextChanged: {
                        meetingManager.setSharingSidebarViewMode(parseInt(currentText));
                    }
                }
                Button {
                    text: qsTr("Get view mode")

                    onClicked: {
                        meetingManager.getSharingSidebarViewMode();
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: idAudioDeviceAutoSelectType
                    checked: meetingManager.audodeviceAutoSelectType
                    text: qsTr('AudioDeviceAutoSelectType Available')

                    onClicked: meetingManager.setAudodeviceAutoSelectType(checked)
                }
                CheckBox {
                    id: idBeauty
                    checked: meetingManager.beauty
                    text: qsTr("Show Beauty")

                    onClicked: meetingManager.beauty = checked
                }
                TextField {
                    id: idBeautyValue
                    Layout.preferredWidth: 100
                    inputMethodHints: Qt.ImhDigitsOnly
                    maximumLength: 2
                    placeholderText: qsTr('Beauty Value')
                    selectByMouse: true
                    text: meetingManager.beautyValue

                    onAccepted: meetingManager.beautyValue = parseInt(idBeautyValue.text)
                }
                CheckBox {
                    id: idVirtualBackground
                    checked: meetingManager.virtualBackground
                    text: qsTr("Show VB")

                    onClicked: meetingManager.virtualBackground = checked
                }
                Button {
                    id: btnDefaultVB
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    highlighted: true
                    text: qsTr('Default VB')

                    onClicked: {
                        meetingManager.getVirtualBackgroundList();
                    }
                }
                TextField {
                    id: vbList
                    Layout.fillWidth: true
                    placeholderText: qsTr('vb path,vb path,vb path....')
                    selectByMouse: true
                }
                Button {
                    id: btnSetVB
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    highlighted: true
                    text: qsTr('Set VB')

                    onClicked: {
                        meetingManager.setVirtualBackgroundList(vbList.text);
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: idCustomMenu
                    Layout.alignment: Qt.AlignHCenter
                    checked: false
                    text: qsTr('CustomMenu')
                }
                ComboBox {
                    id: idVideoFramerate
                    currentIndex: 0
                    model: ["-1", "0", "7", "10", "15", "24", "30", "60"]

                    onCurrentTextChanged: {
                        meetingManager.setVideoFramerate(currentText);
                    }
                }
                CheckBox {
                    id: idAudioDeviceUseLastSelected
                    Layout.alignment: Qt.AlignHCenter
                    checked: meetingManager.audioDeviceUseLastSelected
                    text: qsTr('AudioDeviceUseLastSelected')

                    onClicked: {
                        meetingManager.audioDeviceUseLastSelected = checked;
                    }
                }
                TextField {
                    id: roleBinds
                    Layout.fillWidth: true
                    enabled: true
                    placeholderText: "roleBinds"
                    selectByMouse: true
                }
            }
            RowLayout {
                id: subscribeAudio
                enabled: false

                TextField {
                    id: accoundList
                    Layout.fillWidth: true
                    enabled: !all.checked
                    placeholderText: single.checked ? qsTr('accoundId') : (multiple.checked ? qsTr('accoundId,accoundId,accoundId....') : '')
                    selectByMouse: true
                }
                RadioButton {
                    id: single
                    text: qsTr('Single')
                }
                RadioButton {
                    id: multiple
                    checked: true
                    text: qsTr('multiple')
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
                RowLayout {
                    Button {
                        id: btnSubscribe
                        //Layout.fillWidth: true
                        Layout.preferredWidth: 150
                        highlighted: true
                        text: qsTr('Subscribe Audio')

                        onClicked: {
                            meetingManager.subcribeAudio(accoundList.text, true, single.checked ? 0 : (multiple.checked ? 1 : 2));
                        }
                    }
                    Button {
                        id: btnUnSubscribe
                        //Layout.fillWidth: true
                        Layout.preferredWidth: 170
                        highlighted: true
                        text: qsTr('UnSubscribe Audio')

                        onClicked: {
                            meetingManager.subcribeAudio(accoundList.text, false, single.checked ? 0 : (multiple.checked ? 1 : 2));
                        }
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: 0

                Button {
                    id: btnCreate
                    Layout.preferredWidth: 100
                    highlighted: true
                    text: qsTr('Create')

                    //Layout.fillWidth: true
                    onClicked: {
                        btnCreate.enabled = false;
                        var controls = [];
                        if (idAudioCcontrol.checked) {
                            var audiocontrol = {};
                            audiocontrol["attendeeOff"] = idAudioAttendeeOff.checked;
                            audiocontrol["allowSelfOn"] = idAudioAllowSelfOn.checked;
                            audiocontrol["type"] = 0;
                            controls.push(audiocontrol);
                        }
                        if (idVideoCcontrol.checked) {
                            var videocontrol = {};
                            videocontrol["attendeeOff"] = idVideoAttendeeOff.checked;
                            videocontrol["allowSelfOn"] = idVideoAllowSelfOn.checked;
                            videocontrol["type"] = 1;
                            controls.push(videocontrol);
                        }
                        var meetinginfoObj = {};
                        meetinginfoObj["meetingId"] = checkBox.checked ? meetingManager.personalMeetingId : '';
                        meetinginfoObj["nickname"] = textNickname.text;
                        meetinginfoObj["tag"] = textTag.text;
                        meetinginfoObj["textScene"] = textScene.text;
                        meetinginfoObj["timeOut"] = textTimeout.text;
                        meetinginfoObj["audio"] = checkAudio.checked;
                        meetinginfoObj["video"] = checkVideo.checked;
                        meetinginfoObj["enableChatroom"] = checkChatroom.checked;
                        meetinginfoObj["enableInvitation"] = checkInvitation.checked;
                        meetinginfoObj["enableScreenShare"] = checkScreenShare.checked;
                        meetinginfoObj["enableView"] = checkView.checked;
                        meetinginfoObj["autoOpenWhiteboard"] = autoOpenWhiteboard.checked;
                        meetinginfoObj["rename"] = autorename.checked;
                        meetinginfoObj["displayOption"] = displayOption.currentIndex;
                        meetinginfoObj["enableRecord"] = idOpenRecord.checked;
                        meetinginfoObj["openWhiteboard"] = idOpenWhiteboard.checked;
                        meetinginfoObj["audioAINS"] = idAudioAINS.checked;
                        meetinginfoObj["sip"] = checkSip.checked;
                        meetinginfoObj["showMemberTag"] = idShowMemberTag.checked;
                        meetinginfoObj["subject"] = subject.text;
                        meetinginfoObj["extraData"] = extraData.text;
                        meetinginfoObj["controls"] = controls;
                        meetinginfoObj["enableMuteAllVideo"] = enableMuteAllVideo.checked;
                        meetinginfoObj["enableMuteAllAudio"] = enableMuteAllAudio.checked;
                        meetinginfoObj["strRoleBinds"] = roleBinds.text;
                        meetinginfoObj["showRemainingTip"] = idShowRemainingTip.checked;
                        meetinginfoObj["password"] = textpassword.text;
                        meetinginfoObj["enableFileMessage"] = idEnableFileMessage.checked;
                        meetinginfoObj["enableImageMessage"] = idEnableImageMessage.checked;
                        meetinginfoObj["enableDetectMutedMic"] = idEnableDetectMutedMic.checked;
                        meetinginfoObj["enableUnpubAudioOnMute"] = idEnableUnpubAudioOnMute.checked;
                        meetinginfoObj["customMenu"] = idCustomMenu.checked;
                        meetinginfoObj["enableEncryption"] = idEnableStreamEncryption.checked;
                        meetinginfoObj["encryptionKey"] = idEncryptionKey.text;
                        meetingManager.invokeStart(meetinginfoObj);
                    }
                }
                Button {
                    id: btnJoin
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    highlighted: true
                    text: qsTr('Join')

                    onClicked: {
                        btnJoin.enabled = false;
                        var meetinginfoObj = {};
                        meetinginfoObj["anonymous"] = false;
                        meetinginfoObj["meetingId"] = textMeetingId.text.split("-").join("");
                        meetinginfoObj["nickname"] = textNickname.text;
                        meetinginfoObj["tag"] = textTag.text;
                        meetinginfoObj["timeOut"] = textTimeout.text;
                        meetinginfoObj["audio"] = checkAudio.checked;
                        meetinginfoObj["video"] = checkVideo.checked;
                        meetinginfoObj["enableChatroom"] = checkChatroom.checked;
                        meetinginfoObj["enableInvitation"] = checkInvitation.checked;
                        meetinginfoObj["enableScreenShare"] = checkScreenShare.checked;
                        meetinginfoObj["enableView"] = checkView.checked;
                        meetinginfoObj["autoOpenWhiteboard"] = autoOpenWhiteboard.checked;
                        meetinginfoObj["password"] = textpassword.text;
                        meetinginfoObj["rename"] = autorename.checked;
                        meetinginfoObj["displayOption"] = displayOption.currentIndex;
                        meetinginfoObj["enableRecord"] = idOpenRecord.checked;
                        meetinginfoObj["openWhiteboard"] = idOpenWhiteboard.checked;
                        meetinginfoObj["audioAINS"] = idAudioAINS.checked;
                        meetinginfoObj["sip"] = checkSip.checked;
                        meetinginfoObj["showMemberTag"] = idShowMemberTag.checked;
                        meetinginfoObj["enableMuteAllVideo"] = enableMuteAllVideo.checked;
                        meetinginfoObj["enableMuteAllAudio"] = enableMuteAllAudio.checked;
                        meetinginfoObj["showRemainingTip"] = idShowRemainingTip.checked;
                        meetinginfoObj["enableFileMessage"] = idEnableFileMessage.checked;
                        meetinginfoObj["enableImageMessage"] = idEnableImageMessage.checked;
                        meetinginfoObj["enableDetectMutedMic"] = idEnableDetectMutedMic.checked;
                        meetinginfoObj["enableUnpubAudioOnMute"] = idEnableUnpubAudioOnMute.checked;
                        meetinginfoObj["customMenu"] = idCustomMenu.checked;
                        meetinginfoObj["enableEncryption"] = idEnableStreamEncryption.checked;
                        meetinginfoObj["encryptionKey"] = idEncryptionKey.text;
                        meetingManager.invokeJoin(meetinginfoObj);
                    }
                }
                Button {
                    id: btnLeave
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    enabled: false
                    highlighted: true
                    text: qsTr('Leave')

                    onClicked: meetingManager.leaveMeeting(false)
                }
                Button {
                    id: btnFinish
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    enabled: false
                    highlighted: true
                    text: qsTr('Finish')

                    onClicked: meetingManager.leaveMeeting(true)
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: 0

                Button {
                    id: btnGet
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    enabled: false
                    highlighted: true
                    text: qsTr('Get Info')

                    onClicked: meetingManager.getMeetingInfo()
                }
                Button {
                    id: getStatus
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 100
                    highlighted: true
                    text: qsTr('Get Status')

                    onClicked: {
                        toast.show('Current meeting status: ' + meetingManager.getMeetingStatus());
                    }
                }
                Button {
                    id: getHistoryMeeting
                    //Layout.fillWidth: true
                    Layout.preferredWidth: 150
                    highlighted: true
                    text: qsTr('Get History Info')

                    onClicked: meetingManager.getHistoryMeetingItem()
                }
            }
        }
    }
    Dialog {
        id: showInfoDialog

        property string tipInfo: ""

        standardButtons: Dialog.Cancel

        contentItem: Rectangle {
            anchors.fill: parent
            implicitHeight: 500
            implicitWidth: 830

            Text {
                anchors.fill: parent
                font.pixelSize: 16
                text: showInfoDialog.tipInfo
                wrapMode: Text.Wrap
            }
            Button {
                anchors.bottom: parent.bottom
                text: qsTr('exit')

                onClicked: showInfoDialog.close()
            }
        }

        onVisibleChanged: {
            if (!visible) {
                tipInfo = "";
            }
        }
    }
    Dialog {
        id: meetinginfo

        property int duration: 0
        property string extraData: ""
        property string hostUserId: ""
        property bool isHost: false
        property bool isLocked: false
        property string meetingId: ""
        property int meetingUniqueId: 0
        property string password: ""
        property string scheduleEndTime: ""
        property string scheduleStartTime: ""
        property string shortMeetingNum: ""
        property string sipId: ""
        property string startTime: ""
        property string subject: ""

        standardButtons: Dialog.Save | Dialog.Cancel

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
                    text: "meetingId: " + meetinginfo.meetingUniqueId
                }
                Label {
                    text: "meetingNum: " + meetinginfo.meetingId
                }
                Label {
                    text: "shortMeetingNum: " + meetinginfo.shortMeetingNum
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
                anchors.left: col.left
                anchors.top: col.bottom
                height: 300
                width: parent.width

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
                model: ListModel {
                    id: listUserModel
                }
            }
        }
    }
    Connections {
        target: meetingManager

        onSharingSidebarViewModeNotify: {
            toast.show(qsTr(`Current sharing sidebar view mode: ${viewMode}`));
        }
        onCancelSignal: {
            switch (errorCode) {
            case 0:
                toast.show(qsTr("Cancel successfull"));
                break;
            default:
                toast.show(errorCode + '(' + errorMessage + ')');
                break;
            }
        }
        onDeviceStatusChanged: {
            if (type === 1) {
                checkAudio.checked = status;
                toast.show('audio device status is ' + status);
            } else if (type === 2) {
                checkVideo.checked = status;
                toast.show('video device status is ' + status);
            } else if (type === 3) {
                toast.show('audio AINS status is ' + status);
            }
        }
        onEditSignal: {
            switch (errorCode) {
            case 0:
                toast.show(qsTr("Edit successfull"));
                break;
            default:
                toast.show(errorCode + '(' + errorMessage + ')');
                break;
            }
        }
        onError: {
            toast.show(errorCode + '(' + errorMessage + ')');
        }
        onFinishSignal: {
            toast.show('Finsh meeting signal: ' + errorCode + ", " + errorMessage);
            if (errorCode == 0) {
                btnGet.enabled = false;
                btnCreate.enabled = true;
                btnJoin.enabled = true;
                btnLeave.enabled = false;
                btnFinish.enabled = false;
                subscribeAudio.enabled = false;
            }
        }
        onGetCurrentMeetingInfo: {
            meetinginfo.meetingUniqueId = meetingBaseInfo.meetingUniqueId;
            meetinginfo.meetingId = meetingBaseInfo.meetingId;
            meetinginfo.shortMeetingNum = meetingBaseInfo.shortMeetingNum;
            meetinginfo.subject = meetingBaseInfo.subject;
            meetinginfo.password = meetingBaseInfo.password;
            meetinginfo.isHost = meetingBaseInfo.isHost;
            meetinginfo.isLocked = meetingBaseInfo.isLocked;
            meetinginfo.scheduleStartTime = meetingBaseInfo.scheduleStartTime;
            meetinginfo.scheduleEndTime = meetingBaseInfo.scheduleEndTime;
            meetinginfo.startTime = meetingBaseInfo.startTime;
            meetinginfo.sipId = meetingBaseInfo.sipId;
            meetinginfo.duration = meetingBaseInfo.duration;
            meetinginfo.hostUserId = meetingBaseInfo.hostUserId;
            meetinginfo.extraData = meetingBaseInfo.extraData;
            listUserModel.clear();
            for (var i = 0; i < meetingUserList.length; i++) {
                const user = meetingUserList[i];
                listUserModel.append(user);
                console.log("userid", user.userId);
                console.log("userName", user.userName);
                console.log("tag", user.tag);
            }
            meetinginfo.open();
        }
        onGetHistoryMeetingInfo: {
            toast.show('Get history meeting info, ID: ' + meetingId + ', meetingUniqueId: ' + meetingUniqueId + ', shortMeetingNum: ' + shortMeetingNum + ', subject: ' + subject + ', password: ' + password + ', nickname: ' + nickname + ', sip: ' + sipId);
        }
        onGetPersonalMeetingIdChanged: {
            toast.show('GetPersonalMeetingId: ' + message);
        }
        onGetScheduledMeetingList: {
            listModel.clear();
            let datetimeFlag = 0;
            for (var i = 0; i < meetingList.length; i++) {
                const meeting = meetingList[i];
                listModel.append(meeting);
            }
            meetingManager.getAccountInfo();
        }
        onJoinSignal: {
            switch (errorCode) {
            case MeetingStatus.ERROR_CODE_SUCCESS:
                toast.show(qsTr("Join successfull"));
                btnLeave.enabled = true;
                btnFinish.enabled = true;
                btnGet.enabled = true;
                btnCreate.enabled = false;
                btnJoin.enabled = false;
                subscribeAudio.enabled = true;
                break;
            case MeetingStatus.MEETING_ERROR_LOCKED_BY_HOST:
                toast.show(qsTr('The meeting is locked'));
                break;
            case MeetingStatus.MEETING_ERROR_INVALID_ID:
                toast.show(qsTr('Meeting not exist'));
                break;
            case MeetingStatus.MEETING_ERROR_LIMITED:
                toast.show(qsTr('Exceeds the limit'));
                break;
            case MeetingStatus.ERROR_CODE_FAILED:
                toast.show(qsTr('Failed to join meeting'));
                break;
            default:
                toast.show(errorCode + '(' + errorMessage + ')');
                break;
            }
            if (MeetingStatus.ERROR_CODE_SUCCESS !== errorCode) {
                btnJoin.enabled = true;
            }
        }
        onLeaveSignal: {
            toast.show('Leave meeting signal: ' + errorCode + ", " + errorMessage);
            if (errorCode == 0) {
                btnGet.enabled = false;
                btnCreate.enabled = true;
                btnJoin.enabled = true;
                btnLeave.enabled = false;
                btnFinish.enabled = false;
                subscribeAudio.enabled = false;
            }
        }
        onLogoutSignal: {
            mainWindow.close();
        }
        onMeetingInjectedMenuItemClicked: {
            toast.show('Meeting item clicked, item title: ' + itemTitle);
        }
        onMeetingStatusChanged: {
            toast.show(qsTr('MeetingStatus: ') + meetingStatus);
            switch (meetingStatus) {
            case RunningStatus.MEETING_STATUS_CONNECTING:
                break;
            case RunningStatus.MEETING_STATUS_IDLE:
            case RunningStatus.MEETING_STATUS_DISCONNECTING:
                if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SELF)
                    toast.show(qsTr('You have left the meeting'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_NORMAL)
                    toast.show(qsTr('Your have been left this meeting'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_HOST)
                    toast.show(qsTr('This meeting has been ended'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_KICKOUT)
                    toast.show(qsTr('You have been removed from meeting by host'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_MULTI_SPOT)
                    toast.show(qsTr('You have been kickout by other client'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST)
                    toast.show(qsTr('You have finish this meeting'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_AUTH_INFO_EXPIRED)
                    toast.show(qsTr('Disconnected by auth info expored'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SERVER)
                    toast.show(qsTr('You have been discconected from server'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_ROOMNOTEXIST)
                    toast.show(qsTr('The meeting does not exist'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SYNCDATAERROR)
                    toast.show(qsTr('Failed to synchronize meeting information'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_RTCINITERROR)
                    toast.show(qsTr('The RTC module fails to be initialized'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_JOINCHANNELERROR)
                    toast.show(qsTr('Failed to join the channel of RTC'));
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_TIMEOUT)
                    toast.show(qsTr('Meeting timeout'));
                else if (extCode === RunningStatus.MEETING_WAITING_VERIFY_PASSWORD)
                    toast.show(qsTr('need meeting password'));
                btnGet.enabled = false;
                btnCreate.enabled = true;
                btnJoin.enabled = true;
                btnLeave.enabled = false;
                btnFinish.enabled = false;
                subscribeAudio.enabled = false;
                break;
            }
        }
        onScheduleSignal: {
            switch (errorCode) {
            case 0:
                toast.show(qsTr("Schedule successfull"));
                break;
            default:
                toast.show(errorCode + '(' + errorMessage + ')');
                break;
            }
        }
        onShowSettingsSignal: {
            idSettings.enabled = true;
        }
        onStartSignal: {
            switch (errorCode) {
            case MeetingStatus.ERROR_CODE_SUCCESS:
                toast.show(qsTr('Create successfull'));
                btnLeave.enabled = true;
                btnFinish.enabled = true;
                btnGet.enabled = true;
                btnCreate.enabled = false;
                btnJoin.enabled = false;
                subscribeAudio.enabled = true;
                break;
            case MeetingStatus.MEETING_ERROR_FAILED_MEETING_ALREADY_EXIST:
                toast.show(qsTr('Meeting already started'));
                break;
            case MeetingStatus.ERROR_CODE_FAILED:
                toast.show(qsTr('Failed to start meeting'));
                break;
            default:
                toast.show(errorCode + '(' + errorMessage + ')');
                break;
            }
            if (MeetingStatus.ERROR_CODE_SUCCESS !== errorCode) {
                btnCreate.enabled = true;
            }
        }
        onVirtualBackgroundList: {
            if (vbList === "") {
                toast.show(qsTr("success"));
            } else {
                showInfoDialog.tipInfo = vbList;
                showInfoDialog.open();
            }
        }
    }
}
