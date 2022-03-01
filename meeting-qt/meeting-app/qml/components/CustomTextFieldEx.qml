import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

TextField {
    id: control
    property bool visibleCalendar: false
    property bool visibleComboBox: false
    property bool visibleComboBoxOpen: false

    rightPadding: (!control.enabled || idQtObject.readOnly) ? 12 : 32
    leftPadding: !visibleCalendar ? 12 : idCalendarImage.width + idCalendarImage.anchors.leftMargin + 8
    selectByMouse: true
    selectedTextColor: idQtObject.readOnly ? control.color : "#FFFFFF"
    selectionColor: idQtObject.readOnly ? "#F7F8FA" : "#337DFF"
    placeholderTextColor: "#B0B6BE"
    color: "#333333"
    topPadding: 0
    bottomPadding: 0
    autoScroll: false
    background: Rectangle {
        implicitHeight: 32
        color: control.enabled && !idQtObject.readOnly ? "transparent" : "#F7F8FA"
        border.width: control.enabled && !idQtObject.readOnly && control.focus ? 2 : 0
        border.color: "#32337eff"
        radius: 2
        Rectangle {
            anchors.fill: parent
            anchors.margins: control.enabled && !idQtObject.readOnly && control.focus ? 2 : 0
            color: parent.color
            radius: 2
            border.width: 1
            border.color: (control.enabled && !idQtObject.readOnly && (control.hovered || control.focus)) ? control.Material.accentColor : "#DCDFE5"
        }
    }

    QtObject {
        id: idQtObject
        property string strPlaceholderText: ""
        property bool readOnly: (visibleCalendar || visibleComboBox ) && control.readOnly ? false : control.readOnly
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

    onFocusChanged:
    {
        autoScroll = true
    }

    Image {
        id: idClear
        width: 16
        height: 16
        anchors.right: control.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        visible: control.length !== 0 && control.enabled && control.hovered && !control.readOnly
        source: "qrc:/qml/images/public/button/btn_clear.svg"
        MouseArea {
            anchors.fill: parent
            onClicked: control.clear()
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
