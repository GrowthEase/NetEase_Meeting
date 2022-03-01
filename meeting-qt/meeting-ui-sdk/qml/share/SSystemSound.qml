import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12

import '../components'

Window {
    id: systemSoundWnd
    width: selector.width
    height: selector.height
    flags: {
        if (Qt.platform.os === 'windows')
            return Qt.SubWindow | Qt.FramelessWindowHint
        else
            return Qt.Tool | Qt.FramelessWindowHint
    }

    color: 'transparent'
    Material.theme: Material.Light

    onVisibleChanged: {
        if (visible)
            systemSoundWnd.visible = true
    }

    onActiveChanged: {
        if (!active)
            systemSoundWnd.visible = false
    }

    onActiveFocusItemChanged: {
        if (!activeFocusItem)
            systemSoundWnd.visible = false
    }

    Item {
        id: selector
        width: 202
        height: 32
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            radius: 4
            Label {
                text: qsTr("Shared computer sound")
                width: 112
                color: "#FFFFFF"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
            }
            Image {
                height: 12
                width: 12
                visible: shareManager.shareSystemSound
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                source: "qrc:/qml/images/public/icons/right_white.svg"
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                shareManager.switchSystemSound(!shareManager.shareSystemSound);
            }
        }
    }
}
