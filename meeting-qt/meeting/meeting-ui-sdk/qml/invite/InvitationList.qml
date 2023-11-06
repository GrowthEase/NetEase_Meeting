import QtQuick
import QtQuick.Window 2.12
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material 2.12
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.InviteModel 1.0

import "../components"

Window {
    id: rootWindow

    width: 400 + 20
    height: 500 + 20
    x: (Screen.width - width) / 2 + Screen.virtualX
    y: (Screen.height - height) / 2 + Screen.virtualY
    color: "#00000000"
    title: qsTr("Add attendees")
    flags: Qt.Window | Qt.FramelessWindowHint

    Material.theme: Material.Light

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        color: "#3217171A"
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    onVisibleChanged: {
        if(visible) {
            inviteManager.getInviteList()
        }
    }

    ToastManager {
        id: toast
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        border.width: 1
        border.color: "#FFFFFF"
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            DragArea {
                id: idTitle
                Layout.preferredHeight: 52
                Layout.fillWidth: true
                title: qsTr("Add attendees") + "(0)"
                onCloseClicked: Window.window.hide()
            }

            ColumnLayout {
                spacing: 0
                Layout.topMargin: 20
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.bottomMargin: 20
                Layout.fillHeight: true
                Layout.preferredHeight: 448
                visible: false

                CustomTextFieldEx {
                    id: idSipNum
                    Layout.fillWidth: true
                    placeholderText: qsTr("SIP Number")
                }

                CustomTextFieldEx {
                    id: idSipAddress
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    placeholderText: qsTr("SIP Address")
                }

                CustomButton {
                    id: idAdd
                    enabled: idSipNum.text.trim() !== '' && idSipAddress.text.trim() !== ''
                    highlighted: true
                    text: qsTr("Add")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.topMargin: 33
                    onClicked: {
                        inviteManager.addSip(idSipNum.text, idSipAddress.text);
                        idSipNum.clear()
                        idSipAddress.clear()
                    }
                }

                Label {
                    id: idList
                    text: qsTr("Invitation List")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.topMargin: 43
                    font.pixelSize: 16
                    color: "#999999"
                }

                InviteModel {
                    id: sipModel
                    manager: inviteManager
                    onModelReset: {
                        idTitle.title = qsTr("Add attendees") + "(" + rowCount() + ")"
                    }
                }

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36 * 5
                    anchors.top: idList.bottom
                    anchors.topMargin: 0
                    clip: true
                    model: sipModel
                    delegate: Rectangle {
                        id: delegate
                        height: 36
                        color: "transparent"
                        Rectangle {
                            width: listView.width - 8
                            height: 36
                            color: "transparent"
                            Label {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                text: model.sipNum.replace(/\r\n/g," ").replace(/\n/g," ")
                                font.pixelSize: 14
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar {
                        width: 5
                    }
                }
            }
        }
    }

    Connections {
        target: inviteManager
        function onError(errorCode, errorMessage) {
            if (200 !== errorCode) {
                toast.show(qsTr("add failed, ") + errorMessage)
            } else {
                toast.show(qsTr("add sucessfull"))
            }
        }
    }

    Connections {
        target: rootWindow
        onClosing: {
            rootWindow.hide()
            close.accepted = false
        }
    }

    Connections{
        target: meetingManager
        onMeetingStatusChanged: {
            switch (status) {
            case MeetingStatus.MEETING_DISCONNECTED:
            case MeetingStatus.MEETING_KICKOUT_BY_HOST:
            case MeetingStatus.MEETING_MULTI_SPOT_LOGIN:
            case MeetingStatus.MEETING_ENDED:
                idSipNum.clear()
                idSipAddress.clear()
                break
            default:
                break
            }
        }
    }
}
