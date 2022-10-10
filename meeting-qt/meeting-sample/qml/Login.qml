import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.RunningStatus 1.0

Rectangle {
    Component.onCompleted: {
        mainWindow.showNormal()
    }

    Settings {
        id: setting
        property string sampleAppkey
        property string sampleAccoundId
        property string sampleAccoundToken

        property string sampleAnonAppkey
        property string sampleAnonMeetingId
        property string sampleAnonMeetingPwd
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

    ColumnLayout {
        anchors.centerIn: parent
        width: 600
        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 58
            Layout.preferredWidth: 220
            source: 'qrc:/images/logo.png'
            mipmap: true
        }
        RowLayout {
            TextField {
                implicitWidth: 300
                id: textAppKey
                placeholderText: qsTr('Your application key')
                text: !anon.checked ? (!passwordLogin.checked ? setting.value('sampleAppkey', '') : setting.value('samplePasswordAppkey', '')) : setting.value(
                                          'sampleAnonAppkey', '')
                selectByMouse: true
                Layout.fillWidth: true
                Layout.topMargin: 20
            }
            CheckBox {
                id: anon
                text: qsTr('Anon')
                Layout.topMargin: 20
            }

            CheckBox {
                id: passwordLogin
                text: qsTr('PasswordLogin')
                Layout.topMargin: 20
                visible: !anon.checked
                checked: false
            }

            CheckBox {
                id: rename
                visible: anon.checked
                text: qsTr('Rename')
                Layout.topMargin: 20
            }
        }
        RowLayout {
            TextField {
                id: textAccountId
                placeholderText: !anon.checked ? (!passwordLogin.checked ? qsTr('Your account ID') : qsTr('Your userName')) : qsTr(
                                                     'Meeting ID')
                text: !anon.checked ? (!passwordLogin.checked ? setting.value('sampleAccoundId', '') : setting.value('sampleUserName', '')) : setting.value(
                                          'sampleAnonMeetingId', '')
                selectByMouse: true
                Layout.fillWidth: true
            }
            TextField {
                id: textKeepAliveInterval
                Layout.preferredWidth: 150
                placeholderText: qsTr('KeepAliveInterval')
                selectByMouse: true
            }
            CheckBox {
                id: softwareRender
                text: qsTr("Software Render")
                visible: Qt.platform.os === 'windows'
                checked: meetingManager.softwareRender
                onClicked: meetingManager.setSoftwareRender(checked)
            }
        }
        RowLayout {
            TextField {
                id: nicknameAnon
                placeholderText: qsTr('nicknameAnon')
                visible: anon.checked
                selectByMouse: true
                Layout.fillWidth: true
            }
            TextField {
                id: textPassword
                placeholderText: !anon.checked ? (!passwordLogin.checked ? qsTr('Your password') : qsTr('Your password') ) : qsTr(
                                                     'Password')
                text: !anon.checked ? (!passwordLogin.checked ? setting.value('sampleAccoundToken', '') : setting.value('samplePassword', '') ): setting.value(
                                          'sampleAnonMeetingPwd', '')
                selectByMouse: true
                Layout.fillWidth: true
            }
            TextField {
                id: textTimeout
                placeholderText: qsTr('enter meeting timeout(ms)')
                text: 45 * 1000
                visible: anon.checked
                selectByMouse: true
                Layout.fillWidth: true
            }
        }

        RowLayout {
            TextField {
                id: textTag
                placeholderText: 'user tag'
                selectByMouse: true
                Layout.fillWidth: true
                visible: anon.checked
            }

            Button {
                id: btnGet
                width: 20
                visible: anon.checked
                highlighted: true
                enabled: true
                Layout.fillWidth: true
                text: qsTr('Get Info')
                onClicked: meetingManager.getMeetingInfo()
            }
        }
        RowLayout {
            TextField {
                id: logPath
                placeholderText: qsTr('SDK Log path')
                selectByMouse: true
                Layout.fillWidth: true
            }
            ComboBox {
                id: logLevel
                model: ["VERBOSE", "DEBUG", "INFO", "WARNING", "ERROR"]
                currentIndex: 2
                Layout.fillWidth: true
            }
            CheckBox {
                id: runAdmin
                text: qsTr("Admin privileges")
                checked: false
                visible: Qt.platform.os === 'windows'
            }
            CheckBox {
                id: privateConfig
                text: qsTr("Private Config")
                checked: false
            }
        }
        RowLayout {
            Button {
                id: btnSubmit
                highlighted: true
                text: !anon.checked ? qsTr('Login') : qsTr('Join')
                Layout.fillWidth: true
                enabled: textAppKey.text.length > 0
                         && (!anon.checked ? (textAccountId.text.length > 0
                                              && textPassword.text.length
                                              > 0) : textAccountId.text.length > 0)
                onClicked: {
                    enabled = false
                    loginTime.start()
                }
            }

            Button {
                id: btnLeave
                highlighted: true
                visible: anon.checked
                text: qsTr('Leave')
                Layout.fillWidth: true
                enabled: false
                onClicked: meetingManager.leaveMeeting(false)
            }

            Button {
                id: btnFinish
                highlighted: true
                visible: anon.checked
                text: qsTr('Finish')
                Layout.fillWidth: true
                enabled: false
                onClicked: meetingManager.leaveMeeting(true)
            }
        }
    }

    Timer {
        id: loginTime
        repeat: false
        interval: 200
        onTriggered: {
            if (!anon.checked) {
                setting.setValue(!passwordLogin.checked ? 'sampleAppkey' : 'samplePasswordAppkey', textAppKey.text)
                setting.setValue(!passwordLogin.checked ? 'sampleAccoundId' : 'sampleUserName', textAccountId.text)
                setting.setValue(!passwordLogin.checked ? 'sampleAccoundToken': 'samplePassword', textPassword.text)
                meetingManager.initializeParam(logPath.text,
                                               logLevel.currentIndex,
                                               runAdmin.checked,
                                               privateConfig.checked)
                if (!passwordLogin.checked) {
                    meetingManager.login(
                            textAppKey.text, textAccountId.text,
                            textPassword.text,
                            textKeepAliveInterval.text.toString().trim().length === 0 ? 13566 : parseInt(textKeepAliveInterval.text))
                } else {
                    meetingManager.loginByUsernamePassword(
                            textAppKey.text, textAccountId.text,
                            textPassword.text,
                            textKeepAliveInterval.text.toString().trim().length === 0 ? 13566 : parseInt(textKeepAliveInterval.text))
                }
            } else {
                setting.setValue('sampleAnonAppkey', textAppKey.text)
                setting.setValue('sampleAnonMeetingId', textAccountId.text)
                setting.setValue('sampleAnonMeetingPwd', textPassword.text)
                meetingManager.initializeParam(logPath.text,
                                               logLevel.currentIndex,
                                               runAdmin.checked,
                                               privateConfig.checked)
                meetingManager.initialize(
                            textAppKey.text,
                            textKeepAliveInterval.text.toString().trim(
                                ).length === 0 ? 13566 : parseInt(
                                                     textKeepAliveInterval.text))

                var meetinginfoObj = {}
                meetinginfoObj["anonymous"] = true
                meetinginfoObj["meetingId"] = textAccountId.text
                meetinginfoObj["nickname"] = nicknameAnon.text
                meetinginfoObj["tag"] = textTag.text
                meetinginfoObj["timeOut"] = textTimeout.text
                meetinginfoObj["audio"] = false
                meetinginfoObj["video"] = false
                meetinginfoObj["enableChatroom"] = true
                meetinginfoObj["enableInvitation"] = true
                meetinginfoObj["enableScreenShare"] = true
                meetinginfoObj["enableView"] = true
                meetinginfoObj["autoOpenWhiteboard"] = autoOpenWhiteboard.checked
                meetinginfoObj["password"] = textpassword.text
                meetinginfoObj["rename"] = rename.checked
                meetinginfoObj["displayOption"] = 0
                meetinginfoObj["enableRecord"] = true
                meetinginfoObj["openWhiteboard"] = false
                meetinginfoObj["audioAINS"] = true
                meetinginfoObj["sip"] = true
                meetinginfoObj["showMemberTag"] = false
                meetinginfoObj["enableMuteAllVideo"] = false
                meetinginfoObj["enableMuteAllAudio"] = true
                meetinginfoObj["showRemainingTip"] = false
                meetinginfoObj["enableFileMessage"] = false
                meetinginfoObj["enableImageMessage"] = false

                meetingManager.invokeJoin(meetinginfoObj)
            }
        }
    }
    Connections {
        target: meetingManager
        onLoginSignal: {
            btnSubmit.enabled = Qt.binding(function () {
                return textAppKey.text.length > 0
                        && (!anon.checked ? (textAccountId.text.length > 0
                                             && textPassword.text.length
                                             > 0) : textAccountId.text.length > 0)
            })
            if (errorCode === MeetingStatus.ERROR_CODE_SUCCESS)
                pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/Front.qml'))
            else
                toast.show(errorCode + '(' + errorMessage + ')')
        }

        onJoinSignal: {
            btnSubmit.enabled = Qt.binding(function () {
                return textAppKey.text.length > 0
                        && (!anon.checked ? (textAccountId.text.length > 0
                                             && textPassword.text.length
                                             > 0) : textAccountId.text.length > 0)
            })
            switch (errorCode) {
            case MeetingStatus.ERROR_CODE_SUCCESS:
                toast.show(qsTr("Join successfull"))
                btnLeave.enabled = true
                btnFinish.enabled = true
                btnSubmit.enabled = false
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
                if(anon.checked) {
                    meetingManager.unInitialize()
                }
            }
        }

        onLeaveSignal: {
            toast.show('Leave meeting signal: ' + errorCode + ", " + errorMessage)
        }
        onFinishSignal: {
            toast.show('Finsh meeting signal: ' + errorCode + ", " + errorMessage)
        }
        onMeetingStatusChanged: {
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

                btnSubmit.enabled = true
                btnLeave.enabled = false
                btnFinish.enabled = false
                if(anon.checked) {
                    meetingManager.unInitialize()
                }
                break
            }
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
            for (var i = 0; i < meetingUserList.length; i++) {
                const user = meetingUserList[i]
                listUserModel.append(user)
                console.log("userid", user.userId)
                console.log("userName", user.userName)
                console.log("tag", user.tag)
            }

            meetinginfo.open()
        }
    }

    Connections {
        target: meetingManager
        ignoreUnknownSignals: true
        function onInitializeSignal(errorCode, errorMessage) {
            if (MeetingStatus.ERROR_CODE_SUCCESS !== errorCode) {
                toast.show(errorCode + '(' + errorMessage + ')')
                btnSubmit.enabled = Qt.binding(function () {
                    return textAppKey.text.length > 0
                            && (!anon.checked ? (textAccountId.text.length > 0
                                                 && textPassword.text.length
                                                 > 0) : textAccountId.text.length > 0)
                })
            }
        }
    }
}
