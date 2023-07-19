import QtQuick 2.15
import QtQuick.Window 2.14
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.RunningStatus 1.0
import "utils/dialogManager.js" as DialogManager
import NetEase.Meeting.GlobalToast 1.0

FrontPageForm {
    Component.onCompleted: {
        const sharedMeetingId = globalSettings.value('sharedMeetingId', '')
        if (sharedMeetingId !== '') {
            textMeetingId.text = sharedMeetingId.substring(
                        0, 3) + "-" + sharedMeetingId.substring(
                        3, 6) + "-" + sharedMeetingId.substring(6)

            popupMode = FrontPage.JoinMode
            popupWindow.open()
            globalSettings.setValue('sharedMeetingId', '')
        }
        Qt.callLater(function(){
            meetingManager.getAccountInfo()

            if (!hasReadSafeTip) {
                configManager.requestServerAppConfigs()
            }

            caption.schedule.visible = Qt.binding(function() { return scheduleList.count > 0 })
            caption.history.visible = true

            const inviteMeetingId = meetingManager.getInviteMeetingId()
            if(inviteMeetingId === '') {
                meetingManager.getNeedResumeMeeting()
            }

        })

//        if(ursPage.visible) {
//            ursPage.visible = false
//        }
//        if(authManager.autoRegistered) {
//            windowModifyNickname.screen = mainWindow.screen
//            windowModifyNickname.x
//                    = (mainWindow.screen.width - windowModifyNickname.width)
//                    / 2 + mainWindow.screen.virtualX
//            windowModifyNickname.y
//                    = (mainWindow.screen.height - windowModifyNickname.height)
//                    / 2 + mainWindow.screen.virtualY
//            windowModifyNickname.visible = true
//            windowModifyNickname.show()
//        }
    }

    Component.onDestruction: {
        caption.schedule.visible = false
        caption.history.visible = false
    }

    popupWindow.onOpened: {
        globalSettings.sync()
        const cameraStatus = globalSettings.value("localCameraStatusEx")
        const microphoneStatus = globalSettings.value("localMicStatusEx")
        checkOpenCamera.checked = cameraStatus === undefined ? false : cameraStatus === true
                                                               || cameraStatus === "true"
        checkOpenMicrophone.checked = microphoneStatus
                === undefined ? false : microphoneStatus === true
                                || microphoneStatus === "true"
    }

    popupWindow.onClosed: {
        idProperty.pswd = ""
        inputMeetingPwd.text = ""
        checkUsePersonalId.checked = false
        checkMeetingPwd.checked = false
    }

    createButton.onClicked: {
        popupMode = FrontPage.CreateMode
        buttonSubmit.text = qsTr("Create")
        inputMeetingPwd.enabled = false
        popupWindow.open()
    }

    joinButton.onClicked: {
        popupMode = FrontPage.JoinMode
        textMeetingId.text = ""
        buttonSubmit.text = qsTr("Join")
        var meetingList = historyManager.getRecentMeetingList();
        if(meetingList.length > 0) {
            textMeetingId.acceptToolClickOnly = true
            textMeetingId.visibleComboBox = true
        } else {
            textMeetingId.acceptToolClickOnly = false
            textMeetingId.visibleComboBox = false
        }
        popupWindow.open()
    }

    btnPopupClose.onCloseClicked: {
        popupWindow.close()
        statisticsManager.meetingStatistics("cancel_meeting", "meeting")
    }

    btnJoinPopupClose.onCloseClicked: {
        popupWindow.close()
        statisticsManager.meetingStatistics("cancel_meeting", "meeting")
    }

    textMeetingId.validator: RegExpValidator {
        regExp: /^[0-9- ]{15}$/
    }

    infoArea.onEntered: {
        tooltips.x = 270
        tooltips.y = 170
        tooltips.open()
    }

    infoArea.onExited: {
        tooltips.close()
    }

    //    textMeetingId.onTextChanged: {
    //        const control = textMeetingId
    //        const regex = /^\d{9,10}$/
    //        if (regex.test(control.text)) {
    //            control.text = control.text.substring(0,3) + "-" +
    //                    control.text.substring(3,6) + "-" +
    //                    control.text.substring(6)
    //        }
    //        if (control.length > lastLengthOfMeetingId) {
    //            if (control.length === 3) {
    //                control.text = control.text + "-"
    //            } else if (control.length === 7) {
    //                control.text = control.text + "-"
    //            }
    //        }
    //        lastLengthOfMeetingId = control.length
    //    }
    personalMeetingId.onClicked: {
        checkUsePersonalId.checked = !checkUsePersonalId.checked
    }

    checkUsePersonalId.onToggled: {
        statisticsManager.meetingStatistics("use_personal_id", "meeting", {
                                                "value": checkUsePersonalId.checked ? 1 : 0
                                            })
    }

    checkOpenCamera.onToggled: {
        statisticsManager.meetingStatistics("open_camera", "meeting", {
                                                "value": checkOpenCamera.checked ? 1 : 0
                                            })
    }

    checkOpenMicrophone.onToggled: {
        statisticsManager.meetingStatistics("open_micro", "meeting", {
                                                "value": checkOpenMicrophone.checked ? 1 : 0
                                            })
    }

    checkMeetingPwd.onToggled: {
        inputMeetingPwd.enabled = checkMeetingPwd.checked
        if (checkMeetingPwd.checked) {
            inputMeetingPwd.text = idProperty.pswd
            if (inputMeetingPwd.text.trim().length === 0) {
                inputMeetingPwd.text = ('000000' + Math.floor(
                                            Math.random() * 999999)).slice(-6)
            }
        } else if (!inputMeetingPwd.checked) {
            idProperty.pswd = inputMeetingPwd.text
            inputMeetingPwd.text = ""
        }
    }

    buttonSubmit.onClicked: {
        if (checkMeetingPwd.checked && inputMeetingPwd.text.trim(
                    ).length !== 6) {
            messageTip.warning(qsTr("Please enter 6-digit password"))
            return
        }

        buttonSubmit.enabled = false
        createButton.enabled = false
        joinButton.enabled = false
        if (popupMode === FrontPage.CreateMode) {
            statisticsManager.meetingStatistics("meeting_create", "meeting")
            meetingManager.invokeStart(
                        checkUsePersonalId.checked ? meetingManager.personalMeetingId : "",
                        authManager.appUserNick, inputMeetingPwd.text,
                        checkOpenMicrophone.checked, checkOpenCamera.checked,
                        meetingManager.isSupportRecord)
        } else {
            statisticsManager.meetingStatistics("meeting_join", "meeting")
            meetingManager.invokeJoin(textMeetingId.text.split("-").join("").split(" ").join(""),
                                      authManager.appUserNick,
                                      checkOpenMicrophone.checked,
                                      checkOpenCamera.checked)
        }
    }

    btnScheduleMeeting.onClicked: {
        const screenTmp = mainWindow.screen
        idScheduleMeeting.screen = screenTmp
        idScheduleMeeting.show()
        idScheduleMeeting.x = (screenTmp.width - idScheduleMeeting.width) / 2 + screenTmp.virtualX
        idScheduleMeeting.y = (screenTmp.height - idScheduleMeeting.height) / 2 + screenTmp.virtualY
    }

    appTipArea.onSigContentClicked: {
        function confirm() {//hasReadSafeTip = true
        }

        function cancel() {//do nonthing
        }

        if (appTipArea.type == 1) {
            var obj = configManager.getSafeTipContent()
            DialogManager.dynamicDialog(obj.title, obj.content, confirm, cancel,
                                        mainWindow, obj.okBtnLabel, "", false)
        } else if (appTipArea.type == 2) {
            Qt.openUrlExternally(appTipArea.url)
        }
    }

    appTipArea.onSigCloseClicked: {
        hasReadSafeTip = true
    }

    Connections {
        target: configManager
        onNeedSafeTipChanged: {
            initSaveTip()
        }
    }

    Connections {
        target: caption
        onAvatarClicked: {
            const popupPosition = caption.avatar.mapToGlobal(
                                    -profile.width + caption.avatar.width + 20 /* shadow size */
                                    , caption.avatar.height + 8)
            profile.x = popupPosition.x
            profile.y = popupPosition.y
            profile.show()
        }
        onScheduleClicked: {
            btnScheduleMeeting.clicked()
        }
        onHistoryClicked: {
            const screenTmp = mainWindow.screen
            idHistoryMeeting.screen = screenTmp
            idHistoryMeeting.show()
            idHistoryMeeting.x = (screenTmp.width - idHistoryMeeting.width) / 2 + screenTmp.virtualX
            idHistoryMeeting.y = (screenTmp.height - idHistoryMeeting.height) / 2 + screenTmp.virtualY
        }
    }

    Connections {
        target: authManager
        onLoggedOut: {
            if (needsLogout) {
                console.info('Logout from application server successful', cleanup)
                meetingManager.logout(cleanup)
            }
            profile.closeAllProfileDialog()
            if (customDialog.visible)
                customDialog.close()
            globalSettings.setValue('localUserId', '')
            globalSettings.setValue('localUserToken', '')
        }
        onError: {
            switch (resCode) {
            case 1005:
                message.error(result.msg)
                authManager.logout()
                break
            case 2002:
                break
            default:
                message.error(result.msg)
                break
            }
            buttonSubmit.enabled = Qt.binding(function () {
                return popupMode === FrontPage.JoinMode ? textMeetingId.length >= 1 : true
            })
        }
    }

    Connections {
        target: clientUpdater
        onCheckUpdateSignal: {
            console.info(updateIgnore, resultCode, resultType,
                         JSON.stringify(response))
            if(resultType !== 5) {
                const inviteMeetingId = meetingManager.getInviteMeetingId()
                if(inviteMeetingId !== '') {
                    meetingManager.invokeJoin(inviteMeetingId, authManager.appUserNick, false, false)
                }
            }

            if (0 !== updateIgnore
                    && updateIgnore <= clientUpdater.getLatestVersion())
                return
            if (resultCode !== 200)
                return
            if (resultType === 4 || resultType === 5) {
                const popup = Qt.createComponent(
                                "qrc:/qml/components/CheckUpdate.qml").createObject(
                                mainWindow, {
                                    "updateType": resultType,
                                    "clientUpdateInfo": response
                                })
                popup.open()
            }
        }
    }

    Connections {
        target: meetingManager
        onFeedback: {
            feedback.showOptions = false
            feedback.showFeedbackWindow(false)
        }
        onGotAccountInfo: {
            if (updateEnable) {
                updateEnable = false
                clientUpdater.checkUpdate()
            }
            if (meetingManager.displayName !== '' && !authManager.autoRegistered)
                authManager.appUserNick = meetingManager.displayName
            meetingManager.getMeetingList()
//            authManager.getAccountApps(meetingManager.neAppKey,
//                                       meetingManager.neAccountId,
//                                       meetingManager.neAccountToken)
//            authManager.getAccountAppInfo(meetingManager.neAppKey,
//                                          meetingManager.neAccountId,
//                                          meetingManager.neAccountToken)
        }
        onLogoutSignal: {
            if (errorCode === 0) {
                updateEnable = true
                pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/HomePage.qml'))
            } else {
                message.error(qsTr('Failed to logout from apaas server'))
            }

            isAgreePrivacyPolicy = false
        }
        onAuthInfoExpired: {
            if (!mainWindow.visible) {
                showMainWindowTimer.start()
            }
            if (!authManager.resetPasswordFlag) {
                message.warning(
                            qsTr('Auth information has expired, please relogin.'))
                authManager.logout(false)
                updateEnable = true
                pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/HomePage.qml'))
            } else {
                authManager.resetPasswordFlag = false
            }
        }
        onKickOut: {
            if (!mainWindow.visible) {
                showMainWindowTimer.start()
            }
            if (!authManager.resetPasswordFlag) {
                message.warning(
                            qsTr('You have been kickout by muti client.'))
                authManager.logout(false)
                updateEnable = true
                pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/HomePage.qml'))
            } else {
                authManager.resetPasswordFlag = false
            }
        }
        onStartSignal: {
            switch (errorCode) {
            case MeetingStatus.ERROR_CODE_SUCCESS:
                popupWindow.close()
                mainWindow.hide()
                meetingManager.addHistoryInfo();
                break
            case MeetingStatus.MEETING_ERROR_FAILED_MEETING_ALREADY_EXIST:
                customDialog.text = qsTr('Join Meeting')
                customDialog.description = qsTr(
                            'The meeting is still in progress. Do you want to join directly?')
                customDialog.confirm.connect(joinmeeting)
                customDialog.open()
                break
            case MeetingStatus.ERROR_CODE_FAILED:
                if(popupWindow.visible) {
                    messageTip.error(
                                errorMessage !== '' ? errorMessage : qsTr(
                                                          'Failed to start meeting'))
                } else {
                    message.error(
                                errorMessage !== '' ? errorMessage : qsTr(
                                                          'Failed to start meeting'))
                }

                break
            default:
                messageTip.error(errorMessage)
                break
            }
            buttonSubmit.enabled = Qt.binding(function () {
                return popupMode === FrontPage.JoinMode ? textMeetingId.length >= 1 : true
            })
            createButton.enabled = true
            joinButton.enabled = true
        }
        onJoinSignal: {
            switch (errorCode) {
            case MeetingStatus.ERROR_CODE_SUCCESS:
                popupWindow.close()
                mainWindow.hide()
                meetingManager.addHistoryInfo();
                break
            case MeetingStatus.ERROR_CODE_FAILED:
            default:
                if(popupWindow.visible) {
                    messageTip.error(
                                errorMessage !== '' ? errorMessage : qsTr(
                                                          'Failed to join meeting'))
                } else {
                    message.error(
                                errorMessage !== '' ? errorMessage : qsTr(
                                                          'Failed to join meeting'))
                }
                if(errorCode !== MeetingStatus.MEETING_ERROR_ALREADY_INMEETING) {
                    mainWindow.raiseOnTop()
                }
                break
            }
            buttonSubmit.enabled = Qt.binding(function () {
                return popupMode === FrontPage.JoinMode ? textMeetingId.length >= 1 : true
            })
            createButton.enabled = true
            joinButton.enabled = true
        }
        onInviteFailed: {
            if(inSameMeeting) {
                GlobalToast.displayText(qsTr('you are already in the meeting'))
            } else {
                GlobalToast.displayText(qsTr('You are already in the meeting, please exit the current meeting and try again'))
            }
        }
        onMeetingStatusChanged: {
            switch (meetingStatus) {
            case RunningStatus.MEETING_STATUS_CONNECTING:
                // mainWindow.hide()
                break
            case RunningStatus.MEETING_STATUS_DISCONNECTING:
                if (extCode === RunningStatus.MEETING_DISCONNECTING_REMOVED_BY_HOST)
                    toast.show(qsTr('You have been removed from meeting by host'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_CLOSED_BY_HOST)
                    toast.show(qsTr('This meeting has been ended'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SERVER)
                    toast.show(qsTr('You have been discconected from server'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_AUTH_INFO_EXPIRED)
                    console.info('Disconnected by auth info expored.')
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE) {
                    toast.show(qsTr('You have been kickout by other client'))
                    authManager.logout()
                } else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_ROOMNOTEXIST)
                    toast.show(qsTr('The meeting does not exist'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SYNCDATAERROR)
                    toast.show(qsTr('Failed to synchronize meeting information'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_RTCINITERROR)
                    toast.show(qsTr('The RTC module fails to be initialized'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_JOINCHANNELERROR)
                    toast.show(qsTr('Failed to join the channel of RTC'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_TIMEOUT)
                    toast.show(qsTr('Meeting timeout'))
                createButton.enabled = true
                joinButton.enabled = true
                showMainWindowTimer.start()
                showFeedbackTimer.start()
                break
            case RunningStatus.MEETING_STATUS_WAITING:
                if (extCode === RunningStatus.MEETING_WAITING_VERIFY_PASSWORD) {
                    mainWindow.hide()
                }
            }
        }
        onGetScheduledMeetingList: {
            listModel.clear()
            let datetimeFlag = 0
            meetingList.sort(sortByMultiFields)
            for (var i = 0; i < meetingList.length; i++) {
                const meeting = meetingList[i]
                const dayBegin = new Date(new Date(meeting.startTime).setHours(
                                              0, 0, 0, 0))
                const dayEnd = new Date(new Date(meeting.startTime).setHours(
                                            23, 59, 59, 999))
                if (dayBegin.getTime() > datetimeFlag) {
                    Object.assign(meeting, {
                                      "showDatetime": true
                                  })
                    listModel.append(meeting)
                    datetimeFlag = dayEnd.getTime()
                } else {
                    Object.assign(meeting, {
                                      "showDatetime": false
                                  })
                    listModel.append(meeting)
                }
            }
        }
        onCancelSignal: {
            if (idScheduleDetailsWindow.visible)
                return
            if (0 !== errorCode) {
                message.error(errorMessage)
            }
        }
        onResumeMeetingSignal: {
            idProperty.resumemeetingId = meetingId
            customDialog.text = qsTr('Join Meeting')
            customDialog.description = qsTr(
                        'It was detected that you exited abnormally last time, do you want to resume the meeting?')
            customDialog.confirm.connect(resumemeeting)
            customDialog.open()
        }
    }

    Timer {
        id: showFeedbackTimer
        repeat: false
        interval: 500
        onTriggered: {
            feedback.showOptions = true
            feedback.showFeedbackWindow()
        }
    }

    Timer {
        id: showMainWindowTimer
        repeat: false
        interval: 1000
        onTriggered: {
            mainWindow.showNormal()
            mainWindow.raiseOnTop()
        }
    }

    QtObject {
        id: idProperty
        property string pswd: ""
        property string resumemeetingId: ""
    }

    function sortByMultiFields(src, dest) {
        if (src.startTime === dest.startTime) {
            return src.createTime - dest.createTime
        }
        return src.startTime > dest.startTime ? 1 : -1
    }

    function sortBy(source, dest) {
        if (source.startTime > dest.startTime) {
            return 1
        } else if (source.startTime < dest.startTime) {
            return -1
        } else {
            return 0
        }
    }

    function joinmeeting() {
        meetingManager.invokeJoin(meetingManager.personalMeetingId,
                                  authManager.appUserNick,
                                  checkOpenMicrophone.checked,
                                  checkOpenCamera.checked)

        customDialog.confirm.disconnect(joinmeeting)
    }

    function resumemeeting() {
        let micStatus = false
        let cameraStatus = false
        if (Qt.platform.os === 'windows') {
            micStatus = globalSettings.value(
                        'localMicStatusEx') === 'true'
            cameraStatus = globalSettings.value(
                        'localCameraStatusEx') === 'true'
        } else {
            micStatus = globalSettings.value(
                        'localMicStatusEx')
            cameraStatus = globalSettings.value(
                        'localCameraStatusEx')
        }
        meetingManager.invokeJoin(idProperty.resumemeetingId,
                                  authManager.appUserNick,
                                  micStatus, cameraStatus)

        customDialog.confirm.disconnect(resumemeeting)
    }

    function initSaveTip() {
        var visible = (configManager.needSafeTip && !hasReadSafeTip)
        appTipArea.visible = visible
        if (visible) {
            var obj = configManager.getSafeTipContent()
            appTipArea.description = obj.content
            appTipArea.type = obj.type
            appTipArea.url = obj.url
        }
    }
}
