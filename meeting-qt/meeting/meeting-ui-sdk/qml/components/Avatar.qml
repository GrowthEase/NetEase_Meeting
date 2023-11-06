import QtQuick
import QtQuick.Controls

Rectangle {
    property string nickname: ""

    id: root
    width: 32
    height: 32
    radius: 16
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: "#5996FF"
        }
        GradientStop {
            position: 1.0
            color: "#2575FF"
        }
    }

    Label {
        text: nickname
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 12
        color: "#FFFFFF"
    }

}
