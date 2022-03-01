import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

Window {
    id: rootWindow
    width: 10
    height: 10
    flags: Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus
    color: "#00000000"
    visible: false
    readonly property int borderWidth: 4

    Component.onCompleted: {
        shareManager.sharedOutsideWindow(sSOutsideWindow, borderWidth);
    }
    Rectangle {
        id: idRectangle
        anchors.fill: parent
        color: "#00000000"
        border.width: borderWidth
        border.color: "#FF14CCCC"
    }
}
