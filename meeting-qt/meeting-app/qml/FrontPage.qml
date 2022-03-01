import QtQuick 2.15
import QtQuick.Window 2.14
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.RunningStatus 1.0
import "utils/dialogManager.js" as DialogManager

FrontPageForm {
    Component.onCompleted: {
        const sharedMeetingId = globalSettings.value('sharedMeetingId', '')
        if (sharedMeetingId !== '') {
            textMeetingId.text = sharedMeetingId.substring(0, 3) + "-" +
                    sharedMeetingId.substring(3, 6) + "-" +
                    sharedMeetingId.substring(6)

            popupMode = FrontPage.JoinMode
            popupWindow.open()
            globalSettings.setValue('sharedMeetingId', '')
        }
        meetingManager.getAccountInfo()
        meetingManager.getIsSupportRecord()

        if(!hasReadSafeTip) {
            if(configManager.needSafeTip) {
                initSaveTip()
            } else {
                configManager.requestServerAppConfigs()
            }
        }

        caption.schedule.visible = Qt.binding(function() { return scheduleList.count > 0 })
    }

    Component.onDestruction: {
        caption.schedule.visible = false
    }

    popupWindow.onOpened: {
        globalSettings.sync()
        const cameraStatus = globalSettings.value("localCameraStatusEx")
        const microphoneStatus = globalSettings.value("localMicStatusEx")
        checkOpenCamera.checked = cameraStatus === undefined ? false : cameraStatus === true || cameraStatus === "true";
        checkOpenMicrophone.checked = microphoneStatus === undefined ? false : microphoneStatus === true || microphoneStatus === "true";
    }

    popupWindow.onClosed: {
        checkUsePersonalId.checked = false
    }

    createButton.onClicked: {
        popupMode = FrontPage.CreateMode
        buttonSubmit.text = qsTr("Create")
        popupWindow.open()
    }

    joinButton.onClicked: {
        popupMode = FrontPage.JoinMode
        textMeetingId.text = ""
        buttonSubmit.text = qsTr("Join")
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
        regExp: /^[0-9-]{15}$/
    }

    infoArea.onEntered: {
        tooltips.x = 270
        tooltips.y = 150
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
        statisticsManager.meetingStatistics("use_personal_id", "meeting", { value: checkUsePersonalId.checked ? 1 : 0 })
    }

    checkOpenCamera.onToggled: {
        statisticsManager.meetingStatistics("open_camera", "meeting", { value: checkOpenCamera.checked ? 1 : 0 })
    }

    checkOpenMicrophone.onToggled: {
        statisticsManager.meetingStatistics("open_micro", "meeting", { value: checkOpenMicrophone.checked ? 1 : 0 })
    }

    buttonSubmit.onClicked: {
        buttonSubmit.enabled = false
        createButton.enabled = false
        joinButton.enabled = false
        if (popupMode === FrontPage.CreateMode) {
            statisticsManager.meetingStatistics("meeting_create", "meeting")
            meetingManager.invokeStart(checkUsePersonalId.checked ? meetingManager.personalMeetingId : "",
                                       authManager.appUserNick,
                                       checkOpenMicrophone.checked,
                                       checkOpenCamera.checked, meetingManager.isSupportRecord)
        } else {
            statisticsManager.meetingStatistics("meeting_join", "meeting")
            meetingManager.invokeJoin(textMeetingId.text.split("-").join(""),
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
        function confirm() {
            //hasReadSafeTip = true
        }

        function cancel() {
            //do nonthing
        }

        var obj = configManager.getSafeTipContent()
        DialogManager.dynamicDialog(obj.title, obj.content, confirm, cancel, mainWindow, obj.okBtnLabel, "", false)
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
            const popupPosition = caption.avatar.mapToGlobal(-profile.width + caption.avatar.width + 20 /* shadow size */, caption.avatar.height + 8)
            profile.x = popupPosition.x
            profile.y = popupPosition.y
            profile.show()
        }
        onScheduleClicked: {
            btnScheduleMeeting.clicked()
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
            if (customDialog.visible) customDialog.close()
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
            buttonSubmit.enabled = Qt.binding(function() {
                return popupMode === FrontPage.JoinMode ? textMeetingId.length >= 1 : true
            })
        }
    }

    Connections {
        target: clientUpdater
        onCheckUpdateSignal: {
            console.info(updateIgnore, resultCode, resultType, JSON.stringify(response))
            if (0 !== updateIgnore && updateIgnore <= clientUpdater.getLatestVersion()) return
            if (resultCode !== 200) return
            if (resultType === 4 || resultType === 5) {
                const popup = Qt.createComponent("qrc:/qml/components/CheckUpdate.qml").createObject(mainWindow, {
                                                                                     updateType: resultType,
                                                                                     clientUpdateInfo: response
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
            if (meetingManager.displayName !== '')
                authManager.appUserNick = meetingManager.displayName
            meetingManager.getMeetingList()
            authManager.getAccountApps(meetingManager.neAppKey,
                                       meetingManager.neAccountId,
                                       meetingManager.neAccountToken)
            authManager.getAccountAppInfo(meetingManager.neAppKey,
                                          meetingManager.neAccountId,
                                          meetingManager.neAccountToken)
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
                mainWindow.showNormal()
                mainWindow.raiseOnTop()
            }
            if (!authManager.resetPasswordFlag) {
                message.warning(qsTr('Auth information has expired, please relogin.'))
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
                break
            case MeetingStatus.MEETING_ERROR_FAILED_MEETING_ALREADY_EXIST:
                customDialog.text = qsTr('Join Meeting')
                customDialog.description = qsTr('The meeting is still in progress. Do you want to join directly?')
                customDialog.confirm.connect(joinmeeting)
                customDialog.open()
                break
            case MeetingStatus.ERROR_CODE_FAILED:
                message.error(errorMessage !== '' ? errorMessage : qsTr('Failed to start meeting'))
                break
            default:
                message.error(errorMessage)
                break
            }
            buttonSubmit.enabled = Qt.binding(function() {
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
                break
            case MeetingStatus.ERROR_CODE_FAILED:
            default:
                message.error(errorMessage !== '' ? errorMessage : qsTr('Failed to join meeting'))
                mainWindow.raiseOnTop()
                break
            }
            buttonSubmit.enabled = Qt.binding(function() {
                return popupMode === FrontPage.JoinMode ? textMeetingId.length >= 1 : true
            })
            createButton.enabled = true
            joinButton.enabled = true
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
                }
                createButton.enabled = true
                joinButton.enabled = true
                mainWindow.showNormal()
                mainWindow.raiseOnTop()
                feedback.showOptions = true
                feedback.showFeedbackWindow()
                break
            case RunningStatus.MEETING_STATUS_WAITING:
                if (extCode === RunningStatus.MEETING_WAITING_VERIFY_PASSWORD) {
                    mainWindow.hide()
                }
            }
        }
        onGetScheduledMeetingList: {
            listModel.clear()
            let datetimeFlag = 0;
            meetingList.sort(sortByMultiFields)
            for (let i = 0; i < meetingList.length; i++) {
                const meeting = meetingList[i]
                const dayBegin = new Date(new Date(meeting.startTime).setHours(0,0,0,0))
                const dayEnd = new Date(new Date(meeting.startTime).setHours(23,59,59,999))
                if (dayBegin.getTime() > datetimeFlag) {
                    Object.assign(meeting, { showDatetime: true })
                    listModel.append(meeting)
                    datetimeFlag = dayEnd.getTime()
                } else {
                    Object.assign(meeting, { showDatetime: false })
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

    function initSaveTip() {
        appTipArea.visible = configManager.needSafeTip && !hasReadSafeTip
        if(appTipArea.visible) {
            var obj = configManager.getSafeTipContent()
            appTipArea.description = obj.content
        }
    }
}
