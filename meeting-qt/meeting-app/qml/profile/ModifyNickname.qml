import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../components"

CustomPopup {
    id: popupModifyNickname

    property string lastNicknameText: ''

    width: 400
    height: contentContainer.height
    x: (parent.width - width) / 2
    y: (mainWindow.height - height) / 2
    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0
    padding: 0
    bottomMargin: 10

    Connections {
        target: authManager
        onUpdatedProfile: {
            message.info(qsTr("Nickname changed successfully."))
            popupModifyNickname.close()
        }
        onError: {
            buttonModifyNick.enabled = true
        }
    }

    ColumnLayout {
        id: contentContainer
        width: parent.width
        spacing: 0

        DragArea {
            id: btnPopupClose
            title: qsTr("Modify Nickname")
            windowMode: false
            titleFontSize: 18
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            onCloseClicked: {
                onClicked: popupModifyNickname.close()
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 328
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            Layout.bottomMargin: 20
            spacing: 10

            CustomTextField {
                id: textNewNickname
                placeholderText: qsTr("New nickname")
                text: authManager.appUserNick
                focus: true
                font.pixelSize: 17
                Layout.preferredWidth: 328
                Layout.topMargin: 5
                validator: RegExpValidator {
                    regExp: /\w{1,20}/
                }
                onTextChanged: {
                    const currentText = textNewNickname.text

                    if (currentText === lastNicknameText)
                        return

                    if (getByteLength(currentText) > 20) {
                        textNewNickname.text = lastNicknameText
                    } else {
                        lastNicknameText = currentText
                    }
                }
            }

            Label {
                text: qsTr("10 Chinese characters, or 20 alphanumeric characters")
                font.pixelSize: 12
                color: "#337EFF"
                Layout.topMargin: -15
            }
        }

        Rectangle {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: '#EBEDF0'
        }

        CustomButton {
            id: buttonModifyNick
            text: qsTr("Finished")
            Layout.preferredHeight: 36
            Layout.preferredWidth: 120
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.alignment: Qt.AlignHCenter
            highlighted: true
            enabled: textNewNickname.length > 0 && textNewNickname.text !== authManager.appUserNick
            onClicked: {
                buttonModifyNick.enabled = false
                authManager.updateProfile(textNewNickname.text, meetingManager.neAppKey,
                                          meetingManager.neAccountId, meetingManager.neAccountToken)
            }
        }
    }
}
