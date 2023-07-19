import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NEMeeting 1.0

ListView {
    id: scheduleList

    property var manager

    clip: true
    Layout.fillWidth: true
    Layout.fillHeight: true
    ScrollBar.vertical: ScrollBar {
        width: 5
    }
    model: NEMScheduleModel {
        id: scheduleModel
        schedule: manager
    }
    delegate: ItemDelegate {
        width: parent.width
        height: 65
        ColumnLayout {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            Label {
                font.weight: Font.Medium
                font.pixelSize: 18
                text: model.topic
                elide: Label.ElideRight
                Layout.leftMargin: 15
                Layout.maximumWidth: parent.width
            }
            RowLayout {
                Layout.leftMargin: 15
                Label {
                    font.weight: Font.Medium
                    font.pixelSize: 12
                    enabled: false
                    text: model.meetingId
                }
                Label {
                    enabled: false
                    font.pixelSize: 12
                    text: `${new Date(model.startTime).toLocaleTimeString()} - ${new Date(model.endTime).toLocaleTimeString()}`
                }
                Label {
                    enabled: false
                    font.pixelSize: 12
                    text: {
                        switch (model.state) {
                        case NEMSchedule.MEETING_STATUS_IDLE:
                            return qsTr('Idle')
                        case NEMSchedule.MEETING_STATUS_STARTED:
                            return qsTr('Started')
                        case NEMSchedule.MEETING_STATUS_ENDED:
                            return qsTr('Ended')
                        default:
                            return qsTr('Unknown')
                        }
                    }
                }
            }
        }
    }
}
