import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: root
    property var title: ""
    property alias enabled: backButton.enabled

    signal previous

    ToolButton {
        id: backButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: -18
        font.pixelSize: 24
        onClicked: previous()

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qml/images/public/button/btn_left.svg"
        }
    }

    Label {
        id: text
        text: title
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }
}
