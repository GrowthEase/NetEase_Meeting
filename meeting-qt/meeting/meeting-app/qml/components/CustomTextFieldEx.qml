import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

TextField {
    id: control

    property bool acceptToolClickOnly: false
    property bool visibleCalendar: false
    property bool visibleComboBox: false
    property bool visibleComboBoxOpen: false

    signal comboBoxOpenImageClicked

    Accessible.name: control.placeholderText
    autoScroll: false
    bottomPadding: 0
    color: "#333333"
    leftPadding: !visibleCalendar ? 12 : idCalendarImage.width + idCalendarImage.anchors.leftMargin + 8
    placeholderTextColor: "#B0B6BE"
    rightPadding: (!control.enabled || idQtObject.readOnly) ? 12 : 32
    selectByMouse: true
    selectedTextColor: idQtObject.readOnly ? control.color : "#FFFFFF"
    selectionColor: idQtObject.readOnly ? "#F7F8FA" : "#337DFF"
    topPadding: 0

    background: Rectangle {
        border.color: "#32337eff"
        border.width: control.enabled && !idQtObject.readOnly && control.focus ? 2 : 0
        color: control.enabled && !idQtObject.readOnly ? "transparent" : "#F7F8FA"
        implicitHeight: 32
        radius: 2

        Rectangle {
            anchors.fill: parent
            anchors.margins: control.enabled && !idQtObject.readOnly && control.focus ? 2 : 0
            border.color: (control.enabled && !idQtObject.readOnly && (control.hovered || control.focus)) ? control.Material.accentColor : "#DCDFE5"
            border.width: 1
            color: parent.color
            radius: 2
        }
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
    onFocusChanged: {
        autoScroll = true;
    }

    QtObject {
        id: idQtObject

        property bool readOnly: (visibleCalendar || visibleComboBox) && !acceptToolClickOnly && control.readOnly ? false : control.readOnly
        property string strPlaceholderText: ""
    }
    Image {
        id: idClear
        anchors.right: control.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        height: 16
        mipmap: true
        source: "qrc:/qml/images/public/button/btn_clear.svg"
        visible: control.length !== 0 && control.enabled && control.hovered && !control.readOnly && !acceptToolClickOnly
        width: 16

        MouseArea {
            anchors.fill: parent

            onClicked: control.clear()
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
    MouseArea {
        anchors.right: control.right
        anchors.top: control.top
        height: 32
        visible: acceptToolClickOnly
        width: 32

        onClicked: {
            console.log("comboBoxOpenImageClicked");
            comboBoxOpenImageClicked();
        }
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
