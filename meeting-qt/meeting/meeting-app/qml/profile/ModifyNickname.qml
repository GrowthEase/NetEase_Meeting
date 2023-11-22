import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

CustomPopup {
    id: popupModifyNickname

    property string lastNicknameText: ''

    Accessible.name: btnPopupClose.title
    bottomInset: 0
    bottomMargin: 10
    height: contentContainer.height
    leftInset: 0
    padding: 0
    rightInset: 0
    topInset: 0
    width: 400
    x: (parent.width - width) / 2
    y: (mainWindow.height - height) / 2

    Connections {
        target: authManager

        onError: {
            buttonModifyNick.enabled = true;
        }
        onUpdatedProfile: {
            if (!authManager.autoRegistered) {
                message.info(qsTr("Nickname changed successfully."));
                popupModifyNickname.close();
            }
        }
    }
    ColumnLayout {
        id: contentContainer
        spacing: 0
        width: parent.width

        DragArea {
            id: btnPopupClose
            Layout.preferredHeight: 50
            Layout.preferredWidth: parent.width
            title: qsTr("Modify Nickname")
            titleFontSize: 18
            windowMode: false

            onCloseClicked: {
                onClicked: popupModifyNickname.close();
            }
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
            Layout.preferredWidth: 328
            Layout.topMargin: 20
            spacing: 5

            CustomTextField {
                id: textNewNickname
                Layout.preferredWidth: 328
                Layout.topMargin: 5
                focus: true
                font.pixelSize: 17
                placeholderText: focus ? "" : qsTr("New nickname")
                text: authManager.appUserNick

                onTextChanged: {
                    const currentText = textNewNickname.text;
                    if (currentText === lastNicknameText)
                        return;
                    if (getByteLength(currentText) > 20) {
                    } else {
                        lastNicknameText = currentText;
                        const regStr = /[\uD83C|\uD83D|\uD83E][\uDC00-\uDFFF][\u200D|\uFE0F]|[\uD83C|\uD83D|\uD83E][\uDC00-\uDFFF]|[0-9|*|#]\uFE0F\u20E3|[0-9|#]\u20E3|[\u203C-\u3299]\uFE0F\u200D|[\u203C-\u3299]\uFE0F|[\u2122-\u2B55]|\u303D|[\A9|\AE]\u3030|\uA9|\uAE|\u3030/gi;
                        lastNicknameText = lastNicknameText.replace(regStr, '');
                    }
                    textNewNickname.text = lastNicknameText;
                }
            }
            Label {
                color: "#337EFF"
                // Layout.topMargin: -15
                font.pixelSize: 12
                text: qsTr("10 Chinese characters, or 20 alphanumeric characters")
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: '#EBEDF0'
        }
        CustomButton {
            id: buttonModifyNick
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
            Layout.preferredHeight: 36
            Layout.preferredWidth: 120
            Layout.topMargin: 10
            enabled: textNewNickname.length > 0 && textNewNickname.text !== authManager.appUserNick
            highlighted: true
            text: qsTr("Finished")

            onClicked: {
                buttonModifyNick.enabled = false;
                authManager.updateProfile(textNewNickname.text, meetingManager.neAppKey, meetingManager.neAccountId, meetingManager.neAccountToken);
            }
        }
    }
}
