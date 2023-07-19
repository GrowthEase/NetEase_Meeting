import QtQuick 2.15
import QtQuick.Controls 1.4
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.12
import NetEase.Meeting.HistoryModel 1.0

import "../components"

CustomWindow {
    id: idHistoryWindow
    idLoader.sourceComponent: idComponent
    title: qsTr("History Meeting")
    customWidth: 800
    customHeight: 598

    Component.onCompleted: {
        idLoader.item.initTab()
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

    Component{
        id: historyView;
        HistoryTableView {
            anchors.fill: parent
            dataModel: historyModel
        }
    }

    Component{
        id: collectView;
        HistoryTableView {
            anchors.fill: parent
            dataModel: collectModel
        }
    }

    Component {
        id: idComponent
        Rectangle {
            id: rect
            function initTab() {
                tabview.addTab(qsTr("All meetings"), historyView)
                tabview.addTab(qsTr("Collect meetings"), collectView)
            }

            function initData() {
                historyManager.refreshHistoryMeetingList()
                historyManager.refreshCollectMeetingList()
            }

            TabView {
                id: tabview
                anchors.fill: parent
                anchors.margins: 30
                visible: historyManager.count > 0
                style: TabViewStyle {
                    tabsAlignment: Qt.AlignHCenter
                    frameOverlap: -30
                    tab: Rectangle {
                        color: styleData.selected ? "#337eff" :"#eef0f3"
                        implicitWidth: 104
                        implicitHeight: 32
                        radius: 4
                        Label {
                            id: text
                            anchors.centerIn: parent
                            text: styleData.title
                            font.pixelSize: 14
                            color: styleData.selected ? "#ffffff" : "#333333"
                        }
                    }
                }

                onCurrentIndexChanged: {
                    if(currentIndex == 0) {
                        historyManager.refreshHistoryMeetingList()
                    } else {
                        historyManager.refreshCollectMeetingList()
                    }
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
