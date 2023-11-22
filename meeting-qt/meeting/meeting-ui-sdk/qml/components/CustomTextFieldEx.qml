import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

TextField {
    id: control

    property bool visibleCalendar: false
    property bool visibleComboBox: false
    property bool visibleComboBoxOpen: false

    bottomPadding: 0
    color: "#333333"
    leftPadding: !visibleCalendar ? 12 : idCalendarImage.width + idCalendarImage.anchors.leftMargin + 8
    placeholderTextColor: "#B0B6BE"
    rightPadding: 35
    selectByMouse: true
    topPadding: 0

    background: Rectangle {
        border.color: (control.enabled && control.hovered) ? control.Material.accentColor : "#DCDFE5"
        border.width: 1
        color: control.enabled ? "transparent" : "#F2F2F5"
        implicitHeight: 32
        radius: 2
    }

    onEnabledChanged: {
        if (!control.enabled) {
            idQtObject.strPlaceholderText = control.placeholderText;
            control.placeholderText = "";
        } else {
            control.placeholderText = idQtObject.strPlaceholderText;
            idQtObject.strPlaceholderText = "";
        }
    }

    QtObject {
        id: idQtObject

        property string strPlaceholderText: ""
    }
    ToolButton {
        id: idClearBtn
        anchors.right: control.right
        anchors.rightMargin: 0
        anchors.verticalCenter: control.verticalCenter
        height: 32
        visible: control.length && control.enabled && control.hovered && !control.readOnly
        width: 32

        onClicked: {
            control.clear();
        }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            mipmap: true
            source: "qrc:/qml/images/public/button/btn_clear.svg"
        }
    }
    Image {
        id: idCalendarImage
        anchors.left: control.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        height: 12
        mipmap: true
        source: "qrc:/qml/images/public/icons/calendar.svg"
        visible: visibleCalendar
        width: 12
    }
    Image {
        id: idComboBoxOpenImage
        anchors.right: control.right
        anchors.rightMargin: 12
        anchors.verticalCenter: control.verticalCenter
        height: 8
        mipmap: true
        source: "qrc:/qml/images/public/icons/triangle.svg"
        visible: visibleComboBox
        width: 8

        transform: Rotation {
            id: idRotation
            angle: visibleComboBoxOpen ? 180 : 0
            origin.x: 4
            origin.y: 4
        }
    }
}
