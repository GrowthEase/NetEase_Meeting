import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../components"

CustomWindow {
    id: idScheduleWindow
    idLoader.sourceComponent: idComponent
    title: qsTr("Schedule Meeting")
    customWidth: 400
    customHeight: 604

    property bool isSupportLive: false

    onVisibleChanged: {
        if (visible){
            idLoader.item.init()
        }
    }

    Component {
        id: idComponent
        Rectangle {
            id: rect
            function init () {
                // 初始化主题
                idSubjectText.text = qsTr("%1's scheduled meeting").arg(authManager.appUserNick)
                idSubjectText.focus = true

                // 初始化开始日期
                var curDate = new Date()
                if (curDate.getHours() >= 23 && curDate.getMinutes() >= 30) {
                    curDate = Date.fromLocaleDateString(Qt.locale(), addDays(curDate, 1), "yyyy-MM-dd")
                    curDate.setHours(0)
                    curDate.setMinutes(0)
                    curDate.setSeconds(0)
                    curDate.setMilliseconds(0)
                }
                idStartDate.currentDate = curDate
                idStartDate.minimumDate = curDate
                idComBoxStartTime.currentIndex = -1
                idComBoxEndTime.currentIndex = -1
                getListStartTime()

                // 初始化设置密码
                if (idMeetingPwdCheck.checked) {
                    idMeetingPwdCheck.toggle()
                }

                idMeetingPwdText.enabled = false
                idMeetingPwdText.text = ""
                idProperty.pswd = ""

                // 初始化会议设置
                if (idMeetingSettingCheck.checked)
                    idMeetingSettingCheck.toggle()

                idSubmit.enabled = true

                if(idLiveSettingCheck.checked)
                    idLiveSettingCheck.checked = false

                idLiveAccessCheck.checked = false

                isSupportLive = meetingManager.getIsSupportLive()
            }
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent

                ColumnLayout {
                    anchors.left: parent.Left
                    anchors.leftMargin: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 36
                    anchors.top: parent.top
                    anchors.topMargin: 36
                    spacing: 20
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
                            placeholderText: qsTr("Please enter meeting subject")
                            validator: RegExpValidator { regExp: /\w{1,30}/ }
                            Layout.fillWidth: true
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
                                //currentDate: new Date()
                                //minimumDate: new Date()
                                //maximumDate: Date.fromLocaleDateString(Qt.locale(), addDays(minimumDate, 6), "yyyy-MM-dd")

                                onCurrentDateChanged: {
                                    // console.log("idStartDate onCurrentDateChanged")
                                    getListStartTime()
                                    idEndDate.currentDate = currentDate
                                }
                            }

                            CustomComboBox {
                                id: idComBoxStartTime
                                aliasName: "startTime"
                                Layout.fillWidth: true
                                onCurrentIndexChanged: {
                                    // console.log("idComBoxStartTime onCurrentIndexChanged")
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
                                currentDate: new Date()
                                maximumDate: Date.fromLocaleDateString(Qt.locale(), addDays(idStartDate.currentDate, 1), "yyyy-MM-dd")

                                onCurrentDateChanged: {
                                    getListEndTime()
                                }
                            }
                            CustomComboBox {
                                id: idComBoxEndTime
                                aliasName: "endTime"
                                Layout.fillWidth: true
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
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
                                onToggled: {
                                    idMeetingPwdText.enabled = idMeetingPwdCheck.checked
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
                                enabled: false
                                placeholderText: qsTr("Please enter 6-digit password")
                                validator: RegExpValidator { regExp: /[0-9]{6}/ }
                                Layout.fillWidth: true
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
                            text: qsTr("Automatically mute when join the meeting")
                            font.pixelSize: 14
                        }
                    }

                    Column {
                        spacing: 8
                        Layout.preferredHeight: 56
                        visible: isSupportLive
                        Label {
                            id: idLiveSetting
                            text: qsTr("Live Setting")
                            font.pixelSize: 16
                        }
                        CustomCheckBox {
                            id: idLiveSettingCheck
                            text: qsTr("Enable live stream")
                            font.pixelSize: 14
                        }
                        CustomCheckBox {
                            id: idLiveAccessCheck
                            text: qsTr("Only employees of company can watch")
                            font.pixelSize: 14
                            anchors.left: parent.left
                            anchors.leftMargin: 26
                            visible: idLiveSettingCheck.checked
                        }
                    }
                }

                CustomToolSeparator {
                    width: parent.width
                    anchors.left: parent.left
                    anchors.bottom: idSubmit.top
                    anchors.bottomMargin: idSubmit.anchors.bottomMargin
                }

                CustomButton {
                    id: idSubmit
                    height: 36
                    width: 120
                    highlighted: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
                    text: qsTr("Schedule")
                    //                    enabled: {
                    //                        return !(idSubjectText.text.trim().length === 0 || (idMeetingPwdCheck.checked && idMeetingPwdText.text.trim().length !== 6))
                    //                    }

                    onClicked: {
                        if (idSubjectText.text.trim().length === 0) {
                            idScheduleWindow.idMessage.warning(qsTr("Please enter meeting subject"))
                            return
                        } else if (idMeetingPwdCheck.checked && idMeetingPwdText.text.trim().length !== 6) {
                            idScheduleWindow.idMessage.warning(qsTr("Please enter 6-digit password"))
                            return
                        }

                        var s = idStartDate.text + " " + idComBoxStartTime.text + ":" + "00"
                        s = s.replace(/-/g,"/");
                        //console.log("s", s)
                        const startDateTime = new Date(s)
                        //console.log("startDateTime", startDateTime.getTime())
                        var e = idEndDate.text + " " + idComBoxEndTime.text + ":" + "00"
                        e = e.replace(/-/g,"/");
                        //console.log("e", e)
                        const endDateTime = new Date(e)
                        //console.log("endDateTime", endDateTime.getTime())

                        idSubmit.enabled = false
                        meetingManager.scheduleMeeting(idSubjectText.text, startDateTime.getTime(), endDateTime.getTime(), !idMeetingPwdCheck.checked ? "" : idMeetingPwdText.text, idMeetingSettingCheck.checked, idLiveSettingCheck.checked, idLiveAccessCheck.checked, meetingManager.isSupportRecord)
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
                }
            }

            Connections {
                target: meetingManager
                onScheduleSignal: {
                    idSubmit.enabled = true
                    console.info("Schedule meeting callback, error code:", errorCode, ", error message:", errorMessage)
                    if (0 !== errorCode) {
                        idScheduleWindow.idMessage.error(errorMessage)
                    } else {
                        idScheduleWindow.close()
                        message.info(qsTr("Schedule meeting successfully."))
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
                const curTime = new Date()

                // 如果是今天，则获取当前时间点的下一个半点的索引
                const dateTmp = new Date(idStartDate.currentDate)
                if (dateTmp.toDateString() === curTime.toDateString()) {
                    start = curTime.getHours() * 2 + (curTime.getMinutes() < 30 ? 1 : 2)
                }

                // 限定最大时间
                if (end >= idProperty.timeArray.length) {
                    end = idProperty.timeArray.length - 1
                }

                // 获取上次选中的时间
                var lastText = idComBoxStartTime.text

                // console.log("start, end:", start, end)
                var arrayTmp = new Array
                for (let i = start; i <= end; i++) {
                    arrayTmp.push(idProperty.timeArray[i])
                }
                idComBoxStartTime.listModel = arrayTmp

                var lastIndex = 0
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
                var lastText = idComBoxEndTime.text

                // console.log("start, end:", start, end)
                var arrayTmp = new Array
                for (let i = start; i <= end; i++) {
                    arrayTmp.push(idProperty.timeArray[i])
                }
                idComBoxEndTime.listModel = arrayTmp
                // console.log("idComBoxEndTime.listModel:", idComBoxEndTime.listModel)

                var lastIndex = 0
                idComBoxEndTime.listModel.some(function(item, index){
                    if (item === lastText) {
                        lastIndex = index
                        return
                    }
                })
                // console.log("lastIndex", lastIndex)
                idComBoxEndTime.currentIndex = lastIndex
            }
        }
    }
}
