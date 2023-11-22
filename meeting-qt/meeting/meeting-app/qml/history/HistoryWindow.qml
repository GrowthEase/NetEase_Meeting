import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NetEase.Meeting.HistoryModel 1.0

import "../components"

CustomWindow {
    id: idHistoryWindow
    idLoader.sourceComponent: idComponent
    title: qsTr("History Meeting")
    customWidth: 800
    customHeight: 598

    Component.onCompleted: {
    }

    onVisibleChanged: {
        if(visible) {
            idLoader.item.initData()
        }
    }

    HistoryModel {
        id: historyModel
        manager: historyManager
        dataType: 0
    }

    HistoryModel {
        id: collectModel
        manager: historyManager
        dataType: 1
    }

    Component {
        id: idComponent
        Rectangle {
            id: rect
            function initData() {
                historyManager.refreshHistoryMeetingList()
                historyManager.refreshCollectMeetingList()
            }

            TabBar {
                id: tabview
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 30
                visible: historyManager.count > 0
                TabButton {
                    text: qsTr("All meetings")
                    width: implicitWidth
                    onClicked: {
                        historyManager.refreshHistoryMeetingList()
                        stackLayout.currentIndex = 0
                    }
                }
                TabButton {
                    text: qsTr("Collect meetings")
                    width: implicitWidth
                    onClicked: {
                        historyManager.refreshCollectMeetingList()
                        stackLayout.currentIndex = 1
                    }
                }
            }

            StackLayout {
                id: stackLayout
                anchors.fill: parent
                anchors.topMargin: 50
                anchors.rightMargin: 30
                anchors.bottomMargin: 30
                anchors.leftMargin: 30
                visible: historyManager.count > 0
                HistoryTableView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    dataModel: historyModel
                }
                HistoryTableView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    dataModel: collectModel
                }
            }

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 136
                spacing: 15
                visible: historyManager.count == 0
                Image {
                    id: empty
                    source: "qrc:/qml/images/front/empty.png"
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    font.pixelSize: 16
                    text: qsTr("No historical meeting")
                    Layout.alignment: Qt.AlignHCenter
                    color: "#999999"
                }
            }
        }
    }
}
