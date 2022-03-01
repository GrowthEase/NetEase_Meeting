import QtQuick 2.15
import QtQuick.Controls 2.12

CustomTextField {
    property var lastLengthOfNumber: 0
    property var lastChar

    id: control
    selectByMouse: true
    font.pixelSize: 17
    leftPadding: 90
    validator: RegExpValidator {
        regExp: /\d{3}|\d{3}-|\d{3}-\d{4}-|\d{3}-\d{4}-\d{4}/
    }
    onTextChanged: {
        if (control.length > lastLengthOfNumber) {
            if (control.length === 3) {
                control.text = control.text + "-"
            } else if (control.length === 8) {
                control.text = control.text + "-"
            }
        } else {
            if (typeof lastChar !== undefined) {
                if (lastChar === "-") {
                    lastChar = text.substring(text.length - 1)
                    control.text = control.text.substring(0, control.text.length - 1)
                }
            }
        }
        lastLengthOfNumber = control.length
        lastChar = control.text.substring(control.length - 1)
    }
    color: "#FF337EFF"
    text: ""

    ComboBox {
        id: combobox
        editable: true
        height: 48
        width: 75
        model: ListModel {
            id: model
            ListElement { text: "+86" }
            ListElement { text: "+87" }
        }
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        background: Rectangle {
            border.width: 0
        }
        enabled: false
    }

    ToolSeparator {
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: combobox.right
        anchors.leftMargin: -15
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 13
        orientation: Qt.Vertical
    }

    function phonePrefix() {
        return combobox.currentText.replace("+", "")
    }

    function phoneNumber() {
        return control.text.split("-").join("")
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
