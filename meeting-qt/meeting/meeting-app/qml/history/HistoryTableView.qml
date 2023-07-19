import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls 1.4
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import NetEase.Meeting.HistoryModel 1.0
import QtQuick.Controls.Styles 1.4

import "../components"

Rectangle{
    property HistoryModel dataModel: dataModel

    MessageManager {
        id: idMessage
    }

    TableView {
        id: tableView
        anchors.fill: parent
        clip: true
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        verticalScrollBarPolicy: Qt.ScrollBarAsNeeded

        style: TableViewStyle {
            frame: Rectangle {
                border {
                    color: "#e5e5e5"
                }
                radius: 4
            }

            backgroundColor: "#ffffff"

            incrementControl : Rectangle{
                visible: false
            }

            decrementControl: Rectangle{
                visible: false
            }

            handle: Rectangle{
                x: -3
                implicitWidth: 6
                color: "#cccccc"
                radius: 3
            }

            scrollBarBackground: Rectangle {
                x: -3
                color: "#f1f1f1"
                implicitWidth: 6
            }

            scrollToClickedPosition: true
            transientScrollBars: true
        }

        TableViewColumn{ role: "subject"  ; title: qsTr("subject") ; width: 200; elideMode: Text.ElideRight; movable: false; resizable: false}
        TableViewColumn{ role: "startTime" ; title: qsTr("startTime") ; width: 160; elideMode: Text.ElideRight; movable: false; resizable: false}
        TableViewColumn{ role: "meetingID" ; title: qsTr("meetingID") ; width: 145; elideMode: Text.ElideRight; movable: false; resizable: false}
        TableViewColumn{ role: "creator" ; title: qsTr("creator") ; width: 110; elideMode: Text.ElideRight; movable: false; resizable: false}
        TableViewColumn{ role: "collect" ; title: qsTr("opration") ; width: 105; elideMode: Text.ElideRight; movable: false; resizable: false}

        model: dataModel

        // 设置表头的样式
        headerDelegate: Rectangle {
            height: 40
            color: "#f8f8fa"
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14
                font.pixelSize: 14
                text: styleData.value
                color: "#666666"
            }

            Rectangle {
                color:"#e5e5e5"
                height: 1
                width: parent.width
                anchors.left: parent.left
                anchors.top: parent.top
            }
        }

        rowDelegate: Rectangle {
            height: 54
            color: "transparent"

            Rectangle {
                color:"#e5e5e5"
                height: 1
                width: 705
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.top: parent.bottom
            }
        }

        itemDelegate: Component {
            id: item_delegate
            Loader {
                id:item_loader
                anchors.fill: parent
                anchors.margins: 1
                sourceComponent: {
                    if(styleData.role === "meetingID") {
                        return copy_delegate
                    } else if (styleData.role === "collect"){
                        return collect_delegate
                    }
                    return text_delegate
                }

                Component {
                    id: text_delegate
                    Rectangle {
                        implicitHeight: 54
                        anchors.top: item_loader.Top
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.right: parent.right
                            text: styleData.value
                            color: "#333333"
                            font.pixelSize: 14
                            elide: Text.ElideRight
                        }
                    }
                }

                Component {
                    id: copy_delegate
                    Rectangle {
                        implicitHeight: 54

                        RowLayout {
                            spacing: 8
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            Label {
                                id: idmeetingID
                                text: prettyConferenceId(styleData.value)
                                color: "#333333"
                                font.pixelSize: 14
                            }

                            Image {
                                Layout.preferredHeight: 14
                                Layout.preferredWidth: 14
                                source: 'qrc:/qml/images/public/icons/icon_copy.png'
                                mipmap: true
                                MouseArea {
                                    id: meetingShortIdCopyBtn
                                    anchors.fill: parent
                                    onClicked: {
                                        clipboard.setText(idmeetingID.text)
                                        idMessage.info(qsTr('Meeting ID has been copied'))
                                    }
                                }
                            }
                        }
                    }
                }

                Component {
                    id: collect_delegate
                    Rectangle {
                        implicitHeight: 54
                        RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            CustomStarCheckBox{
                                text: styleData.value === true ? qsTr("cancelCollect") : qsTr("collect")
                                checkState: styleData.value === true ? Qt.Checked : Qt.Unchecked
                                onToggled: {
                                    var ret = false
                                    if(checked) {
                                        ret = historyManager.collect(model.index, model.uniqueID)
                                        if(ret) {
                                            idMessage.info(qsTr('collect success'))
                                        } else {
                                            idMessage.info(qsTr('collect failed'))
                                        }
                                    } else {
                                        if(dataModel.dataType == 0) {
                                            ret = historyManager.cancelCollectFromHistory(model.index, model.uniqueID)
                                        } else {
                                            ret = historyManager.cancelCollectFromCollectList(model.index, model.uniqueID)
                                        }

                                        if(ret) {
                                            idMessage.info(qsTr('cancel success'))
                                        } else {
                                            idMessage.info(qsTr('cancel failed'))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}



