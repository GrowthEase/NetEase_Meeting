import QtQuick 2.15
import QtQuick.Controls 2.12

Slider {
    id: control
    property bool showValue: false
    from: 0
    to: 100
    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: "#F2F2F5"

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: "#337EFF"
            radius: 2
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: control.pressed ? "#f0f0f0" : "#FFFFFF"
        border.color: "#337EFF"
        border.width: 2

        Text {
            id:valueText
            visible: control.pressed && showValue
            anchors.horizontalCenter: handle.horizontalCenter
            anchors.bottom: handle.top
            text: control.value
            font.pixelSize: 14

        }
    }
}
