import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control

    property var hAlignment: Text.AlignHLeft
    property var normalColor: ""
    property var pressedColor: ""

    bottomInset: 0
    font.pixelSize: 12
    leftInset: 0
    leftPadding: 0
    padding: 0
    rightInset: 0
    rightPadding: 0
    topInset: 0

    background: Rectangle {
        color: "#00000000"
        radius: 4
    }
    contentItem: Label {
        Accessible.name: text
        Accessible.role: Accessible.Button
        color: normalColor === "" ? (control.down ? "#1296db" : "#337EFF") : (control.down ? pressedColor : normalColor)
        font: control.font
        horizontalAlignment: control.hAlignment
        opacity: enabled ? 1.0 : 0.3
        text: control.text
        verticalAlignment: Label.AlignVCenter

        Accessible.onPressAction: if (enabled)
            clicked(Qt.LeftButton)
    }
}
