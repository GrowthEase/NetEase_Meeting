import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Window{
    id:root
    visible: false
    height: 32
    width:32
    color: "transparent"
    flags:  Qt.Window | Qt.FramelessWindowHint

    signal click()
    property string tipText: "1"
    Rectangle {

        anchors.fill: parent
        radius: 2
        clip:true
        color: "#337EFF"


        ColumnLayout{
            spacing: 0
            anchors.fill: parent
            anchors.centerIn: parent
            Image {
                width: 16
                height: 16
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/qml/images/meeting/hand_raised.svg"
            }
            Label {
                id:handstip
                text: tipText
                Layout.alignment: Qt.AlignHCenter
                color: "#ECEDEF"
                font.pixelSize: 8
                visible: true
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                click()
            }
        }
    }
}
