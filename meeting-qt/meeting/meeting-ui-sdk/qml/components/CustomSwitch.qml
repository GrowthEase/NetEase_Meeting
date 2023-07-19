import QtQuick 2.15
import QtQuick.Controls 2.12

Switch {
    id: control
    indicator: Rectangle {
        implicitWidth: 40
        implicitHeight: 27
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: control.checked ? "#5996FF" : "#cfcfcf"
            }
            GradientStop {
                position: 1.0
                color: control.checked ? "#2575FF" : "#cfcfcf"
            }
        }
        border.color: control.checked ? "#2575FF" : "#cfcfcf"

        Rectangle {
            x: control.checked ? parent.width - width - 2 : 2
            y: 2
            width: 22
            height: 23
            radius: 13
            color: control.checked ? control.down ? "#cccccc" : "#ffffff" : "#ffffff"
        }
    }

    contentItem: Label {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.down ? "#17a81a" : "#21be2b"
        verticalAlignment: Label.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
