import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "../components"

Rectangle {
    property bool canClose: true
    property string description: ""

    id: root
    visible: true
    height: idDescription.height + 20
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
        anchors.top: parent.top
        anchors.topMargin: 12
        source: "qrc:/qml/images/public/toast/icon_warning.svg"
    }

    Label {
        id: idDescription
        font.pixelSize: 14
        elide: Text.ElideRight
        wrapMode: Text.WrapAnywhere
        text: description
        width: root.width - 76
        maximumLineCount: 2
        anchors.left: idWarning.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }

    ImageButton {
        visible: canClose
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
