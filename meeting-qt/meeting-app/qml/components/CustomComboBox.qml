import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12

CustomTextFieldEx {
    id: idRoot
    property var aliasName: 'customComboBox'    // 起个名称
    property var listModel: []
    property alias currentIndex: listView.currentIndex
    property bool noEdit: false

    // 隐藏弹窗
    function hidePopup() {
        if (idPopup.visible) {
            idPopup.close()
        }
    }

    width: 120
    readOnly: true
    selectByMouse: false

    visibleComboBox: true

    onCurrentIndexChanged: {
        text = (listModel.length > 0 && currentIndex >=0 && currentIndex < listModel.length) ? listModel[currentIndex] : ""
    }

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
        height: (listView.count * 28 + 1 + 8 * 2) > 184 ? 184 : (listView.count * 28 + 1 + 8 * 2)

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            ListView {
                id: listView
                anchors.fill: parent
                anchors.top: parent.top
                anchors.topMargin: 8
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                clip: true
                model: listModel

                delegate: ItemDelegate {
                    height: 28
                    width: listView.width
                    background: Rectangle {
                        anchors.fill: parent
                        color: parent.hovered ? "#F7F8FA" : "#FFFFFF"
                    }

                    Label {
                        id: idLabel
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        text: modelData
                        color: listView.currentIndex === model.index ? "#337EFF" : "#333333"
                    }

                    Image {
                        id: selectedIcon
                        width: 12
                        height: 12
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        source: "qrc:/qml/images/public/icons/right.svg"
                        visible: listView.currentIndex === model.index
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (listView.currentIndex === model.index) { return }

                            listView.currentIndex = model.index
                            idPopup.close()
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    id: idVScrollBar
                    width: 5
                    visible: (listView.count * 28 + 1 + 8 * 2) > 184
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
    }

    Accessible.role: Accessible.Button
    Accessible.name: aliasName
    Accessible.onPressAction: if (enabled) pressed(Qt.LeftButton)
}


