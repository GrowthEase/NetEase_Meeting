import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12

import "../components"
import '../utils/dialogManager.js' as DialogManager

Window {
    id: idScheduleDetailsWindow

    property int uniqueMeetingId
    property int meetingStatus
    property string meetingId
    property string meetingPassword
    property string meetingTopic
    property var startTime
    property var endTime
    property bool attendeeAudioOff
    property bool liveEanble: false
    property bool liveAccess: false
    property bool recordEnable: false
    property string liveUrl:""
    property int detailsHeight: Qt.platform.os === 'windows' ? 626 + 20 : 646   // 根据视觉调整
    property int editHeight: Qt.platform.os === 'windows' ? 644 + 20 : 644      // 根据视觉调整
    property alias title: idDragArea.title
    width: Qt.platform.os === 'windows' ? 400 + 20 : 400                        // 根据视觉调整

    color: "#00000000"
    Material.theme: Material.Light
    flags: Qt.Window | Qt.FramelessWindowHint  | Qt.WindowStaysOnTopHint

    signal joinMeeting()

    onVisibleChanged: {
        if (visible) {
            init()
        } else {
             detailsHeight =  Qt.platform.os === 'windows' ? 646 + 20 : 646
             editHeight= Qt.platform.os === 'windows' ? 644 + 20 : 644
        }
    }

    signal closeBtnClicked()
    function close() {
        idDragArea.close()
    }

    MessageManager {
        id: idMessage
    }

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        color: "#3217171A"
        spread: 0
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    function init () {
        title = qsTr("Meeting Details")

        var isSupportLive = meetingManager.getIsSupportLive()
        meetingManager.getIsSupportRecord()
        if(isSupportLive){
            detailsHeight += 30

            if(liveEanble){
                detailsHeight += 40
            }

            if(Qt.platform.os === 'windows'){
                editHeight -= 30;
            }

            colLive.visible = true;
        }else{
            colLive.visible = false;
        }

        idScheduleDetailsWindow.height = detailsHeight
        idProperty.bEdit = false
        idSubjectText.text = meetingTopic

        // 初始化日期
        var datetimeTmp = new Date(startTime)
        idStartDate.currentDate = datetimeTmp
        idComBoxStartTime.currentIndex = -1
        getListStartTime()

        datetimeTmp = new Date(endTime)
        idComBoxEndTime.currentIndex = -1
        idEndDate.currentDate = datetimeTmp
        idEndDate.minimumDate = idStartDate.currentDate


        // 初始化设置密码
        if (meetingPassword.length === 0 && idMeetingPwdCheck.checked) {
            idMeetingPwdCheck.toggle()
        }else if (meetingPassword.length !== 0 && !idMeetingPwdCheck.checked) {
            idMeetingPwdText.text = meetingPassword
            idMeetingPwdCheck.toggle()
        }

        idMeetingPwdText.text = meetingPassword
        idProperty.pswd = ""

        // 初始化会议设置
        if ((attendeeAudioOff && !idMeetingSettingCheck.checked) || (!attendeeAudioOff && idMeetingSettingCheck.checked)) {
            idMeetingSettingCheck.toggle()
        }

        idCancel.enabled = true
        idEdit.enabled = true
        idJoin.enabled = true
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: Qt.platform.os === 'windows' ? 10 : 0
        anchors.left: parent.left
        anchors.top: parent.top
        width: 400
        height: idProperty.bEdit ? editHeight : detailsHeight
        border.width: 1
        border.color: '#FFFFFF'
        radius: Qt.platform.os === 'windows' ? 0 : 10
        onHeightChanged: {
            if (idProperty.bEdit) {
                idScheduleDetailsWindow.height = editHeight
            }
        }
        ColumnLayout {
            id: idColumnLayout
            spacing: 0
            anchors.fill: parent
            DragArea {
                id: idDragArea
                Layout.preferredHeight: 50
                Layout.fillWidth: true
                onCloseClicked: {
                    closeBtnClicked()
                }
            }

            Rectangle {
                Layout.preferredHeight: mainLayout.height - idDragArea.height
                Layout.fillWidth: true
                radius: Qt.platform.os === 'windows' ? 0 : 10
                anchors.margins: Qt.platform.os === 'windows' ? 10 : 0

                ColumnLayout {
                    anchors.left: parent.Left
                    anchors.leftMargin: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 36
                    anchors.top: parent.top
                    anchors.topMargin: 36
                    spacing:  Qt.platform.os === 'windows' ? 22 : 25
                    width: 328

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        spacing: 8
                        Label {
                            id: idSubject
                            text: qsTr("Meeting Subject")
                            font.pixelSize: 16
                        }
                        CustomTextFieldEx {
                            id: idSubjectText
                            Layout.fillWidth: true
                            readOnly: !idProperty.bEdit
                            placeholderText: qsTr("Please enter meeting subject")
                            validator: RegExpValidator { regExp: /\w{1,30}/ }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        spacing: 8
                        visible: !idProperty.bEdit
                        Label {
                            id: idID
                            text: qsTr("Meeting ID")
                            font.pixelSize: 16
                        }
                        RowLayout {
                            spacing: 10
                            CustomTextFieldEx {
                                id: idIDText
                                Layout.fillWidth: true
                                enabled: idProperty.bEdit
                                text: prettyConferenceId(meetingId)
                            }
                            Label {
                                id: idCopyId
                                text: qsTr("Copy")
                                font.pixelSize: 14
                                color: "#337EFF"
                                MouseArea {
                                    id: copyIdBtn
                                    anchors.fill: parent
                                    onClicked: {
                                        clipboard.setText(prettyConferenceId(meetingId))
                                        idMessage.info(qsTr('Meeting link has been copied'))
                                    }
                                }
                                Accessible.role: Accessible.Button
                                Accessible.name: idCopyId.text
                                Accessible.onPressAction: if (enabled) copyIdBtn.clicked(Qt.LeftButton)
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 8
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        Label {
                            id: idStartTime
                            text: qsTr("Start Time")
                            font.pixelSize: 16
                        }
                        RowLayout {
                            spacing: 10
                            CustomCalendar {
                                id: idStartDate
                                Layout.preferredWidth: 198
                                manualInput: false
                                aliasName: "startDate"
                                enabled: idProperty.bEdit
                                minimumDate: new Date()

                                onCurrentDateChanged: {
                                    // console.log("idStartDate onCurrentDateChanged")
                                    getListStartTime()

                                    if (!idProperty.bEdit)
                                        return

                                    var s = idStartDate.text + " " + idComBoxStartTime.text + ":" + "00"
                                    s = s.replace(/-/g,"/");
                                    // console.log("s", s)
                                    const startDateTimeTmp = new Date(s)
                                    const startDateTimeTmpadd1 = startDateTimeTmp.getTime() + 24*60*60*1000
                                    const startDateTimeTmpsubtract1 = startDateTimeTmp.getTime() - 24*60*60*1000
                                    // console.log("startDateTimeTmpadd1", startDateTimeTmpadd1)
                                    // console.log("startDateTimeTmpsubtract1", startDateTimeTmpsubtract1)

                                    var e = idEndDate.text + " " + idComBoxEndTime.text + ":" + "00"
                                    e = e.replace(/-/g,"/");
                                    // console.log("e", e)
                                    const endDateTimeTmp = new Date(e)
                                    // console.log("endDateTimeTmp", endDateTimeTmp.getTime())

                                    if (startDateTimeTmpadd1 < endDateTimeTmp || startDateTimeTmpsubtract1 > endDateTimeTmp)
                                        idEndDate.currentDate = currentDate
                                }
                            }

                            CustomComboBox {
                                id: idComBoxStartTime
                                aliasName: "startTime"
                                Layout.fillWidth: true
                                enabled: idProperty.bEdit
                                onCurrentIndexChanged: {
                                    // console.log("idComBoxStartTime onCurrentIndexChanged")
                                    if (!idProperty.bEdit)
                                        return

                                    if (text === (idProperty.timeArray[idProperty.timeArray.length - 1])) {
                                        // 如果开始时间是23:30
                                        idEndDate.currentDate = Date.fromLocaleDateString(Qt.locale(), addDays(idStartDate.currentDate, 1), "yyyy-MM-dd")
                                        idEndDate.minimumDate = idEndDate.currentDate
                                    } else {
                                        idEndDate.minimumDate = Qt.binding(function() { return idStartDate.currentDate })
                                        getListEndTime()
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 8
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        Label {
                            id: idEndTime
                            text: qsTr("End Time")
                            font.pixelSize: 16
                        }
                        RowLayout {
                            spacing: 10
                            CustomCalendar {
                                id: idEndDate
                                Layout.preferredWidth: 198
                                manualInput: false
                                aliasName: "endDate"
                                enabled: idProperty.bEdit
                                maximumDate: Date.fromLocaleDateString(Qt.locale(), addDays(idStartDate.currentDate, 1), "yyyy-MM-dd")

                                onCurrentDateChanged: {
                                    // console.log("idEndDate onCurrentDateChanged")
                                    getListEndTime()
                                }
                            }
                            CustomComboBox {
                                id: idComBoxEndTime
                                aliasName: "endTime"
                                Layout.fillWidth: true
                                enabled: idProperty.bEdit
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.preferredHeight: 56
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            id: idMeetingPwd
                            text: qsTr("Meeting Password")
                            font.pixelSize: 16
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            CustomCheckBox {
                                id: idMeetingPwdCheck
                                text: qsTr("Use Password")
                                font.pixelSize: 14
                                enabled: idProperty.bEdit
                                onToggled: {
                                    if (idMeetingPwdCheck.checked) {
                                        idMeetingPwdText.text = idProperty.pswd
                                        if (idMeetingPwdText.text.trim().length === 0) {
                                            idMeetingPwdText.text = ('000000' + Math.floor(Math.random() * 999999)).slice(-6)
                                        }
                                    } else if (!idMeetingPwdCheck.checked) {
                                        idProperty.pswd = idMeetingPwdText.text
                                        idMeetingPwdText.text = ""
                                    }
                                }
                            }
                            CustomTextFieldEx {
                                id: idMeetingPwdText
                                text: ""
                                enabled: idProperty.bEdit && idMeetingPwdCheck.checked
                                placeholderText: qsTr("Please enter 6-digit password")
                                validator: RegExpValidator { regExp: /[0-9]{6}/ }
                                Layout.fillWidth: true
                            }
                            Label {
                                id: idCopyPassword
                                visible: !idProperty.bEdit && idMeetingPwdCheck.checked
                                text: qsTr("Copy")
                                font.pixelSize: 14
                                color: "#337EFF"
                                MouseArea {
                                    id: copyPasswordBtn
                                    anchors.fill: parent
                                    onClicked: {
                                        clipboard.setText(meetingPassword)
                                        idMessage.info(qsTr('Meeting password has been copied'))
                                    }
                                }
                                Accessible.role: Accessible.Button
                                Accessible.name: idCopyPassword.text
                                Accessible.onPressAction: if (enabled) copyPasswordBtn.clicked(Qt.LeftButton)
                            }
                        }
                    }

                    Column {
                        spacing: 8
                        Layout.preferredHeight: 40
                        Label {
                            id: idMeetingSetting
                            text: qsTr("Meeting Setting")
                            font.pixelSize: 16
                        }
                        CustomCheckBox {
                            id: idMeetingSettingCheck
                            enabled: idProperty.bEdit
                            text: qsTr("Automatically mute when join the meeting")
                            font.pixelSize: 14
                        }
                    }

                    Column {
                        id: colLive
                        visible: true
                        Layout.fillWidth: true
                        Layout.preferredHeight:  64
                        spacing: 8
                        Label {
                            id: idMeetingLiveSetting
                            text: qsTr("Live Settings")
                            font.pixelSize: 16
                        }
                        RowLayout {
                            id:liveEdit
                            visible: idProperty.bEdit || !liveEanble
                            enabled: idProperty.bEdit
                            width: parent.width
                            CustomCheckBox {
                                id:editLiveCheck
                                text: qsTr("Enable live stream")
                                font.pixelSize: 14
                                checked: liveUrl.length !== 0 && liveEanble === true
                                enabled: true
                            }
                        }
                        RowLayout {
                            id:liveDetails
                            visible: liveUrl.length !== 0 && liveEanble === true && idProperty.bEdit === false
                            width: parent.width
                            height: 32
                            spacing: 8
                            Label {
                                text: qsTr("Live Url")
                                font.pixelSize: 14
                            }

                            Rectangle{
                                id: idLiveUrlText
                                Layout.fillWidth: true
                                color:  "#F7F8FA"
                                radius: 2
                                border.color: "#DCDFE5"
                                border.width: 1
                                height: 32

                                Label {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: 14
                                    text: liveUrl
                                    elide: Text.ElideRight
                                }
                            }
                            Label {
                                id: idCopyliveUrl
                                text: qsTr("Copy")
                                font.pixelSize: 14
                                color: "#337EFF"
                                MouseArea {
                                    id: copyLiveUrlBtn
                                    anchors.fill: parent
                                    onClicked: {
                                        clipboard.setText(liveUrl)
                                        idMessage.info(qsTr('Live Url has been copied'))
                                    }
                                }
                                Accessible.role: Accessible.Button
                                Accessible.name: idCopyliveUrl.text
                                Accessible.onPressAction: if (enabled) copyLiveUrlBtn.clicked(Qt.LeftButton)
                            }
                        }

                        CustomCheckBox {
                            id:idLiveAccessCheck
                            text: qsTr("Only employees of the company can watch")
                            font.pixelSize: 14
                            checked: liveAccess
                            enabled: idProperty.bEdit === true
                            visible: editLiveCheck.checked
                            anchors.left: parent.left
                            anchors.leftMargin: idProperty.bEdit === true ? 26 : 0
                        }

                    }
                }

                CustomToolSeparator {
                    width: parent.width
                    anchors.left: parent.left
                    anchors.bottom: idBtnRow.top
                    anchors.bottomMargin: idBtnRow.anchors.bottomMargin
                }

                Row {
                    id: idBtnRow
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
                    CustomButton {
                        id: idCancel
                        height: 36
                        width: 116
                        text: qsTr("Cancel Meeting")
                        visible: !idProperty.bEdit && 1 === meetingStatus
                        markedness: true
                        onClicked: {
                            DialogManager.dynamicDialog(qsTr("Cancel"), qsTr('Do you want to cancel this meeting?'), function () {
                                idCancel.enabled = false
                                idEdit.enabled = false
                                idJoin.enabled = false
                                meetingManager.cancelMeeting(uniqueMeetingId)
                            }, function () {}, idScheduleDetailsWindow, qsTr('Confirm'), qsTr('Exit'))
                        }
                    }

                    CustomButton {
                        id: idEdit
                        height: 36
                        width: 116
                        text: idProperty.bEdit ? qsTr("Save") : qsTr("Edit Meeting")
                        highlighted: idProperty.bEdit
                        visible: 1 === meetingStatus
                        onClicked: {
                            if (!idProperty.bEdit) {
                                idScheduleDetailsWindow.title = qsTr("Edit Meeting")
                                idProperty.bEdit = true
                            } else {
                                if (idSubjectText.text.trim().length === 0) {
                                    idMessage.warning(qsTr("Please enter meeting subject"))
                                    return
                                } else if (idMeetingPwdCheck.checked && idMeetingPwdText.text.trim().length !== 6) {
                                    idMessage.warning(qsTr("Please enter 6-digit password"))
                                    return
                                }

                                var s = idStartDate.text + " " + idComBoxStartTime.text + ":" + "00"
                                s = s.replace(/-/g,"/");
                                // console.log("s", s)
                                const startDateTime = new Date(s)
                                // console.log("startDateTime", startDateTime.getTime())
                                var e = idEndDate.text + " " + idComBoxEndTime.text + ":" + "00"
                                e = e.replace(/-/g,"/");
                                // console.log("e", e)
                                const endDateTime = new Date(e)
                                // console.log("endDateTime", endDateTime.getTime())

                                idCancel.enabled = false
                                idEdit.enabled = false
                                idJoin.enabled = false
                                meetingManager.editMeeting(uniqueMeetingId,
                                                           meetingId,
                                                           idSubjectText.text,
                                                           startDateTime.getTime(),
                                                           endDateTime.getTime(),
                                                           !idMeetingPwdCheck.checked ? "" : idMeetingPwdText.text,
                                                           idMeetingSettingCheck.checked,
                                                           editLiveCheck.checked,
                                                           idLiveAccessCheck.checked,
                                                           meetingManager.isSupportRecord)
                            }
                        }
                    }

                    CustomButton {
                        id: idJoin
                        height: 36
                        width: 116
                        highlighted: true
                        visible: !idProperty.bEdit
                        text: qsTr("Join Meeting")
                        onClicked: {
                            let micStatus = false
                            let cameraStatus = false
                            if (Qt.platform.os === 'windows') {
                                micStatus = globalSettings.value('localMicStatusEx') === 'true'
                                cameraStatus = globalSettings.value('localCameraStatusEx') === 'true'
                            } else {
                                micStatus = globalSettings.value('localMicStatusEx')
                                cameraStatus = globalSettings.value('localCameraStatusEx')
                            }

                            joinMeeting()
                            meetingManager.invokeJoin(meetingId, authManager.appUserNick, micStatus, cameraStatus)
                            idScheduleDetailsWindow.close()
                        }
                    }
                }
            }
            QtObject {
                id: idProperty
                property var timeArray: ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30",
                    "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30",
                    "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
                    "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30",
                    "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30",
                    "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"]

                property string pswd: ""
                property bool bEdit: false
            }
        }

        Connections {
            target: meetingManager
            onCancelSignal: {
                console.info("Cancel meeting callback, error code:", errorCode, ", error message:", errorMessage)
                if (0 !== errorCode) {
                    idMessage.error(errorMessage)
                }else {
                    idScheduleDetailsWindow.close()
                    message.info(qsTr("Cancel meeting successfully."))
                }
                idCancel.enabled = true
                idEdit.enabled = true
                idJoin.enabled = true
            }

            onEditSignal: {
                console.info("Edit meeting callback, error code:", errorCode, ", error message:", errorMessage)
                if (0 !== errorCode) {
                    idMessage.error(errorMessage)
                }else {
                    idScheduleDetailsWindow.close()
                    message.info(qsTr("Edit meeting successfully."))
                }
                idCancel.enabled = true
                idEdit.enabled = true
                idJoin.enabled = true
            }
        }
    }
    // 加days天，返回"yyyy-MM-dd"
    function addDays(date, days) {
        var nd = new Date(date);
        nd = nd.valueOf();
        nd = nd + days * 24 * 60 * 60 * 1000;
        nd = new Date(nd);
        var y = nd.getFullYear();
        var m = nd.getMonth() + 1;
        var d = nd.getDate();
        if(m <= 9) m = "0"+m;
        if(d <= 9) d = "0"+d;
        var cdate = y+"-"+m+"-"+d;
        return cdate;
    }

    // 获取开始时间列表
    function getListStartTime() {
        // console.log("getListStartTime")
        var start = 0
        var end = idProperty.timeArray.length // 等于47

        // 如果是今天，则获取当前时间点的下一个半点的索引
        const curTime = new Date()
        const dateTmp = new Date(idStartDate.currentDate)
        if (dateTmp.toDateString() === curTime.toDateString()) {
            if (idProperty.bEdit) {
                start = curTime.getHours() * 2 + (curTime.getMinutes() < 30 ? 1 : 2)
            } else {
                start = dateTmp.getHours() * 2 + (dateTmp.getMinutes() < 30 ? 0 : 1)
            }
        }

        // 限定最大时间
        if (end >= idProperty.timeArray.length) {
            end = idProperty.timeArray.length - 1
        }

        // 获取上次选中的时间
        var lastIndex = 0
        var lastText = ''
        if (!idProperty.bEdit) {
            const datetimeTmp = new Date(startTime)
            var hours = datetimeTmp.getHours()
            var minutes = datetimeTmp.getMinutes()
            lastText = (hours >= 10 ? hours : '0' + hours) + ':' + (minutes >= 10 ? minutes : '0' + minutes)
        } else {
            lastText = idComBoxStartTime.text
        }

        // console.log("start, end:", start, end)
        var arrayTmp = new Array
        for (let i = start; i <= end; i++) {
            arrayTmp.push(idProperty.timeArray[i])
        }
        idComBoxStartTime.listModel = arrayTmp

        idComBoxStartTime.listModel.some(function(item, index){
            if (item === lastText) {
                lastIndex = index
                return
            }
        })
        // console.log("lastIndex", lastIndex)
        idComBoxStartTime.currentIndex = lastIndex
    }

    // 获取结束时间列表
    function getListEndTime() {
        // console.log("getListEndTime")
        if ("" === idComBoxStartTime.text) {
            return
        }

        var start = 0
        var end = idProperty.timeArray.length // 等于47

        // 获取开始时间点的索引
        for (let j = 0; j < idProperty.timeArray.length; j++) {
            if (idProperty.timeArray[j] === idComBoxStartTime.text) {
                start = j + 1
                break
            }
        }

        // console.log("start, end:", start, end)
        // 如果不是今天，则获取后一天从00:00到开始时间点的索引
        const dateTmp1 = new Date(idStartDate.currentDate)
        const dateTmp2 = new Date(idEndDate.currentDate)
        if (dateTmp1.toDateString() !== dateTmp2.toDateString()) {
            end = start - 1
            start = 0
        }

        // 限定最大时间
        if (end >= idProperty.timeArray.length) {
            end = idProperty.timeArray.length - 1
        }

        // 获取上次选中的时间
        var lastIndex = 0
        var lastText = ''
        if (!idProperty.bEdit) {
            const datetimeTmp = new Date(endTime)
            var hours = datetimeTmp.getHours()
            var minutes = datetimeTmp.getMinutes()
            lastText = (hours >= 10 ? hours : '0' + hours) + ':' + (minutes >= 10 ? minutes : '0' + minutes)
        } else {
            lastText = idComBoxEndTime.text
        }

        // console.log("start, end:", start, end)
        var arrayTmp = new Array
        for (let i = start; i <= end; i++) {
            arrayTmp.push(idProperty.timeArray[i])
        }
        idComBoxEndTime.listModel = arrayTmp
        // console.log("idComBoxEndTime.listModel:", idComBoxEndTime.listModel)

        // console.log("lastText", lastText)
        idComBoxEndTime.listModel.some(function(item, index){
            if (item === lastText) {
                lastIndex = index
                return
            }
        })

        // console.log("lastIndex", lastIndex)
        idComBoxEndTime.currentIndex = lastIndex
    }

    function prettyConferenceId(conferenceId) {
        if (conferenceId === undefined) {
            conferenceId = meetingManager.meetingId
        }
        return conferenceId.substring(0, 3) + "-" +
                conferenceId.substring(3, 6) + "-" +
                conferenceId.substring(6)
    }
}
