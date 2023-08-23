import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material 2.12
import "../components"
import "../utils/dialogManager.js" as DialogManager

Window {
    id: idScheduleDetailsWindow

    property bool attendeeAudioOff
    property int detailsHeight: Qt.platform.os === 'windows' ? 626 + 20 : 646   // 根据视觉调整
    property int editHeight: Qt.platform.os === 'windows' ? 644 + 20 : 644      // 根据视觉调整
    property var endTime
    property string lastSubjectText: ''
    property bool liveAccess: false
    property bool liveEanble: false
    property string liveUrl: ""
    property string meetingId
    property string meetingInviteUrl
    property string meetingPassword
    property int meetingStatus
    property string meetingTopic
    property bool recordEnable: false
    property var startTime
    property int uniqueMeetingId

    signal closeBtnClicked
    signal joinMeeting

    // 加days天，返回"yyyy-MM-dd"
    function addDays(date, days) {
        var nd = new Date(date);
        nd = nd.valueOf();
        nd = nd + days * 24 * 60 * 60 * 1000;
        nd = new Date(nd);
        var y = nd.getFullYear();
        var m = nd.getMonth() + 1;
        var d = nd.getDate();
        if (m <= 9)
            m = "0" + m;
        if (d <= 9)
            d = "0" + d;
        var cdate = y + "-" + m + "-" + d;
        return cdate;
    }
    function close() {
        idDragArea.close();
    }

    // 获取结束时间列表
    function getListEndTime() {
        // console.log("getListEndTime")
        if ("" === idComBoxStartTime.text) {
            return;
        }
        var start = 0;
        var end = idProperty.timeArray.length; // 等于47

        // 获取开始时间点的索引
        for (let j = 0; j < idProperty.timeArray.length; j++) {
            if (idProperty.timeArray[j] === idComBoxStartTime.text) {
                start = j + 1;
                break;
            }
        }

        // console.log("start, end:", start, end)
        // 如果不是今天，则获取后一天从00:00到开始时间点的索引
        const dateTmp1 = new Date(idStartDate.currentDate);
        const dateTmp2 = new Date(idEndDate.currentDate);
        if (dateTmp1.toDateString() !== dateTmp2.toDateString()) {
            end = start - 1;
            start = 0;
        }

        // 限定最大时间
        if (end >= idProperty.timeArray.length) {
            end = idProperty.timeArray.length - 1;
        }

        // 获取上次选中的时间
        var lastIndex = 0;
        var lastText = '';
        if (!idProperty.bEdit) {
            const datetimeTmp = new Date(endTime);
            var hours = datetimeTmp.getHours();
            var minutes = datetimeTmp.getMinutes();
            lastText = (hours >= 10 ? hours : '0' + hours) + ':' + (minutes >= 10 ? minutes : '0' + minutes);
        } else {
            lastText = idComBoxEndTime.text;
        }

        // console.log("start, end:", start, end)
        var arrayTmp = new Array;
        for (let i = start; i <= end; i++) {
            arrayTmp.push(idProperty.timeArray[i]);
        }
        idComBoxEndTime.listModel = arrayTmp;
        // console.log("idComBoxEndTime.listModel:", idComBoxEndTime.listModel)

        // console.log("lastText", lastText)
        idComBoxEndTime.listModel.some(function (item, index) {
                if (item === lastText) {
                    lastIndex = index;
                    return;
                }
            });

        // console.log("lastIndex", lastIndex)
        idComBoxEndTime.currentIndex = lastIndex;
    }

    // 获取开始时间列表
    function getListStartTime() {
        // console.log("getListStartTime")
        var start = 0;
        var end = idProperty.timeArray.length; // 等于47

        // 如果是今天，则获取当前时间点的下一个半点的索引
        const curTime = new Date();
        const dateTmp = new Date(idStartDate.currentDate);
        if (dateTmp.toDateString() === curTime.toDateString()) {
            if (idProperty.bEdit) {
                start = curTime.getHours() * 2 + (curTime.getMinutes() < 30 ? 1 : 2);
            } else {
                start = dateTmp.getHours() * 2 + (dateTmp.getMinutes() < 30 ? 0 : 1);
            }
        }

        // 限定最大时间
        if (end >= idProperty.timeArray.length) {
            end = idProperty.timeArray.length - 1;
        }

        // 获取上次选中的时间
        var lastIndex = 0;
        var lastText = '';
        if (!idProperty.bEdit) {
            const datetimeTmp = new Date(startTime);
            var hours = datetimeTmp.getHours();
            var minutes = datetimeTmp.getMinutes();
            lastText = (hours >= 10 ? hours : '0' + hours) + ':' + (minutes >= 10 ? minutes : '0' + minutes);
        } else {
            lastText = idComBoxStartTime.text;
        }

        // console.log("start, end:", start, end)
        var arrayTmp = new Array;
        for (let i = start; i <= end; i++) {
            arrayTmp.push(idProperty.timeArray[i]);
        }
        idComBoxStartTime.listModel = arrayTmp;
        idComBoxStartTime.listModel.some(function (item, index) {
                if (item === lastText) {
                    lastIndex = index;
                    return;
                }
            });
        // console.log("lastIndex", lastIndex)
        idComBoxStartTime.currentIndex = lastIndex;
    }
    function init() {
        idScheduleDetailsWindow.title = qsTr("Meeting Details");
        detailsHeight = Qt.platform.os === 'windows' ? 646 + 20 : 646 + 20;
        editHeight = Qt.platform.os === 'windows' ? 644 + 20 : 644;
        meetingManager.getIsSupportRecord();
        if (meetingManager.isSupportLive) {
            detailsHeight += 30;
            if (liveEanble) {
                detailsHeight += 40;
            }
            if (Qt.platform.os === 'windows') {
                editHeight -= 30;
            }
            colLive.visible = true;
        } else {
            colLive.visible = false;
        }
        if (meetingInviteUrl !== '') {
            detailsHeight += 56;
        }
        idScheduleDetailsWindow.height = detailsHeight;
        idProperty.bEdit = false;
        lastSubjectText = meetingTopic;
        idSubjectText.text = meetingTopic;

        // 初始化日期
        var datetimeTmp = new Date(startTime);
        idStartDate.currentDate = datetimeTmp;
        idComBoxStartTime.currentIndex = -1;
        getListStartTime();
        datetimeTmp = new Date(endTime);
        idComBoxEndTime.currentIndex = -1;
        idEndDate.currentDate = datetimeTmp;
        idEndDate.minimumDate = idStartDate.currentDate;

        // 初始化设置密码
        if (meetingPassword.length === 0 && idMeetingPwdCheck.checked) {
            idMeetingPwdCheck.toggle();
        } else if (meetingPassword.length !== 0 && !idMeetingPwdCheck.checked) {
            idMeetingPwdText.text = meetingPassword;
            idMeetingPwdCheck.toggle();
        }
        idMeetingPwdText.text = meetingPassword;
        idProperty.pswd = "";

        // 初始化会议设置
        if ((attendeeAudioOff && !idMeetingSettingCheck.checked) || (!attendeeAudioOff && idMeetingSettingCheck.checked)) {
            idMeetingSettingCheck.toggle();
        }
        idCancel.enabled = true;
        idEdit.enabled = true;
        idJoin.enabled = true;
        const screenTmp = mainWindow.screen;
        idScheduleDetailsWindow.x = (screenTmp.width - idScheduleDetailsWindow.width) / 2 + screenTmp.virtualX;
        idScheduleDetailsWindow.y = (screenTmp.height - idScheduleDetailsWindow.height) / 2 + screenTmp.virtualY;
    }
    function prettyConferenceId(conferenceId) {
        if (conferenceId === undefined) {
            conferenceId = meetingManager.meetingId;
        }
        return conferenceId.substring(0, 3) + "-" + conferenceId.substring(3, 6) + "-" + conferenceId.substring(6);
    }

    Accessible.name: "scheduleDetailsWindow"
    Material.theme: Material.Light
    color: "#00000000"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    //property alias title: idDragArea.title
    width: Qt.platform.os === 'windows' ? 400 + 20 : 400                        // 根据视觉调整

    onVisibleChanged: {
        if (visible) {
            init();
        }
    }

    MessageManager {
        id: idMessage
    }
    DropShadow {
        anchors.fill: mainLayout
        color: "#3217171A"
        horizontalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        spread: 0
        verticalOffset: 0
        visible: Qt.platform.os === 'windows'

        Behavior on radius  {
            PropertyAnimation {
                duration: 100
            }
        }
    }
    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.left: parent.left
        anchors.margins: Qt.platform.os === 'windows' ? 10 : 0
        anchors.top: parent.top
        border.color: '#FFFFFF'
        border.width: 1
        height: idProperty.bEdit ? editHeight : detailsHeight
        radius: Qt.platform.os === 'windows' ? 0 : 10
        width: 400

        onHeightChanged: {
            if (idProperty.bEdit) {
                idScheduleDetailsWindow.height = editHeight;
            }
        }

        ColumnLayout {
            id: idColumnLayout
            anchors.fill: parent
            spacing: 0

            DragArea {
                id: idDragArea
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                title: idScheduleDetailsWindow.title

                onCloseClicked: {
                    closeBtnClicked();
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: mainLayout.height - idDragArea.height
                anchors.margins: Qt.platform.os === 'windows' ? 10 : 0
                radius: Qt.platform.os === 'windows' ? 0 : 10

                ColumnLayout {
                    anchors.left: parent.Left
                    anchors.leftMargin: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 36
                    anchors.top: parent.top
                    anchors.topMargin: 36
                    spacing: Qt.platform.os === 'windows' ? 22 : 25
                    width: 328

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        spacing: 8

                        Label {
                            id: idSubject
                            font.pixelSize: 16
                            text: qsTr("Meeting Subject")
                        }
                        CustomTextFieldEx {
                            id: idSubjectText
                            Layout.fillWidth: true
                            placeholderText: qsTr("Please enter meeting subject")
                            readOnly: !idProperty.bEdit

                            onTextChanged: {
                                const currentText = idSubjectText.text;
                                if (currentText === lastSubjectText)
                                    return;
                                if (getByteLength(currentText) > 30) {
                                } else {
                                    lastSubjectText = currentText;
                                    const regStr = /[\uD83C|\uD83D|\uD83E][\uDC00-\uDFFF][\u200D|\uFE0F]|[\uD83C|\uD83D|\uD83E][\uDC00-\uDFFF]|[0-9|*|#]\uFE0F\u20E3|[0-9|#]\u20E3|[\u203C-\u3299]\uFE0F\u200D|[\u203C-\u3299]\uFE0F|[\u2122-\u2B55]|\u303D|[\A9|\AE]\u3030|\uA9|\uAE|\u3030/gi;
                                    lastSubjectText = lastSubjectText.replace(regStr, '');
                                }
                                idSubjectText.text = lastSubjectText;
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        spacing: 8
                        visible: !idProperty.bEdit

                        Label {
                            id: idID
                            font.pixelSize: 16
                            text: qsTr("Meeting ID")
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
                                Accessible.name: "copy_id"
                                Accessible.role: Accessible.Button
                                color: "#337EFF"
                                font.pixelSize: 14
                                text: qsTr("Copy")

                                Accessible.onPressAction: if (enabled)
                                    copyIdBtn.clicked(Qt.LeftButton)

                                MouseArea {
                                    id: copyIdBtn
                                    anchors.fill: parent

                                    onClicked: {
                                        clipboard.setText(prettyConferenceId(meetingId));
                                        idMessage.info(qsTr('Meeting link has been copied'));
                                    }
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        spacing: 8
                        visible: !idProperty.bEdit && meetingInviteUrl !== ''

                        Label {
                            id: idInviteUrl
                            font.pixelSize: 16
                            text: qsTr("InviteUrl")
                        }
                        RowLayout {
                            spacing: 10

                            CustomTextFieldEx {
                                id: idInviteUrlText
                                Layout.fillWidth: true
                                enabled: idProperty.bEdit
                                text: meetingInviteUrl
                            }
                            Label {
                                id: idCopyInviteUrl
                                Accessible.name: "copy_inviteUrl"
                                Accessible.role: Accessible.Button
                                color: "#337EFF"
                                font.pixelSize: 14
                                text: qsTr("Copy")

                                Accessible.onPressAction: if (enabled)
                                    copyInviteUrlBtn.clicked(Qt.LeftButton)

                                MouseArea {
                                    id: copyInviteUrlBtn
                                    anchors.fill: parent

                                    onClicked: {
                                        clipboard.setText(meetingInviteUrl);
                                        idMessage.info(qsTr('Meeting Invite Url has been copied'));
                                    }
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        spacing: 8

                        Label {
                            id: idStartTime
                            font.pixelSize: 16
                            text: qsTr("Start Time")
                        }
                        RowLayout {
                            spacing: 10

                            CustomCalendar {
                                id: idStartDate
                                Layout.preferredWidth: 198
                                aliasName: "startDate"
                                enabled: idProperty.bEdit
                                manualInput: false
                                minimumDate: new Date()

                                onCurrentDateChanged: {
                                    // console.log("idStartDate onCurrentDateChanged")
                                    getListStartTime();
                                    if (!idProperty.bEdit)
                                        return;
                                    var s = idStartDate.text + " " + idComBoxStartTime.text + ":" + "00";
                                    s = s.replace(/-/g, "/");
                                    // console.log("s", s)
                                    const startDateTimeTmp = new Date(s);
                                    const startDateTimeTmpadd1 = startDateTimeTmp.getTime() + 24 * 60 * 60 * 1000;
                                    const startDateTimeTmpsubtract1 = startDateTimeTmp.getTime() - 24 * 60 * 60 * 1000;
                                    // console.log("startDateTimeTmpadd1", startDateTimeTmpadd1)
                                    // console.log("startDateTimeTmpsubtract1", startDateTimeTmpsubtract1)
                                    var e = idEndDate.text + " " + idComBoxEndTime.text + ":" + "00";
                                    e = e.replace(/-/g, "/");
                                    // console.log("e", e)
                                    const endDateTimeTmp = new Date(e);
                                    // console.log("endDateTimeTmp", endDateTimeTmp.getTime())
                                    if (startDateTimeTmpadd1 < endDateTimeTmp || startDateTimeTmpsubtract1 > endDateTimeTmp)
                                        idEndDate.currentDate = currentDate;
                                }
                            }
                            CustomComboBox {
                                id: idComBoxStartTime
                                Layout.fillWidth: true
                                aliasName: "startTime"
                                enabled: idProperty.bEdit

                                onCurrentIndexChanged: {
                                    // console.log("idComBoxStartTime onCurrentIndexChanged")
                                    if (!idProperty.bEdit)
                                        return;
                                    if (text === (idProperty.timeArray[idProperty.timeArray.length - 1])) {
                                        // 如果开始时间是23:30
                                        idEndDate.currentDate = Date.fromLocaleDateString(Qt.locale(), addDays(idStartDate.currentDate, 1), "yyyy-MM-dd");
                                        idEndDate.minimumDate = idEndDate.currentDate;
                                    } else {
                                        idEndDate.minimumDate = Qt.binding(function () {
                                                return idStartDate.currentDate;
                                            });
                                        getListEndTime();
                                    }
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        spacing: 8

                        Label {
                            id: idEndTime
                            font.pixelSize: 16
                            text: qsTr("End Time")
                        }
                        RowLayout {
                            spacing: 10

                            CustomCalendar {
                                id: idEndDate
                                Layout.preferredWidth: 198
                                aliasName: "endDate"
                                enabled: idProperty.bEdit
                                manualInput: false
                                maximumDate: Date.fromLocaleDateString(Qt.locale(), addDays(idStartDate.currentDate, 1), "yyyy-MM-dd")

                                onCurrentDateChanged: {
                                    // console.log("idEndDate onCurrentDateChanged")
                                    getListEndTime();
                                }
                            }
                            CustomComboBox {
                                id: idComBoxEndTime
                                Layout.fillWidth: true
                                aliasName: "endTime"
                                enabled: idProperty.bEdit
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        spacing: 8

                        Label {
                            id: idMeetingPwd
                            font.pixelSize: 16
                            text: qsTr("Meeting Password")
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            CustomCheckBox {
                                id: idMeetingPwdCheck
                                enabled: idProperty.bEdit
                                font.pixelSize: 14
                                text: qsTr("Use Password")

                                onToggled: {
                                    if (idMeetingPwdCheck.checked) {
                                        idMeetingPwdText.text = idProperty.pswd;
                                        if (idMeetingPwdText.text.trim().length === 0) {
                                            idMeetingPwdText.text = ('000000' + Math.floor(Math.random() * 999999)).slice(-6);
                                        }
                                    } else if (!idMeetingPwdCheck.checked) {
                                        idProperty.pswd = idMeetingPwdText.text;
                                        idMeetingPwdText.text = "";
                                    }
                                }
                            }
                            CustomTextFieldEx {
                                id: idMeetingPwdText
                                Layout.fillWidth: true
                                enabled: idProperty.bEdit && idMeetingPwdCheck.checked
                                placeholderText: qsTr("Please enter 6-digit password")
                                text: ""

                                validator: RegularExpressionValidator {
                                    regularExpression: /[0-9]{6}/
                                }
                            }
                            Label {
                                id: idCopyPassword
                                Accessible.name: "copy_password"
                                Accessible.role: Accessible.Button
                                color: "#337EFF"
                                font.pixelSize: 14
                                text: qsTr("Copy")
                                visible: !idProperty.bEdit && idMeetingPwdCheck.checked

                                Accessible.onPressAction: if (enabled)
                                    copyPasswordBtn.clicked(Qt.LeftButton)

                                MouseArea {
                                    id: copyPasswordBtn
                                    anchors.fill: parent

                                    onClicked: {
                                        clipboard.setText(meetingPassword);
                                        idMessage.info(qsTr('Meeting password has been copied'));
                                    }
                                }
                            }
                        }
                    }
                    Column {
                        Layout.preferredHeight: 40
                        spacing: 8

                        Label {
                            id: idMeetingSetting
                            font.pixelSize: 16
                            text: qsTr("Meeting Setting")
                        }
                        CustomCheckBox {
                            id: idMeetingSettingCheck
                            enabled: idProperty.bEdit
                            font.pixelSize: 14
                            text: qsTr("Automatically mute when join the meeting")
                        }
                    }
                    Column {
                        id: colLive
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        spacing: 8
                        visible: true

                        Label {
                            id: idMeetingLiveSetting
                            font.pixelSize: 16
                            text: qsTr("Live Settings")
                        }
                        RowLayout {
                            id: liveEdit
                            enabled: idProperty.bEdit
                            visible: idProperty.bEdit || !liveEanble
                            width: parent.width

                            CustomCheckBox {
                                id: editLiveCheck
                                checked: liveUrl.length !== 0 && liveEanble === true
                                enabled: true
                                font.pixelSize: 14
                                text: qsTr("Enable live stream")
                            }
                        }
                        RowLayout {
                            id: liveDetails
                            height: 32
                            spacing: 8
                            visible: liveUrl.length !== 0 && liveEanble === true && idProperty.bEdit === false
                            width: parent.width

                            Label {
                                font.pixelSize: 14
                                text: qsTr("Live Url")
                            }
                            Rectangle {
                                id: idLiveUrlText
                                Layout.fillWidth: true
                                border.color: "#DCDFE5"
                                border.width: 1
                                color: "#F7F8FA"
                                height: 32
                                radius: 2

                                Label {
                                    Accessible.name: "liveUrl"
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    font.pixelSize: 14
                                    text: liveUrl
                                }
                            }
                            Label {
                                id: idCopyliveUrl
                                Accessible.name: "copy_liveUrl"
                                Accessible.role: Accessible.Button
                                color: "#337EFF"
                                font.pixelSize: 14
                                text: qsTr("Copy")

                                Accessible.onPressAction: if (enabled)
                                    copyLiveUrlBtn.clicked(Qt.LeftButton)

                                MouseArea {
                                    id: copyLiveUrlBtn
                                    anchors.fill: parent

                                    onClicked: {
                                        clipboard.setText(liveUrl);
                                        idMessage.info(qsTr('Live Url has been copied'));
                                    }
                                }
                            }
                        }
                        CustomCheckBox {
                            id: idLiveAccessCheck
                            anchors.left: parent.left
                            anchors.leftMargin: idProperty.bEdit === true ? 26 : 0
                            checked: liveAccess
                            enabled: idProperty.bEdit === true
                            font.pixelSize: 14
                            text: qsTr("Only employees of the company can watch")
                            visible: editLiveCheck.checked
                        }
                    }
                }
                CustomToolSeparator {
                    anchors.bottom: idBtnRow.top
                    anchors.bottomMargin: idBtnRow.anchors.bottomMargin
                    anchors.left: parent.left
                    width: parent.width
                }
                Row {
                    id: idBtnRow
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    CustomButton {
                        id: idCancel
                        height: 36
                        markedness: true
                        text: qsTr("Cancel Meeting")
                        visible: !idProperty.bEdit && 1 === meetingStatus
                        width: 116

                        onClicked: {
                            DialogManager.dynamicDialog(qsTr("Cancel"), qsTr('Do you want to cancel this meeting?'), function () {
                                    idCancel.enabled = false;
                                    idEdit.enabled = false;
                                    idJoin.enabled = false;
                                    meetingManager.cancelMeeting(uniqueMeetingId);
                                }, function () {}, idScheduleDetailsWindow, qsTr('Confirm'), qsTr('Exit'));
                        }
                    }
                    CustomButton {
                        id: idEdit
                        height: 36
                        highlighted: idProperty.bEdit
                        text: idProperty.bEdit ? qsTr("Save") : qsTr("Edit Meeting")
                        visible: 1 === meetingStatus
                        width: 116

                        onClicked: {
                            if (!idProperty.bEdit) {
                                idScheduleDetailsWindow.title = qsTr("Edit Meeting");
                                idProperty.bEdit = true;
                            } else {
                                if (idSubjectText.text.trim().length === 0) {
                                    idMessage.warning(qsTr("Please enter meeting subject"));
                                    return;
                                } else if (idMeetingPwdCheck.checked && idMeetingPwdText.text.trim().length !== 6) {
                                    idMessage.warning(qsTr("Please enter 6-digit password"));
                                    return;
                                }
                                var s = idStartDate.text + " " + idComBoxStartTime.text + ":" + "00";
                                s = s.replace(/-/g, "/");
                                // console.log("s", s)
                                const startDateTime = new Date(s);
                                // console.log("startDateTime", startDateTime.getTime())
                                var e = idEndDate.text + " " + idComBoxEndTime.text + ":" + "00";
                                e = e.replace(/-/g, "/");
                                // console.log("e", e)
                                const endDateTime = new Date(e);
                                // console.log("endDateTime", endDateTime.getTime())
                                idCancel.enabled = false;
                                idEdit.enabled = false;
                                idJoin.enabled = false;
                                meetingManager.editMeeting(uniqueMeetingId, meetingId, idSubjectText.text, startDateTime.getTime(), endDateTime.getTime(), !idMeetingPwdCheck.checked ? "" : idMeetingPwdText.text, idMeetingSettingCheck.checked, editLiveCheck.checked, idLiveAccessCheck.checked, meetingManager.isSupportRecord);
                            }
                        }
                    }
                    CustomButton {
                        id: idJoin
                        height: 36
                        highlighted: true
                        text: qsTr("Join Meeting")
                        visible: !idProperty.bEdit
                        width: 116

                        onClicked: {
                            let micStatus = false;
                            let cameraStatus = false;
                            if (Qt.platform.os === 'windows') {
                                micStatus = globalSettings.value('localMicStatusEx') === 'true';
                                cameraStatus = globalSettings.value('localCameraStatusEx') === 'true';
                            } else {
                                micStatus = globalSettings.value('localMicStatusEx');
                                cameraStatus = globalSettings.value('localCameraStatusEx');
                            }
                            joinMeeting();
                            meetingManager.invokeJoin(meetingId, authManager.appUserNick, micStatus, cameraStatus);
                            idScheduleDetailsWindow.close();
                        }
                    }
                }
            }
            QtObject {
                id: idProperty

                property bool bEdit: false
                property string pswd: ""
                property var timeArray: ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"]
            }
        }
        Connections {
            target: meetingManager

            onCancelSignal: {
                console.info("Cancel meeting callback, error code:", errorCode, ", error message:", errorMessage);
                if (0 !== errorCode) {
                    idMessage.error(errorMessage);
                } else {
                    idScheduleDetailsWindow.close();
                    message.info(qsTr("Cancel meeting successfully."));
                }
                idCancel.enabled = true;
                idEdit.enabled = true;
                idJoin.enabled = true;
            }
            onEditSignal: {
                console.info("Edit meeting callback, error code:", errorCode, ", error message:", errorMessage);
                if (0 !== errorCode) {
                    idMessage.error(errorMessage);
                } else {
                    idScheduleDetailsWindow.close();
                    message.info(qsTr("Edit meeting successfully."));
                }
                idCancel.enabled = true;
                idEdit.enabled = true;
                idJoin.enabled = true;
            }
        }
    }
}
