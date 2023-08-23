import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects

CustomTextFieldEx {
    id: idRoot
    property var aliasName: 'customSelectComboBox'
    property alias listModel: listView.model
    property var checkedItems: []
    property alias currentIndex: listView.currentIndex
    property bool noEdit: false
    property int popupHeight: idPopup.height

    signal sigPressed()
    signal sigConfirm()
    signal sigChecked(bool checked, int index)

    // 隐藏弹窗
    function hidePopup() {
        if (idPopup.visible) {
            idPopup.close()
        }
    }

    readOnly: true
    selectByMouse: false
    visibleComboBox: true

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
        height: listView.count > 7 ? 7 * 40 + 52 + 20 : listView.count * 40 + 52 + 20

        Rectangle {
            anchors.margins: 1
            anchors.fill: parent
            ColumnLayout {
                spacing: 0
                anchors.fill: parent
                anchors.top: parent.top
                anchors.topMargin: 17
                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.preferredHeight: count * 40
                    Layout.maximumHeight: 280
                    clip: true
                    model: listModel
                    delegate: ItemDelegate {
                        height: 40
                        width: listView.width
                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.hovered ? "#F7F8FA" : "#000000"
                        }

                        Rectangle {
                            id: rec
                            anchors.fill: parent
                            CustomCheckBox {
                                anchors.left:  parent.left
                                anchors.leftMargin: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: model.nickname
                                checked: model.checkState === 1
                                onCheckedChanged: {
                                    sigChecked(checked, model.index)
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        id: idVScrollBar
                        width: 5
                        visible: listView.count > 6
                    }
                }
                Rectangle {
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                    color: '#E8E8E8'
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    Label {
                        id: idConfirm
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("comfirm")
                        font.pixelSize: 14
                        color: "#337EFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            sigConfirm()
                            idPopup.close()
                        }
                    }
                }
            }

        }

        onAboutToShow: { visibleComboBoxOpen = true }
        onAboutToHide: { visibleComboBoxOpen = false }
    }

    onPressed: {
        if (noEdit) { return }

        if (idPopup.visible) {
            idPopup.close()
            return
        }

        idPopup.x = 0
        idPopup.y = idRoot.height + 8
        idPopup.open()

        sigPressed()
    }

    Accessible.role: Accessible.Button
    Accessible.name: aliasName
    Accessible.onPressAction: if (enabled) pressed(Qt.LeftButton)
}


