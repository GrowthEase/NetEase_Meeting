import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import NetEase.Meeting.HistoryModel 1.0

import "../components"

Rectangle{
    property HistoryModel dataModel: dataModel
    border.color: "#e5e5e5"
    border.width: 1
    MessageManager {
        id: idMessage
    }
    Rectangle {
        id: header
        width: parent.width
        height: 40
        anchors.margins: 1
        color: "#f8f8fa"
        border.color: "#e5e5e5"
        border.width: 1
        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            Rectangle { Layout.preferredWidth: 15; }
            Label { text: qsTr('Subject'); Layout.preferredWidth: 200; color: "#333333"; font.pixelSize: 14; }
            Label { text: qsTr('Start time'); Layout.preferredWidth: 160; color: "#333333"; font.pixelSize: 14; }
            Label { text: qsTr('Meeting ID'); Layout.preferredWidth: 130; color: "#333333"; font.pixelSize: 14; }
            Label { text: qsTr('Creator'); Layout.preferredWidth: 110; color: "#333333"; font.pixelSize: 14; }
            Label { text: qsTr('Collection'); Layout.preferredWidth: 105; color: "#333333"; font.pixelSize: 14; }
        }
    }
    TableView {
        id: tableView
        clip: true
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 15
        anchors.topMargin: 3
        anchors.bottomMargin: 3
        // interactive: false
        rowSpacing: 1
        columnSpacing: 1
        ScrollBar.vertical: ScrollBar {
            width: 7
        }
        delegate: Rectangle {
            id: cell
            implicitWidth: 150
            implicitHeight: 54
            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                spacing: 0
                Label {
                    id: itemText
                    Layout.maximumWidth: 190
                    elide: Qt.ElideRight
                    color: "#333333"
                    font.pixelSize: 14
                    visible: column !== 4
                }
                Image {
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    Layout.leftMargin: 8
                    source: 'qrc:/qml/images/public/icons/icon_copy.png'
                    mipmap: true
                    visible: column === 2
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            clipboard.setText(itemText.text)
                            idMessage.info(qsTr('Meeting ID has been copied'))
                        }
                    }
                }
                CustomStarCheckBox {
                    text: model.collect ? qsTr("Cancel") : qsTr("Collect")
                    checkState: model.collect ? Qt.Checked : Qt.Unchecked
                    visible: column === 4
                    onToggled: {
                        var ret = false
                        if(checked) {
                            ret = historyManager.collect(row, model.uniqueID)
                            if(ret) {
                                idMessage.info(qsTr('Collect success'))
                            } else {
                                idMessage.info(qsTr('Collect failed'))
                            }
                        } else {
                            if(dataModel.dataType == 0) {
                                ret = historyManager.cancelCollectFromHistory(row, model.uniqueID)
                            } else {
                                ret = historyManager.cancelCollectFromCollectList(row, model.uniqueID)
                            }
                            if(ret) {
                                idMessage.info(qsTr('Cancel success'))
                            } else {
                                idMessage.info(qsTr('Cancel failed'))
                            }
                        }
                    }
                }
            }
            Rectangle {
                color: "#e5e5e5"
                height: 1
                width: parent.width
                anchors.left: parent.left
                anchors.bottom: parent.bottom
            }
            Component.onCompleted: {
                switch (column) {
                case 0:
                    cell.implicitWidth = 200
                    itemText.text = model.subject
                    break
                case 1:
                    cell.implicitWidth = 160
                    itemText.text = model.startTime
                    break
                case 2:
                    cell.implicitWidth = 130
                    itemText.text = prettyConferenceId(model.meetingID)
                    break
                case 3:
                    cell.implicitWidth = 110
                    itemText.text = model.creator
                    break
                case 4:
                    cell.implicitWidth = 105
                    itemText.text = model.collect
                    break
                }
            }
        }
        model: dataModel
    }
}
