import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NetEase.Meeting.MeetingStatus 1.0

Popup {
    id: idNetWorkQualityInfo
    function startClose() {
        idInfomationClose.start();
    }
    function stopClose() {
        idInfomationClose.stop();
    }

    height: netWorkQualityInfoContainer.height + 50 // incldue top and bottom padding
    padding: 25
    width: 200

    background: Rectangle {
        radius: 10
    }

    Component.onCompleted: {
    }
    onClosed: {
        idNetWorkQualityInfo.closePolicy = Popup.CloseOnEscape | Popup.CloseOnPressOutside;
    }

    MouseArea {
        id: idInfomation
        anchors.centerIn: parent
        height: parent.height + 50
        hoverEnabled: true
        width: parent.width + 50

        onExited: {
            idInfomationClose.stop();
            close();
        }
    }
    Timer {
        id: idInfomationClose
        interval: 1000
        repeat: false

        onTriggered: {
            if (!idInfomation.containsMouse) {
                close();
            }
        }
    }
    Connections {
        target: meetingManager

        onRtcStateChanged: {
            const rtcState = meetingManager.rtcState;
            delay.text = rtcState["downRtt"] + "ms";
            upPacketLoss.text = rtcState["txPacketLossRate"] + "%";
            downPacketLoss.text = rtcState["rxPacketLossRate"] + "%";
        }
    }
    ColumnLayout {
        id: netWorkQualityInfoContainer
        height: childrenRect.height
        spacing: 15
        width: parent.width

        Label {
            Layout.fillWidth: true
            Layout.maximumWidth: 320
            color: '#333333'
            font.pixelSize: 20
            text: {
                const netWorkQualityType = membersManager.netWorkQualityType;
                switch (netWorkQualityType) {
                case MeetingStatus.NETWORKQUALITY_GOOD:
                    return qsTr("The network connection is good");
                case MeetingStatus.NETWORKQUALITY_GENERAL:
                    return qsTr("The network connection is general");
                case MeetingStatus.NETWORKQUALITY_BAD:
                    return qsTr("The network connection is poor");
                default:
                    return qsTr("The network connection is good");
                }
            }
            wrapMode: Text.WrapAnywhere
        }
        RowLayout {
            Label {
                Layout.preferredWidth: 100
                color: '#94979A'
                font.pixelSize: 12
                text: qsTr('Delay:')
            }
            Label {
                id: delay
                color: '#94979A'
                font.pixelSize: 12
                text: "0ms"
            }
        }
        RowLayout {
            Label {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 100
                color: '#94979A'
                font.pixelSize: 12
                text: qsTr('Packet Loss:')
            }
            ColumnLayout {
                RowLayout {
                    spacing: 5

                    Label {
                        color: '#2972F6'
                        font.pixelSize: 12
                        text: "↑"
                    }
                    Label {
                        id: upPacketLoss
                        color: '#94979A'
                        font.pixelSize: 12
                        text: "0%"
                    }
                }
                RowLayout {
                    spacing: 5

                    Label {
                        color: '#5CC871'
                        font.pixelSize: 12
                        text: "↓"
                    }
                    Label {
                        id: downPacketLoss
                        color: '#94979A'
                        font.pixelSize: 12
                        text: "0%"
                    }
                }
            }
        }
    }
}
