import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Qt5Compat.GraphicalEffects

import '../components'

Popup {
    id: root
    height: 265
    width: 350
    padding: 0
    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0
    modal: true
    dim: false

    property var contentText: ""
    property var titleText: qsTr('Permission')
    signal sigOpenSetting

    background: Rectangle {
        id: backgroundRect
        radius: Qt.platform.os === 'windows' ? 0 : 10
        border.width: 1
        border.color: "#EBEDF0"
        layer.enabled: true
        layer.effect: DropShadow {
            width: backgroundRect.width
            height: backgroundRect.height
            x: backgroundRect.x - 2
            y: backgroundRect.y - 2
            visible: backgroundRect.visible
            source: backgroundRect
            horizontalOffset: 0
            verticalOffset: 0
            radius: 16
            samples: 33
            color: "#1917171a"
        }
    }

    ColumnLayout {
        id: contentContainer
        spacing: 0
        anchors.fill: parent

        DragArea {
            Layout.preferredHeight: 54
            Layout.preferredWidth: parent.width
            windowMode: false
            title: titleText
            onCloseClicked: root.close()
        }

        TextArea {
            id: content
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.fillHeight: true
            Layout.fillWidth: true
            selectByMouse: true
            selectByKeyboard: true
            enabled: false
            color: '#222222'
            background: Rectangle {

            }
            wrapMode: Text.WrapAnywhere
            text: contentText
        }

        Rectangle {
            color: '#EBEDF0'
            Layout.fillWidth: true
            Layout.preferredHeight: 1
        }

        CustomButton {
            id: btnOpenSettings
            text: qsTr('Open Settings')
            highlighted: true
            Layout.preferredHeight: 36
            Layout.preferredWidth: 135
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            onClicked: {
                sigOpenSetting()
                enabled = false
                enableTimer.start()
            }
        }
    }

    Timer {
        id: enableTimer
        repeat: false
        running: false
        interval: 3000
        onTriggered: {
            btnOpenSettings.enabled = true
        }
    }
}
