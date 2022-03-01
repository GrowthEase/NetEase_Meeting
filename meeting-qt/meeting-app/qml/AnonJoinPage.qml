import QtQuick 2.15
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.RunningStatus 1.0

AnonJoinPageForm {
    Component.onCompleted: {
        const sharedMeetingId = globalSettings.value('sharedMeetingId', '')
        if (sharedMeetingId !== '') {
            textMeetingId.text = sharedMeetingId.substring(0, 3) + "-" +
                    sharedMeetingId.substring(3, 6) + "-" +
                    sharedMeetingId.substring(6)
            globalSettings.setValue('sharedMeetingId', '')
        }

        checkCamera.checked = Qt.binding(function(){
            globalSettings.sync();
            const cameraStatus = globalSettings.value("localCameraStatusEx");
            return (cameraStatus === undefined) ? false : cameraStatus === true || cameraStatus === "true";
        })

        checkMicrophone.checked = Qt.binding(function(){
            globalSettings.sync();
            const micStatus = globalSettings.value("localMicStatusEx");
            return (micStatus === undefined) ? false : micStatus === true || micStatus === "true";
        })
    }

    header.onPrevious: {
        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/HomePage.qml"))
    }

    buttonJoin.onClicked: {
        meetingManager.invokeJoin(textMeetingId.text.split("-").join(""),
                                  textNickname.text,
                                  checkMicrophone.checked,
                                  checkCamera.checked,
                                  true)
        buttonJoin.enabled = false
        header.enabled = false
    }

    checkCamera.onToggled: {
        statisticsManager.meetingStatistics("open_camera", "meeting", { value: checkCamera.checked ? 1 : 0 })
    }

    checkMicrophone.onToggled: {
        statisticsManager.meetingStatistics("open_micro", "meeting", { value: checkMicrophone.checked ? 1 : 0 })
    }

    textMeetingId.validator: RegExpValidator {
        regExp: /^[0-9-]{15}$/
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

    textNickname.validator: RegExpValidator {
        regExp: /\w{20}/
    }

    textNickname.onTextChanged: {
        const currentText = textNickname.text

        if (currentText === lastNicknameText)
            return

        if (getByteLength(currentText) > 20) {
            textNickname.text = lastNicknameText
        } else {
            lastNicknameText = currentText
        }
    }

    Connections {
        target: authManager
        onError: {
            buttonJoin.enabled = Qt.binding(function () {
                return textMeetingId.length >= 11 && textNickname.length > 0
            })
            message.error(result.msg)
        }
    }

    Connections {
        target: meetingManager
        onJoinSignal: {
            console.info("Anon join meeting callback, error code:", errorCode, ", error message:", errorMessage)
            switch (errorCode) {
            case MeetingStatus.ERROR_CODE_SUCCESS:
                authManager.appUserNick = textNickname.text
                mainWindow.hide()
                break
            case MeetingStatus.ERROR_CODE_FAILED:
            default:
                message.error(errorMessage !== '' ? errorMessage : qsTr('Failed to join meeting'))
                mainWindow.raiseOnTop()
                break
            }
            buttonJoin.enabled = Qt.binding(function () {
                return textMeetingId.length >= 1 && textNickname.length > 0
            })
            header.enabled = true
        }
        onMeetingStatusChanged: {
            console.info('Meeting status changed, meeting status:', meetingStatus)
            switch (meetingStatus) {
            case RunningStatus.MEETING_STATUS_CONNECTING:
                // mainWindow.hide()
                break;
            case RunningStatus.MEETING_STATUS_DISCONNECTING:
                if (extCode === RunningStatus.MEETING_DISCONNECTING_CLOSED_BY_HOST)
                    toast.show(qsTr('This meeting has been ended'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_REMOVED_BY_HOST)
                    toast.show(qsTr('You have been removed from meeting by host'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_BY_SERVER)
                    toast.show(qsTr('You have been discconected from server'))
                else if (extCode === RunningStatus.MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE)
                    toast.show(qsTr('You have been kickout by other client'))
                mainWindow.raiseOnTop()
                pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/HomePage.qml"))
                break
            case RunningStatus.MEETING_STATUS_WAITING:
                if (extCode === RunningStatus.MEETING_WAITING_VERIFY_PASSWORD) {
                    mainWindow.hide()
                }
            }
        }
        onFeedback: {
            feedback.showOptions = false
            feedback.showFeedbackWindow(false)
        }
    }
}
