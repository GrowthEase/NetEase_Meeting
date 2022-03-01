import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Popup {
    id: root
    width: 320
    height: 157
    modal: true
    padding: 0
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    margins: 0
    dim: false
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    background: Rectangle {
        id: backgroundRect
        radius: Qt.platform.os === 'windows' ? 0 : 10
        border.width: 1
        border.color: "#EBEDF0"
        layer.enabled: true
        layer.effect: DropShadow {
            width: backgroundRect.width
            height: backgroundRect.height
            x: backgroundRect.x - 2
            y: backgroundRect.y - 2
            visible: backgroundRect.visible
            source: backgroundRect
            horizontalOffset: 0
            verticalOffset: 0
            radius: 16
            samples: 33
            color: "#1917171a"
        }
    }

    property alias text: title.text
    property alias checkenable: handsup.checked

    property string checkText: ""

    signal muteNotAllowOpenByself
    signal muteAllowOpenByself
    signal cancel

    onClosed: {
        // When created dynamically, is called when the dialog is closed only but the parent object is not destroyed
        //root.destroy()
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: 28
        anchors.bottom: layoutButtons.top
        anchors.bottomMargin: 28
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Label {
            id: title
            text: ""
            color: "#222222"
            font.weight: Font.Medium
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: 4
            CustomCheckBox {
                id:handsup
                width: 16
                height: 16
                checked: meetingManager.meetingAllowSelfAudioOn
                text: checkText
            }
        }
    }

    CustomToolSeparator {
        width: parent.width
        anchors.bottom: layoutButtons.top
    }

    RowLayout {
        id: layoutButtons
        width: parent.width
        anchors.bottom: parent.bottom
        spacing: 0
        CustomButton {
            buttonRadius: 8
            Layout.preferredHeight: 50
            Layout.preferredWidth: 158
            borderSize: 0
            normalTextColor: "#333333"
            text: qsTr("cancel")
            onClicked: {
                cancel()
                close()
            }
        }
        ToolSeparator {
            padding: 0
            topInset: 0
            bottomInset: 0
            leftInset: 0
            rightInset: 0
            verticalPadding: 0
            horizontalPadding: 0
            contentItem: Rectangle {
                implicitWidth: 1
                implicitHeight: 50
                color: "#EBEDF0"
            }
        }
        CustomButton {
            buttonRadius: 8
            Layout.preferredHeight: 50
            Layout.preferredWidth: 158
            borderSize: 0
            normalTextColor: "#337EFF"
            text: qsTr("mute")
            onClicked: {
                if (handsup.checked) {
                    muteAllowOpenByself()
                } else {
                    muteNotAllowOpenByself()
                }
                close()
            }
        }
    }
}
