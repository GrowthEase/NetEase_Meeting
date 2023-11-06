import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

CheckBox {
    id: control
    topInset: 0
    bottomInset: 0
    leftInset: 0
    rightInset: 0
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    contentItem: Label {
        text: control.text
        font: control.font
        color: "#5c98ff"
        verticalAlignment: Text.AlignVCenter
        leftPadding: indicatorItem.width + 4
        Accessible.role: Accessible.Button
        Accessible.name: text
        Accessible.onPressAction: if (enabled) toggle()
    }
    indicator: Rectangle {
        id: indicatorItem
        implicitWidth: 18
        implicitHeight: 18
        color: "transparent"
        Image {
            id: checkImage
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2 + 2
            width: 14
            height: 14
            source: control.checkState === Qt.Checked ? "qrc:/qml/images/public/icons/Vector_select.png" : "qrc:/qml/images/public/icons/Vector_normal.png"
            mipmap: true
            fillMode: Image.PreserveAspectFit
        }
    }
}
