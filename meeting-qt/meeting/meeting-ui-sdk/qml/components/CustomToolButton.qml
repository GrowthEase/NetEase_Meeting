import QtQuick
import QtQuick.Controls

ToolButton {
    enum Direction {
        Left,
        Right,
        Up,
        Down
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
        mipmap: true
        source: {
            switch (root.direction) {
            case CustomToolButton.Direction.Left:
                return "qrc:/qml/images/public/button/btn_left_white.svg"
            case CustomToolButton.Direction.Right:
                return "qrc:/qml/images/public/button/btn_right_white.svg"
            case CustomToolButton.Direction.Up:
                return "qrc:/qml/images/public/button/btn_up_white.svg"
            case CustomToolButton.Direction.Down:
                return "qrc:/qml/images/public/button/btn_down_white.svg"
            }
        }
    }
}
