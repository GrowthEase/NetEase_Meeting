import QtQuick
import QtQuick.Controls

CustomTextField {
    id: control

    property var lastChar
    property var lastLengthOfNumber: 0

    function phoneNumber() {
        return control.text.split("-").join("");
    }
    function phonePrefix() {
        return combobox.currentText.replace("+", "");
    }

    color: "#FF337EFF"
    font.pixelSize: 17
    leftPadding: 90
    selectByMouse: true
    text: ""

    validator: RegularExpressionValidator {
        regularExpression: /\d{3}|\d{3}-|\d{3}-\d{4}-|\d{3}-\d{4}-\d{4}/
    }

    onTextChanged: {
        if (control.length > lastLengthOfNumber) {
            if (control.length === 3) {
                control.text = control.text + "-";
            } else if (control.length === 8) {
                control.text = control.text + "-";
            }
        } else {
            if (typeof lastChar !== undefined) {
                if (lastChar === "-") {
                    lastChar = text.substring(text.length - 1);
                    control.text = control.text.substring(0, control.text.length - 1);
                }
            }
        }
        lastLengthOfNumber = control.length;
        lastChar = control.text.substring(control.length - 1);
    }

    ComboBox {
        id: combobox
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        anchors.left: parent.left
        editable: true
        enabled: false
        height: 48
        width: 75

        background: Rectangle {
            border.width: 0
        }
        model: ListModel {
            id: model
            ListElement {
                text: "+86"
            }
            ListElement {
                text: "+87"
            }
        }
    }
    ToolSeparator {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 13
        anchors.left: combobox.right
        anchors.leftMargin: -15
        anchors.top: parent.top
        anchors.topMargin: 5
        height: parent.height
        orientation: Qt.Vertical
    }
}
