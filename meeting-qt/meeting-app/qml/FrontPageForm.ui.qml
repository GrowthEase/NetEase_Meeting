import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0

import "components/"
import "schedule/"
import "profile/"

Item {
    id: frontPage
    anchors.fill: parent

    property int lastLengthOfMeetingId: 0
    property var popupMode: FrontPage.CreateMode
    property alias createButton: createButton
    property alias joinButton: joinButton
    property alias popupWindow: popupWindow
    property alias tooltips: tooltips
    property alias infoImage: infoImage
    property alias infoArea: infoArea
    property alias textMeetingId: textMeetingId
    property alias personalMeetingId: personalMeetingId
    property alias checkUsePersonalId: checkUsePersonalId
    property alias checkOpenCamera: checkOpenCamera
    property alias checkOpenMicrophone: checkOpenMicrophone
    property alias buttonSubmit: buttonSubmit
    property alias btnPopupClose: btnPopupClose
    property alias btnJoinPopupClose: btnJoinPopupClose
    property alias customDialog: customDialog
    property alias idScheduleMeeting: idScheduleMeeting
    property alias idScheduleDetailsWindow: idScheduleDetailsWindow
    property alias btnScheduleMeeting: btnScheduleMeeting
    property alias scheduleList: scheduleList
    property alias listModel: listModel
    property alias profile: profile
    property alias feedback: feedback
    property alias appList: appList
    property alias appTipArea: idAppTipArea

    enum PopupMode {
        CreateMode,
        JoinMode
    }

    Settings {
        property alias localCameraStatusEx: checkOpenCamera.checked
        property alias localMicStatusEx: checkOpenMicrophone.checked
    }

    ScheduleWindow {
        id: idScheduleMeeting
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
        visible: false
        width: 655
        anchors.top: frontPage.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    GridLayout {
        anchors.margins: 50
        anchors.centerIn: parent
        columnSpacing: 20
        columns: 2

        Rectangle {
            Layout.preferredWidth: 400
            Layout.preferredHeight: 400

            RowLayout {
                anchors.top: parent.top
                anchors.topMargin: 125
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 50

                ColumnLayout {
                    spacing: 0
                    Image {
                        id: createImage
                        Layout.preferredWidth: 117
                        Layout.preferredHeight: 117
                        Layout.alignment: Qt.AlignHCenter
                        source: "qrc:/qml/images/front/create_meeting.png"
                        MouseArea {
                            id: createButton
                            hoverEnabled: true
                            anchors.fill: parent
                        }
                        Accessible.role: Accessible.Button
                        Accessible.name: createmeetingLabel.text
                        Accessible.onPressAction: if (createButton.enabled) createButton.clicked(Qt.LeftButton)
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
                        Layout.preferredWidth: 117
                        Layout.preferredHeight: 117
                        Layout.alignment: Qt.AlignHCenter
                        source: "qrc:/qml/images/front/join_meeting.png"
                        MouseArea {
                            id: joinButton
                            hoverEnabled: true
                            anchors.fill: parent
                        }
                        Accessible.role: Accessible.Button
                        Accessible.name: joinmeetingLabel.text
                        Accessible.onPressAction: if (joinButton.enabled) joinButton.clicked(Qt.LeftButton)
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
            Layout.topMargin: 20
            Layout.preferredWidth: 400
            Layout.preferredHeight: 400

            ListView {
                id: scheduleList
                height: childrenRect.height > parent.height ? parent.height : childrenRect.height
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                spacing: 10
                model: ListModel {
                    id: listModel
                }
                delegate: ScheduleItem {
                    width: 380
                    height: model.showDatetime ? 115 : 72
                    uniqueMeetingId: model.uniqueMeetingId
                    meetingId: model.meetingId
                    meetingPassword: model.password
                    meetingTopic: model.topic
                    meetingStatus: model.status
                    startTime: model.startTime
                    endTime: model.endTime
                    showDatetime: model.showDatetime
                    enableLive:model.enableLive
                    liveUrl: model.liveUrl
                    liveAccess: model.liveAccess
                    recordEnable: model.recordEnable
                }
                ScrollBar.vertical: ScrollBar {
                    width: 7
                }
            }

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 60
                spacing: 0
                visible: scheduleList.count === 0
                Image {
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 180
                    Layout.alignment: Qt.AlignHCenter
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
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignHCenter
                    highlighted: true
                    text: qsTr("Schedule")
                }
            }
        }
    }

    CustomPopup {
        id: popupWindow
        width: 400
        // height: popupMode === FrontPage.JoinMode ? 297 : 329
        height: popupLayout.height
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        bottomMargin: 10
        topPadding: 0
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0
        topInset: 0
        bottomInset: 0
        leftInset: 0
        rightInset: 0

        CustomPopup {
            id: tooltips
            width: 180
            height: 82
            padding: 10
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                Label {
                    text: qsTr('Inner meeting ID:')
                    font.pixelSize: 12
                    color: '#333333'
                }
                TextArea {
                    text: qsTr('Can only be used inside the company')
                    font.pixelSize: 12
                    color: '#333333'
                    Layout.preferredWidth: parent.width
                    wrapMode: Text.WrapAnywhere
                    background: null
                }
            }
        }

        ColumnLayout {
            id: popupLayout
            width: parent.width
            spacing: 0

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: '#2c2c2c'
            }

            DragArea {
                id: btnPopupClose
                title: qsTr('Create Now')
                visible: popupMode === FrontPage.CreateMode
                windowMode: false
                titleFontSize: 18
                Layout.fillWidth: true
                Layout.preferredHeight: 50
            }

            DragArea {
                id: btnJoinPopupClose
                title: qsTr('Join Now')
                visible: popupMode === FrontPage.JoinMode
                windowMode: false
                titleFontSize: 18
                Layout.fillWidth: true
                Layout.preferredHeight: 50
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.topMargin: 30
                Layout.bottomMargin: 36
                Layout.leftMargin: 36
                Layout.rightMargin: 36
                spacing: 0

                CustomTextFieldEx {
                    id: textMeetingId
                    placeholderText: qsTr("Meeting ID")
                    visible: popupMode === FrontPage.JoinMode
                    font.pixelSize: 14
                    focus: true
                    Layout.topMargin: 10
                    Layout.preferredWidth: 328
                    Layout.preferredHeight: 34
                    Layout.bottomMargin: 0
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
                        text: meetingManager.personalShortMeetingId === '' ? meetingManager.prettyMeetingId : ''
                        font.weight: Font.Light
                        MouseArea {
                            anchors.fill: parent
                            id: personalMeetingId
                        }
                    }
                }

                ColumnLayout {
                    spacing: 10
                    visible: popupMode === FrontPage.CreateMode && meetingManager.personalShortMeetingId !== ''
                    Layout.topMargin: 15
                    Layout.leftMargin: 24
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    RowLayout {
                        visible: meetingManager.personalShortMeetingId.length > 0
                        Layout.fillHeight: true
                        Layout.preferredWidth: 300
                        Label {
                            text: qsTr('Short ID')
                            font.pixelSize: 14
                            color: '#999999'
                        }
                        Rectangle {
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 20
                            Layout.alignment: Qt.AlignVCenter
                            border.width: 1
                            border.color: '#33337EFF'
                            color: '#19337EFF'
                            Label {
                                anchors.centerIn: parent
                                text: qsTr('Only Inner')
                                font.pixelSize: 12
                                color: '#337EFF'
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: meetingManager.personalShortMeetingId
                            font.pixelSize: 14
                            color: '#999999'
                        }
                        Image {
                            id: infoImage
                            Layout.preferredHeight: 16
                            Layout.preferredWidth: 16
                            Layout.alignment: Qt.AlignVCenter
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
                            text: qsTr('Long ID')
                            font.pixelSize: 14
                            color: '#999999'
                        }
                        Label {
                            text: meetingManager.prettyMeetingId
                            font.pixelSize: 14
                            color: '#999999'
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }

                CustomCheckBox {
                    id: checkOpenCamera
                    text: qsTr("Open camera")
                    font.weight: Font.Light
                    Layout.topMargin: 15
                }

                CustomCheckBox {
                    id: checkOpenMicrophone
                    text: qsTr("Open microphone")
                    font.weight: Font.Light
                    Layout.topMargin: 15
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: "#EBEDF0"
            }

            CustomButton {
                id: buttonSubmit
                Layout.preferredHeight: 36
                Layout.preferredWidth: 120
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                highlighted: true
                enabled: popupMode === FrontPage.JoinMode ? textMeetingId.length >= 1 : true
            }
        }
    }
}
