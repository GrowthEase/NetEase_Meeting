import QtQuick 2.15
import QtQuick.Controls 2.12

Rectangle {
    property string nickname: ""

    signal click()

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
        text: nickname.substring(0, 1)
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 18
        color: "#FFFFFF"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: click()
    }

    Accessible.role: Accessible.Button
    Accessible.name: "nickName"
    Accessible.onPressAction: if (enabled) click()
}
