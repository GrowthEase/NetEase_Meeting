import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Button {
    property var normalColor: ""
    property var pressedColor: ""
    property var hAlignment: Text.AlignHLeft
    padding: 0
    topInset: 0
    bottomInset: 0
    leftInset: 0
    rightInset: 0

    id: control
    font.pixelSize: 12
    contentItem: Label {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: normalColor === "" ? (control.down ? "#1296db" : "#337EFF") : (control.down ? pressedColor : normalColor)
        horizontalAlignment: control.hAlignment
        verticalAlignment: Label.AlignVCenter

        Accessible.role: Accessible.Button
        Accessible.name: text
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }
    background: Rectangle {
        color: "#00000000"
        radius: 4
    }
}
