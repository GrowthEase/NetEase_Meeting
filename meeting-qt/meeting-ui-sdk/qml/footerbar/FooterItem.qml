import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Button {
    id: root
    bottomInset: 0
    topInset: 0
    leftInset: 0
    rightInset: 0

    property string itemIcon: ''
    property string itemText: ''
    property int imageWidth: 24
    property int imageHieght: 24
    property int imageTopMargin: 0

    background: Rectangle {
        color: root.hovered ? (root.pressed ? '#1D1D24' : '#22222B') : 'transparent';
        implicitHeight: root.height
        implicitWidth: root.width
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            Image {
                source: itemIcon
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: imageWidth
                Layout.preferredHeight: imageHieght
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.topMargin: 6 + imageTopMargin
                Layout.bottomMargin: 5
            }
            Label {
                text: itemText
                color: '#FFFFFF'
                font.pixelSize: 10
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: root.width
                elide: Text.ElideRight
            }
        }
        Accessible.role: Accessible.Button
        Accessible.name: itemText
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }
}
