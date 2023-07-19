import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NetEase.Meeting.MeetingStatus 1.0

Popup {
    id: idNetWorkQualityInfo
    width: 200
    height: netWorkQualityInfoContainer.height + 50 // incldue top and bottom padding
    padding: 25
    background: Rectangle {
        radius: 10
    }

    Component.onCompleted: {
    }

    function startClose() {
        idInfomationClose.start()
    }

    function stopClose() {
        idInfomationClose.stop()
    }

    onClosed: {
        idNetWorkQualityInfo.closePolicy = Popup.CloseOnEscape | Popup.CloseOnPressOutside
    }

    MouseArea {
        id: idInfomation
        anchors.centerIn: parent
        width: parent.width + 50
        height: parent.height + 50
        hoverEnabled: true
        onExited: {
            idInfomationClose.stop()
            close()
        }
    }

    Timer {
        id: idInfomationClose
        repeat: false
        interval: 1000
        onTriggered: {
            if (!idInfomation.containsMouse) {
                close()
            }
        }
    }

    Connections {
        target: meetingManager
        onRtcStateChanged: {
            const rtcState = meetingManager.rtcState
            delay.text = rtcState["downRtt"] + "ms"
            upPacketLoss.text = rtcState["txPacketLossRate"] + "%"
            downPacketLoss.text = rtcState["rxPacketLossRate"] + "%"
        }
    }

    ColumnLayout {
        id: netWorkQualityInfoContainer
        height: childrenRect.height
        width: parent.width
        spacing: 15
        Label {
            text: {
                const netWorkQualityType = membersManager.netWorkQualityType
                if (MeetingStatus.NETWORKQUALITY_GOOD === netWorkQualityType) {
                    return qsTr("The network connection is good")
                } else if (MeetingStatus.NETWORKQUALITY_GENERAL === netWorkQualityType) {
                    return qsTr("The network connection is general")
                } else if (MeetingStatus.NETWORKQUALITY_BAD === netWorkQualityType) {
                    return qsTr("The network connection is poor")
                } else {
                    return qsTr("The network connection is unknown")
                }
            }
            font.pixelSize: 20
            color: '#333333'
            wrapMode: Text.WrapAnywhere
            Layout.maximumWidth: 320
            Layout.fillWidth: true
        }
        RowLayout {
            Label {
                text: qsTr('Delay:')
                font.pixelSize: 12
                color: '#94979A'
                Layout.preferredWidth: 100
            }
            Label {
                id: delay
                text: "0ms"
                font.pixelSize: 12
                color: '#94979A'
            }
        }
        RowLayout {
            Label {
                text: qsTr('Packet Loss:')
                Layout.alignment: Qt.AlignTop
                font.pixelSize: 12
                color: '#94979A'
                Layout.preferredWidth: 100
            }
            ColumnLayout {
                RowLayout {
                    spacing: 5
                    Label {
                        text: "↑"
                        font.pixelSize: 12
                        color: '#2972F6'
                    }
                    Label {
                        id: upPacketLoss
                        text: "0%"
                        font.pixelSize: 12
                        color: '#94979A'
                    }
                }

                RowLayout {
                    spacing: 5
                    Label {
                        text: "↓"
                        font.pixelSize: 12
                        color: '#5CC871'
                    }
                    Label {
                        id: downPacketLoss
                        text: "0%"
                        font.pixelSize: 12
                        color: '#94979A'
                    }
                }
            }
        }
    }
}
