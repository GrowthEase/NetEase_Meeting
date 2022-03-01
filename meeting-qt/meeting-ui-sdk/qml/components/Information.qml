import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NetEase.Meeting.MeetingStatus 1.0

Popup {
    width: 375
    height: meetingInfoContainer.height + 50 // incldue top and bottom padding
    padding: 25
    background: Rectangle {
        radius: 10
    }

    property string meetingId: ''
    property string meetingTopic: ''
    property string meetingPassword: ''
    property string meetingHost: ''
    property string meetingSIPChannelId: ''
    property string meetingshortId: ''
    Component.onCompleted: {

    }

    onMeetingHostChanged: {
        labelHostNick.text = membersManager.getNicknameByAccountId(meetingHost)
    }

    Connections {
        target: membersManager
        onAfterUserJoined: {
            if (accountId === meetingHost) {
                labelHostNick.text = membersManager.getNicknameByAccountId(meetingHost)
            }
        }

        onNicknameChanged:{
            if(accountId === membersManager.hostAccountId){
                labelHostNick.text = nickname
            }
        }
    }

    ColumnLayout {
        id: meetingInfoContainer
        height: childrenRect.height
        width: parent.width
        spacing: 15
        Label {
            text: meetingTopic
            font.pixelSize: 20
            color: '#333333'
            wrapMode: Text.WrapAnywhere
            // elide: Text.ElideRight
            Layout.maximumWidth: 320
            Layout.fillWidth: true
        }
        RowLayout {
            Layout.topMargin: -10
            Layout.preferredHeight: 20
            Image {
                Layout.preferredHeight: 15
                Layout.preferredWidth: 15
                source: 'qrc:/qml/images/meeting/information/icon_safety_certificate.png'
            }
            Label {
                text: qsTr('The meeting is being encrypted and protected')
                font.pixelSize: 12
                color: '#94979A'
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: '#F2F3F5'
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            visible: meetingshortId !== '' && (meetingManager.meetingIdDisplayOption === 0 || meetingManager.meetingIdDisplayOption === 2)
            Label {
                text: meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_SHORT_ID_ONLY
                      ? qsTr('Meeting ID')
                      : qsTr('Short ID')
                font.pixelSize: 14
                color: '#94979A'
                Layout.preferredWidth: 120
            }
            Label {
                text: meetingshortId
                font.pixelSize: 14
                color: '#222222'
            }
            Rectangle {
                visible: meetingManager.meetingIdDisplayOption !== MeetingStatus.DISPLAY_SHORT_ID_ONLY
                Layout.preferredWidth: 64
                Layout.preferredHeight: 20
                Layout.leftMargin: 8
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
            Image {
                Layout.preferredHeight: 14
                Layout.preferredWidth: 14
                Layout.leftMargin: 18
                source: 'qrc:/qml/images/meeting/information/icon_copy.png'
                MouseArea {
                    id: meetingShortIdCopyBtn
                    anchors.fill: parent
                    onClicked: {
                        clipboard.setText(meetingshortId)
                        toast.show(qsTr('Meeting link has been copied'))
                    }
                }
                Accessible.role: Accessible.Button
                Accessible.name: "meetingShortIdCopy"
                Accessible.onPressAction: if (enabled) meetingShortIdCopyBtn.clicked(Qt.LeftButton)
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight:true
            spacing: 0
            visible: meetingManager.meetingIdDisplayOption === 1 ||
                     meetingManager.meetingIdDisplayOption === 2 ||
                     (meetingManager.meetingIdDisplayOption === MeetingStatus.DISPLAY_SHORT_ID_ONLY && meetingManager.shortMeetingId === '')
            Label {
                text: qsTr('Meeting ID')
                font.pixelSize: 14
                color: '#94979A'
                Layout.preferredWidth: 120
            }
            Label {
                text: meetingId
                font.pixelSize: 14
                color: '#222222'
            }
            Image {
                Layout.preferredHeight: 14
                Layout.preferredWidth: 14
                Layout.leftMargin: 18
                source: 'qrc:/qml/images/meeting/information/icon_copy.png'
                MouseArea {
                    id: meetingIdCopyBtn
                    anchors.fill: parent
                    onClicked: {
                        clipboard.setText(meetingId)
                        toast.show(qsTr('Meeting link has been copied'))
                    }
                }
                Accessible.role: Accessible.Button
                Accessible.name: "meetingIdCopy"
                Accessible.onPressAction: if (enabled) meetingIdCopyBtn.clicked(Qt.LeftButton)
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            visible: meetingPassword !== ''
            spacing: 0
            Label {
                text: qsTr('Password')
                font.pixelSize: 14
                color: '#94979A'
                Layout.preferredWidth: 120
            }
            Label {
                text: meetingPassword
                font.pixelSize: 14
                color: '#222222'
            }
            Image {
                Layout.preferredHeight: 14
                Layout.preferredWidth: 14
                Layout.leftMargin: 18
                source: 'qrc:/qml/images/meeting/information/icon_copy.png'
                MouseArea {
                    id: meetingPasswordCopyBtn
                    anchors.fill: parent
                    onClicked: {
                        clipboard.setText(meetingPassword)
                        toast.show(qsTr('Meeting password has been copied'))
                    }
                }
                Accessible.role: Accessible.Button
                Accessible.name: "meetingPasswordCopy"
                Accessible.onPressAction: if (enabled) meetingPasswordCopyBtn.clicked(Qt.LeftButton)
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            spacing: 0
            Label {
                text: qsTr('Meeting Host')
                font.pixelSize: 14
                color: '#94979A'
                Layout.preferredWidth: 120
            }
            Label {
                id: labelHostNick
                text: ''
                font.pixelSize: 14
                elide: Text.ElideRight
                Layout.maximumWidth: 210
                color: '#222222'
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            visible: meetingSIPChannelId !== ''
            spacing: 0
            Label {
                text: qsTr('SIP')
                font.pixelSize: 14
                color: '#94979A'
                Layout.preferredWidth: 120
            }
            Label {
                text: meetingSIPChannelId
                font.pixelSize: 14
                color: '#222222'
            }
            Image {
                Layout.preferredHeight: 14
                Layout.preferredWidth: 14
                Layout.leftMargin: 18
                source: 'qrc:/qml/images/meeting/information/icon_copy.png'
                MouseArea {
                    id: meetingSIPCopyBtn
                    anchors.fill: parent
                    onClicked: {
                        clipboard.setText(meetingSIPChannelId)
                        toast.show(qsTr('SIP ID has been copied'))
                    }
                }
                Accessible.role: Accessible.Button
                Accessible.name: "meetingSIPCopy"
                Accessible.onPressAction: if (enabled) meetingSIPCopyBtn.clicked(Qt.LeftButton)
            }
        }
    }
}
