import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.settings 1.0
import "components/"
import "schedule/"
import "history/"
import "profile/"

Item {
    id: frontPage

    enum PopupMode {
        CreateMode,
        JoinMode
    }

    property alias appList: appList
    property alias appTipArea: idAppTipArea
    property alias btnJoinPopupClose: btnJoinPopupClose
    property alias btnPopupClose: btnPopupClose
    property alias btnScheduleMeeting: btnScheduleMeeting
    property alias buttonSubmit: buttonSubmit
    property alias checkMeetingPwd: idMeetingPwdCheck
    property alias checkOpenCamera: checkOpenCamera
    property alias checkOpenMicrophone: checkOpenMicrophone
    property alias checkUsePersonalId: checkUsePersonalId
    property alias createButton: createButton
    property alias customDialog: customDialog
    property alias feedback: feedback
    property alias historyPopup: historyPopup
    property alias idHistoryMeeting: idHistoryMeeting
    property alias idScheduleDetailsWindow: idScheduleDetailsWindow
    property alias idScheduleMeeting: idScheduleMeeting
    property alias infoArea: infoArea
    property alias infoImage: infoImage
    property alias inputMeetingPwd: idMeetingPwdText
    property alias joinButton: joinButton
    property int lastLengthOfMeetingId: 0
    property alias listModel: listModel
    property alias messageTip: idMessage
    property alias npsWindow: npsWindow
    property alias personalMeetingId: personalMeetingId
    property var popupMode: FrontPage.CreateMode
    property alias popupWindow: popupWindow
    property alias profile: profile
    property alias scheduleList: scheduleList
    property alias textMeetingId: textMeetingId
    property alias tooltips: tooltips

    anchors.fill: parent

    Settings {
        property alias localCameraStatusEx: checkOpenCamera.checked
        property alias localMicStatusEx: checkOpenMicrophone.checked
    }
    ScheduleWindow {
        id: idScheduleMeeting

    }
    HistoryWindow {
        id: idHistoryMeeting

    }
    ScheduleDetailsWindow {
        id: idScheduleDetailsWindow

    }
    CustomDialog {
        id: customDialog

    }
    Feedback {
        id: feedback

    }
    NPSWindow {
        id: npsWindow

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2 - 20
    }
    ProfileWindow {
        id: profile

        screen: mainWindow.screen
    }
    AppList {
        id: appList

        anchors.centerIn: parent
    }
    CustomTipArea {
        id: idAppTipArea

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: frontPage.top
        anchors.topMargin: 0
        visible: false
        width: 655
        z: 2
    }

    //    RecentHistoryPopup
    CustomPopup {
        id: historyPopup

        height: 600
        width: 400
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2 - 20
    }
    GridLayout {
        anchors.centerIn: parent
        anchors.margins: 50
        columnSpacing: 20
        columns: 2

        Rectangle {
            Layout.preferredHeight: 400
            Layout.preferredWidth: 400

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 125
                spacing: 50

                ColumnLayout {
                    spacing: 0

                    Image {
                        id: createImage

                        Accessible.name: createmeetingLabel.text
                        Accessible.role: Accessible.Button
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 117
                        Layout.preferredWidth: 117
                        mipmap: true
                        source: "qrc:/qml/images/front/create_meeting.png"

                        Accessible.onPressAction: if (createButton.enabled)
                            createButton.clicked(Qt.LeftButton)

                        MouseArea {
                            id: createButton

                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                    Label {
                        id: createmeetingLabel

                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 16
                        text: qsTr("Create Meeting")
                    }
                }
                ColumnLayout {
                    spacing: 0

                    Image {
                        id: joinImage

                        Accessible.name: joinmeetingLabel.text
                        Accessible.role: Accessible.Button
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 117
                        Layout.preferredWidth: 117
                        mipmap: true
                        source: "qrc:/qml/images/front/join_meeting.png"

                        Accessible.onPressAction: if (joinButton.enabled)
                            joinButton.clicked(Qt.LeftButton)

                        MouseArea {
                            id: joinButton

                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                    Label {
                        id: joinmeetingLabel

                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 16
                        text: qsTr("Join Meeting")
                    }
                }
            }
        }
        Rectangle {
            Layout.preferredHeight: 400
            Layout.preferredWidth: 400
            Layout.topMargin: 20

            ListView {
                id: scheduleList

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                height: childrenRect.height > parent.height ? parent.height : childrenRect.height
                spacing: 10
                width: parent.width

                ScrollBar.vertical: ScrollBar {
                    width: 7
                }
                delegate: ScheduleItem {
                    enableLive: model.enableLive
                    endTime: model.endTime
                    height: model.showDatetime ? 115 : 72
                    liveAccess: model.liveAccess
                    liveUrl: model.liveUrl
                    meetingId: model.meetingId
                    meetingInviteUrl: model.inviteUrl
                    meetingPassword: model.password
                    meetingStatus: model.status
                    meetingTopic: model.topic
                    recordEnable: model.recordEnable
                    showDatetime: model.showDatetime
                    startTime: model.startTime
                    uniqueMeetingId: model.uniqueMeetingId
                    width: 380
                }
                model: ListModel {
                    id: listModel

                }
            }
            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 60
                spacing: 0
                visible: scheduleList.count === 0

                Image {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 180
                    Layout.preferredWidth: 180
                    mipmap: true
                    source: "qrc:/qml/images/front/meeting_list.png"
                }
                Label {
                    id: idMeetingTip

                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 14
                    text: qsTr("There are no forthcoming meetings at present")
                }
                Item {
                    Layout.preferredHeight: 20
                }
                CustomButton {
                    id: btnScheduleMeeting

                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 120
                    highlighted: true
                    text: qsTr("Schedule")
                }
            }
        }
    }
    CustomPopup {
        id: popupWindow

        bottomInset: 0
        bottomMargin: 10
        bottomPadding: 0
        // height: popupMode === FrontPage.JoinMode ? 297 : 329
        height: popupLayout.height
        leftInset: 0
        leftPadding: 0
        rightInset: 0
        rightPadding: 0
        topInset: 0
        topPadding: 0
        width: 400
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2 - 20

        MessageManager {
            id: idMessage

        }
        CustomPopup {
            id: tooltips

            height: 82
            padding: 10
            width: 180

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Label {
                    color: '#333333'
                    font.pixelSize: 12
                    text: qsTr('Inner meeting ID:')
                }
                TextArea {
                    Layout.preferredWidth: parent.width
                    background: null
                    color: '#333333'
                    font.pixelSize: 12
                    text: qsTr('Can only be used inside the company')
                    wrapMode: Text.WrapAnywhere
                }
            }
        }
        ColumnLayout {
            id: popupLayout

            spacing: 0
            width: parent.width

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: '#2c2c2c'
            }
            DragArea {
                id: btnPopupClose

                Layout.fillWidth: true
                Layout.preferredHeight: 50
                title: qsTr('Create Now')
                titleFontSize: 18
                visible: popupMode === FrontPage.CreateMode
                windowMode: false
            }
            DragArea {
                id: btnJoinPopupClose

                Layout.fillWidth: true
                Layout.preferredHeight: 50
                title: qsTr('Join Now')
                titleFontSize: 18
                visible: popupMode === FrontPage.JoinMode
                windowMode: false
            }
            ColumnLayout {
                Layout.bottomMargin: 36
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.leftMargin: 36
                Layout.rightMargin: 36
                Layout.topMargin: 30
                spacing: 0

                CustomHistoryComboBox {
                    id: textMeetingId

                    Layout.bottomMargin: 0
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 328
                    Layout.topMargin: 10
                    font.pixelSize: 14
                    placeholderText: qsTr("Meeting ID")
                    visible: popupMode === FrontPage.JoinMode
                }
                Label {
                    color: '#222222'
                    font.pixelSize: 16
                    text: qsTr('Using personal ID')
                    visible: popupMode === FrontPage.CreateMode
                }
                RowLayout {
                    Layout.topMargin: 10
                    visible: popupMode === FrontPage.CreateMode

                    CustomCheckBox {
                        id: checkUsePersonalId

                        font.weight: Font.Light
                        text: qsTr("Using personal ID: ")
                    }
                    Label {
                        font.weight: Font.Light
                        text: authManager.personalShortMeetingNum === '' ? authManager.prettyMeetingId : ''

                        MouseArea {
                            id: personalMeetingId

                            anchors.fill: parent
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: 24
                    Layout.topMargin: 15
                    spacing: 10
                    visible: popupMode === FrontPage.CreateMode && authManager.personalShortMeetingNum !== ''

                    RowLayout {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 300
                        visible: authManager.personalShortMeetingNum.length > 0

                        Label {
                            color: '#999999'
                            font.pixelSize: 14
                            text: qsTr('Short ID')
                        }
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: 20
                            Layout.preferredWidth: 64
                            border.color: '#33337EFF'
                            border.width: 1
                            color: '#19337EFF'

                            Label {
                                anchors.centerIn: parent
                                color: '#337EFF'
                                font.pixelSize: 12
                                text: qsTr('Only Inner')
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Label {
                            color: '#999999'
                            font.pixelSize: 14
                            text: authManager.personalShortMeetingNum
                        }
                        Image {
                            id: infoImage

                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: 16
                            Layout.preferredWidth: 16
                            mipmap: true
                            source: 'qrc:/qml/images/front/short_id_info.svg'

                            MouseArea {
                                id: infoArea

                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 300

                        Label {
                            color: '#999999'
                            font.pixelSize: 14
                            text: qsTr('Long ID')
                        }
                        Label {
                            Layout.alignment: Qt.AlignRight
                            color: '#999999'
                            font.pixelSize: 14
                            text: meetingManager.prettyMeetingId
                        }
                    }
                }
                Label {
                    Layout.topMargin: 26
                    color: '#222222'
                    font.pixelSize: 16
                    text: qsTr('Meeting password')
                    visible: popupMode === FrontPage.CreateMode
                }
                RowLayout {
                    Layout.topMargin: 14
                    spacing: 10
                    visible: popupMode === FrontPage.CreateMode

                    CustomCheckBox {
                        id: idMeetingPwdCheck

                        font.pixelSize: 14
                        font.weight: Font.Light
                        text: qsTr("Use Password")
                    }
                    CustomTextFieldEx {
                        id: idMeetingPwdText

                        Layout.fillWidth: true
                        enabled: false
                        placeholderText: qsTr("Please enter 6-digit password")
                        text: ""

                        validator: RegularExpressionValidator {
                            regularExpression: /[0-9]{6}/
                        }
                    }
                }
                Label {
                    Layout.topMargin: 26
                    color: '#222222'
                    font.pixelSize: 16
                    text: qsTr('Meeting Setting')
                    visible: popupMode === FrontPage.CreateMode
                }
                CustomCheckBox {
                    id: checkOpenCamera

                    Layout.topMargin: 14
                    font.weight: Font.Light
                    text: qsTr("Open camera")
                }
                CustomCheckBox {
                    id: checkOpenMicrophone

                    Layout.topMargin: 15
                    font.weight: Font.Light
                    text: qsTr("Open microphone")
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#EBEDF0"
            }
            CustomButton {
                id: buttonSubmit

                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.bottomMargin: 10
                Layout.preferredHeight: 36
                Layout.preferredWidth: 120
                Layout.topMargin: 10
                enabled: popupMode === FrontPage.JoinMode ? textMeetingId.length >= 1 : true
                highlighted: true
            }
        }
    }
}
