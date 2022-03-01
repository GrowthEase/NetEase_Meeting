import QtQuick 2.15
import QtQuick.Controls 2.12

ToolButton {
    enum Direction {
        Left,
        Right
    }

    property int direction

    id: root

    background: Rectangle {
        radius: parent.height / 2
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: root.down ? "#99FFFFFF" : "#12FFFFFF"
            }
            GradientStop {
                position: 1.0
                color: root.down ? "#99FFFFFF" : "#12FFFFFF"
            }
        }
    }

    Image {
        width: 14
        height: 14
        anchors.centerIn: parent
        source: direction === CustomToolButton.Direction.Left
                ? "qrc:/qml/images/public/button/btn_left_white.svg"
                : "qrc:/qml/images/public/button/btn_right_white.svg"
    }
}
