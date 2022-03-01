import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12

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
        color: "#333333"
        verticalAlignment: Text.AlignVCenter
        leftPadding: indicatorItem.width + 8

        Accessible.role: Accessible.Button
        Accessible.name: text
        Accessible.onPressAction: if (enabled) toggle()
    }
    indicator: Rectangle {
        id: indicatorItem
        implicitWidth: 16
        implicitHeight: 16
        color: !control.enabled ? "#F2F2F5" : "transparent"
        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        border.color: (checkState !== Qt.Unchecked && control.enabled ) ? control.Material.accentColor : "#E1E3E6"
        border.width: checkState !== Qt.Unchecked ? width / 2 : 1
        radius: 2

        Behavior on border.color {
            ColorAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }

        // TODO: This needs to be transparent
        Image {
            id: checkImage
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 11
            height: 11
            source: "qrc:/qml/images/public/icons/right_white.svg"
            fillMode: Image.PreserveAspectFit

            scale: control.checkState === Qt.Checked ? 1 : 0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 12
            height: 3

            scale: control.checkState === Qt.PartiallyChecked ? 1 : 0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        states: [
            State {
                name: "checked"
                when: control.checkState === Qt.Checked
            },
            State {
                name: "partiallychecked"
                when: control.checkState === Qt.PartiallyChecked
            }
        ]

        transitions: Transition {
            SequentialAnimation {
                NumberAnimation {
                    target: indicatorItem
                    property: "scale"
                    // Go down 2 pixels in size.
                    to: 1 - 2 / indicatorItem.width
                    duration: 120
                }
                NumberAnimation {
                    target: indicatorItem
                    property: "scale"
                    to: 1
                    duration: 120
                }
            }
        }
    }
}
