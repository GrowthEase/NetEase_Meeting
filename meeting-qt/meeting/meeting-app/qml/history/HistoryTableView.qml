import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import NetEase.Meeting.HistoryModel 1.0
import "../components"

Rectangle {
    property HistoryModel dataModel: dataModel

    border.color: "#e5e5e5"
    border.width: 1

    MessageManager {
        id: idMessage

    }
    Rectangle {
        id: header

        anchors.margins: 1
        border.color: "#e5e5e5"
        border.width: 1
        color: "#f8f8fa"
        height: 40
        width: parent.width

        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 15
            }
            Label {
                Layout.preferredWidth: 200
                color: "#333333"
                font.pixelSize: 14
                text: qsTr('Subject')
            }
            Label {
                Layout.preferredWidth: 160
                color: "#333333"
                font.pixelSize: 14
                text: qsTr('Start time')
            }
            Label {
                Layout.preferredWidth: 130
                color: "#333333"
                font.pixelSize: 14
                text: qsTr('Meeting ID')
            }
            Label {
                Layout.preferredWidth: 110
                color: "#333333"
                font.pixelSize: 14
                text: qsTr('Creator')
            }
            Label {
                Layout.preferredWidth: 105
                color: "#333333"
                font.pixelSize: 14
                text: qsTr('Collection')
            }
        }
    }
    TableView {
        id: tableView

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.topMargin: 3
        clip: true
        columnSpacing: 1
        model: dataModel
        // interactive: false
        rowSpacing: 1

        ScrollBar.vertical: ScrollBar {
            width: 7
        }
        delegate: Rectangle {
            id: cell

            implicitHeight: 54
            implicitWidth: 150

            Component.onCompleted: {
                switch (column) {
                case 0:
                    cell.implicitWidth = 200;
                    itemText.text = model.subject;
                    break;
                case 1:
                    cell.implicitWidth = 160;
                    itemText.text = model.startTime;
                    break;
                case 2:
                    cell.implicitWidth = 130;
                    itemText.text = prettyConferenceId(model.meetingID);
                    break;
                case 3:
                    cell.implicitWidth = 110;
                    itemText.Layout.preferredWidth = 110;
                    itemText.text = model.creator;
                    break;
                case 4:
                    cell.implicitWidth = 105;
                    itemText.text = model.collect;
                    break;
                }
            }

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0
                width: parent.width

                Label {
                    id: itemText

                    Layout.maximumWidth: 190
                    color: "#333333"
                    elide: Qt.ElideRight
                    font.pixelSize: 14
                    visible: column !== 4
                    wrapMode: Text.NoWrap
                }
                Image {
                    Layout.leftMargin: 8
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    mipmap: true
                    source: 'qrc:/qml/images/public/icons/icon_copy.png'
                    visible: column === 2

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            clipboard.setText(itemText.text);
                            idMessage.info(qsTr('Meeting ID has been copied'));
                        }
                    }
                }
                CustomStarCheckBox {
                    checkState: model.collect ? Qt.Checked : Qt.Unchecked
                    text: model.collect ? qsTr("Cancel") : qsTr("Collect")
                    visible: column === 4

                    onToggled: {
                        var ret = false;
                        if (checked) {
                            ret = historyManager.collect(row, model.uniqueID);
                            if (ret) {
                                idMessage.info(qsTr('Collect success'));
                            } else {
                                idMessage.info(qsTr('Collect failed'));
                            }
                        } else {
                            if (dataModel.dataType == 0) {
                                ret = historyManager.cancelCollectFromHistory(row, model.uniqueID);
                            } else {
                                ret = historyManager.cancelCollectFromCollectList(row, model.uniqueID);
                            }
                            if (ret) {
                                idMessage.info(qsTr('Cancel success'));
                            } else {
                                idMessage.info(qsTr('Cancel failed'));
                            }
                        }
                    }
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                color: "#e5e5e5"
                height: 1
                width: parent.width
            }
        }
    }
}
