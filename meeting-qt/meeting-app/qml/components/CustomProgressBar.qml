import QtQuick 2.15
import QtQuick.Controls 2.12

ProgressBar {
    id: control
    from: 0
    to: 100
    background: Rectangle {
        radius: 4
        color: "#F2F2F5"
        implicitWidth: parent.width
        implicitHeight: 8
    }
    contentItem: Item {
        implicitWidth: parent.width
        implicitHeight: 8
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: 4
            color: "#337EFF"
        }
    }
}
