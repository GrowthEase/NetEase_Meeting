import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0
import NetEase.Meeting.MeetingStatus 1.0

Rectangle {
    Component.onCompleted: {
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

    ColumnLayout {
        anchors.centerIn: parent
        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 58
            Layout.preferredWidth: 220
            source: 'qrc:/images/logo.png'
        }
        RowLayout {
            TextField {
                implicitWidth: 300
                id: textAppKey
                placeholderText: qsTr('Your application key')
                text: !anon.checked ? setting.value('sampleAppkey', '') : setting.value('sampleAnonAppkey', '')
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
                id: rename
                visible: anon.checked
                text: qsTr('Rename')
                Layout.topMargin: 20
            }
        }
        RowLayout {
            TextField {
                id: textAccountId
                placeholderText: !anon.checked ? qsTr('Your account ID') : qsTr('Meeting ID')
                text: !anon.checked ? setting.value('sampleAccoundId', '') : setting.value('sampleAnonMeetingId', '')
                selectByMouse: true
                Layout.fillWidth: true
            }
            TextField {
                id: textKeepAliveInterval
                placeholderText: qsTr('KeepAliveInterval')
                selectByMouse: true
            }
        }
        TextField {
            id: textPassword
            placeholderText: !anon.checked ? qsTr('Your password') : qsTr('Password')
            text: !anon.checked ? setting.value('sampleAccoundToken', '') : setting.value('sampleAnonMeetingPwd', '')
            selectByMouse: true
            Layout.fillWidth: true
        }
        RowLayout {
            TextField {
                id: logPath
                placeholderText:qsTr('SDK Log path')
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
                checked: true
                visible: Qt.platform.os === 'windows'
            }
        }
        Button {
            id: btnSubmit
            highlighted: true
            text: !anon.checked ? qsTr('Login') : qsTr('Join')
            Layout.fillWidth: true
            enabled: textAppKey.text.length > 0 && (!anon.checked ? (textAccountId.text.length > 0 && textPassword.text.length > 0) : textAccountId.text.length > 0)
            onClicked: {
                enabled = false
                loginTime.start()
            }
        }
    }

    Timer {
        id: loginTime
        repeat: false
        interval: 200
        onTriggered: {
            if (!anon.checked) {
                setting.setValue('sampleAppkey', textAppKey.text)
                setting.setValue('sampleAccoundId', textAccountId.text)
                setting.setValue('sampleAccoundToken', textPassword.text)
                meetingManager.initializeParam(logPath.text, logLevel.currentIndex, runAdmin.checked)
                meetingManager.login(textAppKey.text,
                                     textAccountId.text,
                                     textPassword.text,
                                     textKeepAliveInterval.text.toString().trim().length === 0 ? 13566 : parseInt(textKeepAliveInterval.text))
            } else {
                setting.setValue('sampleAnonAppkey', textAppKey.text)
                setting.setValue('sampleAnonMeetingId', textAccountId.text)
                setting.setValue('sampleAnonMeetingPwd', textPassword.text)
                meetingManager.initializeParam(logPath.text, logLevel.currentIndex, runAdmin.checked)
                meetingManager.initialize(textAppKey.text, textKeepAliveInterval.text.toString().trim().length === 0 ? 13566 : parseInt(textKeepAliveInterval.text))
                meetingManager.invokeJoin(textAccountId.text, 'nickname', false, false, true, true, textPassword.text, rename.checked)
            }
        }
    }
    Connections {
        target: meetingManager
        onLoginSignal: {
            btnSubmit.enabled = Qt.binding(function() { return textAppKey.text.length > 0 && (!anon.checked ? (textAccountId.text.length > 0 && textPassword.text.length > 0) : textAccountId.text.length > 0) })
            if (errorCode === MeetingStatus.ERROR_CODE_SUCCESS)
                pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/Front.qml'))
            else
                toast.show(errorCode + '(' + errorMessage + ')')
        }

        onJoinSignal: {
            btnSubmit.enabled = Qt.binding(function() { return textAppKey.text.length > 0 && (!anon.checked ? (textAccountId.text.length > 0 && textPassword.text.length > 0) : textAccountId.text.length > 0) })
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
    }

    Connections {
        target: meetingManager
        ignoreUnknownSignals: true
        function onInitializeSignal(errorCode, errorMessage) {
            if (MeetingStatus.ERROR_CODE_SUCCESS !== errorCode) {
                toast.show(errorCode + '(' + errorMessage + ')')
                btnSubmit.enabled = Qt.binding(function() { return textAppKey.text.length > 0 && (!anon.checked ? (textAccountId.text.length > 0 && textPassword.text.length > 0) : textAccountId.text.length > 0) })
            }
        }
    }
}
