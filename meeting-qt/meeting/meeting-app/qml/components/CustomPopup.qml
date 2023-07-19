import QtQuick 2.15
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Popup {
    modal: true
    dim: false
    focus: true
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
}
