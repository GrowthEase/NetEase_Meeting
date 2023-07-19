import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

import "../components"

CustomTextFieldEx {
    id: idRoot
    property alias listModel: listView.model
    property alias currentIndex: listView.currentIndex

    visibleComboBox: true
    acceptToolClickOnly: true

    Popup {
        id: idPopup
        padding: 0
        leftInset: 0
        rightInset: 0
        topInset: 0
        bottomInset: 0
        background: Rectangle {
            id: idBackground
            radius: 2
            border.width: 1
            border.color: "#EBEDF0"
            layer.enabled: true
            layer.effect: DropShadow {
                width: idBackground.width
                height: idBackground.height
                x: idBackground.x
                y: idBackground.y
                visible: idBackground.visible
                source: idBackground
                verticalOffset: 2
                radius: 6
                samples: 16
                color: "#1917171a"
            }
        }

        width: idRoot.width
        height: listView.count > 5 ? (5 * 36 + 57) : (listView.count * 36 + 57)

        Rectangle {
            anchors.margins: 1
            anchors.fill: parent
            ListView {
                id: listView
                width: 326
                height: count > 5 ? 5 * 36 : count * 36
                clip: true
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 6
                model: ListModel{
                    id: listModel
                }
                delegate: ItemDelegate {
                    id: itemDelegate
                    height: 36
                    width: listView.width
                    background: Rectangle {
                        anchors.fill: parent
                        color: "#ffffff"
                    }

                    Rectangle {
                        id: rec
                        anchors.fill: parent
                        color: parent.hovered ? "#f2f3f5": "#ffffff"
                        Label {
                            id: idSubject
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            text: model.meetingSuject
                            elide: Label.ElideRight
                            width: parent.width / 2
                            color: itemDelegate.hovered ? "#337EFF" : "#333333"
                        }

                        Label {
                            id: idMeetingNum
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            text: prettyConferenceId(model.meetingID)
                            color: itemDelegate.hovered ? "#337EFF" : "#666666"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            idRoot.text = model.meetingID
                            idPopup.close()
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    id: idVScrollBar
                    width: 5
                    visible: listView.count > 5
                }
            }
            Rectangle {
                id: line
                width: parent.width
                height: 1
                anchors.left: listView.left
                anchors.top: listView.bottom
                anchors.topMargin: 6
                color: '#EBEDF0'
            }
            Rectangle {
                width: parent.width
                height: 44
                anchors.left: line.left
                anchors.top: line.bottom
                Label {
                    id: idcClear
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("clear history")
                    color: idcClearArea.containsMouse ? "#337eff" : "#666666"

                    MouseArea {
                        id: idcClearArea
                        hoverEnabled: true
                        anchors.fill: parent
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        historyManager.clearRecentMeetingList()
                        listModel.clear()
                        idRoot.acceptToolClickOnly = false
                        idRoot.visibleComboBox = false
                        idPopup.close()
                    }
                }
            }
        }

        onAboutToShow: { visibleComboBoxOpen = true }
        onAboutToHide: { visibleComboBoxOpen = false }
    }

    onComboBoxOpenImageClicked: {
        if (idPopup.visible) {
            idPopup.close()
            return
        }

        var meetingList = historyManager.getRecentMeetingList();
        listModel.clear()
        for (var i = 0; i < meetingList.length; i++) {
            const meeting = meetingList[i]
            listModel.append(meeting)
        }

        idPopup.x = 0
        idPopup.y = idRoot.height + 8
        idPopup.open()
    }
}


