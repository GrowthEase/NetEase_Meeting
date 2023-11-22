import QtQuick
import QtQuick.Controls
import QtQuick.Window 2.12
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../components"

CustomTextFieldEx {
    id: idRoot

    property alias currentIndex: listView.currentIndex
    property alias listModel: listView.model

    acceptToolClickOnly: true
    visibleComboBox: true

    ToastManager {
        id: toast
    }

    onComboBoxOpenImageClicked: {
        if (idPopup.visible) {
            idPopup.close();
            return;
        }
        var meetingList = historyManager.getRecentMeetingList();
        listModel.clear();
        for (var i = 0; i < meetingList.length; i++) {
            const meeting = meetingList[i];
            listModel.append(meeting);
        }
        idPopup.x = 0;
        idPopup.y = idRoot.height + 8;
        idPopup.open();
    }

    Popup {
        id: idPopup
        bottomInset: 0
        height: listView.count > 5 ? (5 * 36 + 57) : (listView.count * 36 + 57)
        leftInset: 0
        padding: 0
        rightInset: 0
        topInset: 0
        width: idRoot.width

        background: Rectangle {
            id: idBackground
            border.color: "#EBEDF0"
            border.width: 1
            layer.enabled: true
            radius: 2

            layer.effect: DropShadow {
                color: "#1917171a"
                height: idBackground.height
                radius: 6
                samples: 16
                source: idBackground
                verticalOffset: 2
                visible: idBackground.visible
                width: idBackground.width
                x: idBackground.x
                y: idBackground.y
            }
        }

        onAboutToHide: {
            visibleComboBoxOpen = false;
        }
        onAboutToShow: {
            visibleComboBoxOpen = true;
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1

            ListView {
                id: listView
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 6
                clip: true
                height: count > 5 ? 5 * 36 : count * 36
                width: 326

                ScrollBar.vertical: ScrollBar {
                    id: idVScrollBar
                    visible: listView.count > 5
                    width: 5
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
                        color: parent.hovered ? "#f2f3f5" : "#ffffff"

                        Label {
                            id: idSubject
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            color: itemDelegate.hovered ? "#337EFF" : "#333333"
                            elide: Label.ElideRight
                            text: model.meetingSuject
                            width: parent.width / 2
                        }
                        Label {
                            id: idMeetingNum
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            color: itemDelegate.hovered ? "#337EFF" : "#666666"
                            text: prettyConferenceId(model.meetingID)
                        }
                    }
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            idRoot.text = model.meetingID;
                            idPopup.close();
                        }
                    }
                }
                model: ListModel {
                    id: listModel
                }
            }
            Rectangle {
                id: line
                anchors.left: listView.left
                anchors.top: listView.bottom
                anchors.topMargin: 6
                color: '#EBEDF0'
                height: 1
                width: parent.width
            }
            Rectangle {
                anchors.left: line.left
                anchors.top: line.bottom
                height: 44
                width: parent.width

                Label {
                    id: idcClear
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    color: idcClearArea.containsMouse ? "#337eff" : "#666666"
                    text: qsTr("Clear history")

                    MouseArea {
                        id: idcClearArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        historyManager.clearRecentMeetingList();
                        listModel.clear();
                        idRoot.acceptToolClickOnly = false;
                        idRoot.visibleComboBox = false;
                        idPopup.close();
                        toast.show(qsTr("History cleared"));
                    }
                }
            }
        }
    }
}
