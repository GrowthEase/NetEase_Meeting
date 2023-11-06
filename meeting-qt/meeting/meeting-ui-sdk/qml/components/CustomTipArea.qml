import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    property bool canClose: true
    property string description: ""

    id: root
    visible: true
    color: "#FFF7E0"
    border.color: "#FFD551"
    border.width: 1
    radius: 4

    signal sigContentClicked()
    signal sigCloseClicked()

    Image {
        id: idWarning
        width: 16
        height: 16
        anchors.left: parent.left
        anchors.leftMargin: 17
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/qml/images/public/icons/icon_warning.svg"
        mipmap: true
    }

    Label {
        id: idDescription
        font.pixelSize: 14
        elide: Text.ElideRight
        wrapMode: Text.WrapAnywhere
        text: description
        width: root.width
        maximumLineCount: 2
        color: "#333333"
        anchors.left: idWarning.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }

    ImageButton {
        visible: true
        z: 2

        implicitWidth: 10
        implicitHeight: 10

        anchors.right: parent.right
        anchors.rightMargin: 17
        anchors.verticalCenter: parent.verticalCenter

        normalImage: 'qrc:/qml/images/public/icons/icon_close_min.png'
        hoveredImage: 'qrc:/qml/images/public/icons/icon_close_min.png'
        pushedImage: 'qrc:/qml/images/public/icons/icon_close_min.png'

        onClicked: {
            sigCloseClicked()
            root.visible = false
        }
    }

    MouseArea {
        id: idShowDetail
        hoverEnabled: true
        anchors.fill: parent

        onClicked: {
            sigContentClicked()
        }
    }
}
