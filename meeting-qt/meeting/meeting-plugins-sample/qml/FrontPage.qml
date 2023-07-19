import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import NEMeeting 1.0

import "components"

Item {
    anchors.fill: parent

    NEMDevices {
        id: nemDevices
        engine: nemEngine
        autoSelectMode: NEMDevices.RECOMMENDED_MODE
    }

    NEMSchedule {
        id: scheduleManager
        engine: nemEngine
    }

    Drawer {
        id: drawer
        edge: Qt.RightEdge
        height: parent.height
        width: 260
        background: Rectangle {
            color: '#ffffff'
        }

        ColumnLayout {
            anchors.fill: parent
            AccountInfo {
                Layout.preferredHeight: 230
                Layout.fillWidth: true
                accountInfo: nemAccount
                onSignOut: auth.signOut()
            }
            DevicesSelector {
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.bottomMargin: 10
                Layout.preferredHeight: 200
                Layout.fillWidth: true
                color: '#ffffff'
            }
        }
    }

    RoundButton {
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        highlighted: true
        text: nemAccount.displayName.substr(0, 1)
        font.pixelSize: 16
        onClicked: {
            drawer.open()
        }
    }

    Dialog {
        id: createDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        parent: Overlay.overlay
        focus: true
        modal: true
        title: "Create meeting"
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            loader.setSource(Qt.resolvedUrl('qrc:/qml/MeetingPage.qml'), {
                                 createMode: true,
                                 meetingId: usePersonalId.checked ? nemAccount.personalId : '',
                                 nickname: nemAccount.displayName,
                                 enableAudio: true,
                                 enableVideo: true
                             })
        }
        ColumnLayout {
            spacing: 20
            anchors.fill: parent
            CheckBox {
                id: usePersonalId
                text: qsTr('Use personal ID: %1').arg(prettyId(nemAccount.personalId))
            }
        }
    }

    Dialog {
        id: joinDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        parent: Overlay.overlay
        focus: true
        modal: true
        title: "Join meeting"
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            loader.setSource(Qt.resolvedUrl('qrc:/qml/MeetingPage.qml'), {
                                 createMode: false,
                                 meetingId: textMeetingId.text,
                                 password: '',
                                 nickname: nemAccount.displayName,
                                 enableAudio: true,
                                 enableVideo: true
                             })
        }
        ColumnLayout {
            spacing: 20
            anchors.fill: parent
            Label {
                elide: Label.ElideRight
                text: "Please enter the meeting ID:"
                Layout.fillWidth: true
            }
            TextField {
                id: textMeetingId
                focus: true
                placeholderText: "Meeting ID"
                Layout.fillWidth: true
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        Item {
            Layout.preferredWidth: parent.width / 2
            Layout.fillHeight: true
            RowLayout {
                anchors.centerIn: parent
                spacing: 45
                ColumnLayout {
                    RoundButton {
                        Layout.preferredHeight: 96
                        Layout.preferredWidth: 96
                        highlighted: true
                        icon.source: 'qrc:/qml/images/meeting-start.svg'
                        onClicked: createDialog.open()
                    }
                    Label {
                        text: qsTr('Create')
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
                ColumnLayout {
                    RoundButton {
                        Layout.preferredHeight: 96
                        Layout.preferredWidth: 96
                        highlighted: true
                        icon.source: 'qrc:/qml/images/meeting-join.svg'
                        onClicked: joinDialog.open()
                    }
                    Label {
                        text: qsTr('Join')
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: parent.width / 2
            ColumnLayout {
                Layout.leftMargin: 10
                Layout.topMargin: 50
                Layout.bottomMargin: 30
                Layout.rightMargin: 50
                visible: scheduleList.count !== 0
                ScheduleListView {
                    id: scheduleList
                    manager: scheduleManager
                    Layout.fillWidth: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    RoundButton {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: 28
                        text: qsTr('\u002b')
                        highlighted: true
                    }
                    RoundButton {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: 28
                        text: qsTr('\u002d')
                        highlighted: true
                    }
                }
            }
            ColumnLayout {
                visible: scheduleList.count === 0
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Image {
                    source: 'qrc:/qml/images/pre-meeting-empty.png'
                }
                Button {
                    text: qsTr('Schedule')
                    highlighted: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
