import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NetEase.Meeting.GlobalChatManager 1.0

Button {
    id: root
    bottomInset: 0
    topInset: 0
    leftInset: 0
    rightInset: 0
    focusPolicy: Qt.NoFocus

    property string itemIcon: ''
    property string itemText: ''
    property int msgTipNum: 0
    property int tipNum: 0

    background: Rectangle {
        color: root.hovered ? (root.pressed ? '#1D1D24' : '#22222B') : 'transparent';
        // implicitHeight: root.height
        // implicitWidth:  root.width
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            Image {
                source: itemIcon
                fillMode: Image.PreserveAspectFit
                mipmap: true
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.topMargin: 6
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
        Rectangle {
            width: tip.implicitWidth >= 12 ? tip.implicitWidth + 2 : 12
            height: tip.implicitHeight + 2
            radius: 6
            color: "red"
            visible: msgTipNum !== 0
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 14

            Label {
                id:tip
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.pixelSize: 10
                font.bold: true
                text: {
                    if (msgTipNum > 99) {
                        return "99+"
                    } else {
                        return msgTipNum
                    }
                }
            }
        }

        Accessible.role: Accessible.Button
        Accessible.name: itemText
        Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
    }

    Label {
        visible: 0 !== tipNum
        text: tipNum
        anchors.top: parent.top;
        anchors.right: parent.right;
        anchors.topMargin: 8;
        anchors.rightMargin: 10;
        font.pixelSize: 11;
        font.bold: true;
        color: "#FFFFFF"
    }
}
