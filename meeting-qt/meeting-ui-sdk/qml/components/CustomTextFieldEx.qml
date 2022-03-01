import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

TextField {
    id: control
    property bool visibleCalendar: false
    property bool visibleComboBox: false
    property bool visibleComboBoxOpen: false

    rightPadding: 35
    leftPadding: !visibleCalendar ? 12 : idCalendarImage.width + idCalendarImage.anchors.leftMargin + 8
    selectByMouse: true
    placeholderTextColor: "#B0B6BE"
    color: "#333333"
    topPadding: 0
    bottomPadding: 0
    background: Rectangle {
        implicitHeight: 32
        color: control.enabled ? "transparent" : "#F2F2F5"
        border.width: 1
        border.color: (control.enabled && control.hovered) ? control.Material.accentColor : "#DCDFE5"
        radius: 2
    }

    QtObject {
        id: idQtObject
        property string strPlaceholderText: ""
    }

    onEnabledChanged: {
        if (!control.enabled) {
            idQtObject.strPlaceholderText = control.placeholderText
            control.placeholderText = ""
        } else {
            control.placeholderText = idQtObject.strPlaceholderText
            idQtObject.strPlaceholderText = ""
        }
    }

    ToolButton {
        id: idClearBtn
        width: 32
        height: 32
        anchors.right: control.right
        anchors.rightMargin: 0
        anchors.verticalCenter: control.verticalCenter
        visible: control.length && control.enabled && control.hovered && !control.readOnly
        onClicked: {
            control.clear()
        }
        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qml/images/public/button/btn_clear.svg"
        }
    }

    Image {
        id: idCalendarImage
        width: 12
        height: 12
        visible: visibleCalendar
        anchors.left: control.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/qml/images/public/icons/calendar.svg"
    }

    Image {
        id: idComboBoxOpenImage
        width: 8
        height: 4
        anchors.right: control.right
        anchors.rightMargin: 12
        anchors.verticalCenter: control.verticalCenter
        visible: visibleComboBox
        source: "qrc:/qml/images/public/icons/triangle.svg"

        transform: Rotation {
            id: idRotation
            origin.x: 4
            origin.y: 2
            angle: visibleComboBoxOpen ? 180 : 0
        }
    }
}
