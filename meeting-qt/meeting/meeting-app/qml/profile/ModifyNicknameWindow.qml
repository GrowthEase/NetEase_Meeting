import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12


import "../components"

CustomWindow {
    id: windowModifyNickname

    property string lastNicknameText: ''
    property var modifyNicknameEnable: true

    width: 400
    height: 230
    title: qsTr("set meeting nickName")
    idLoader.sourceComponent: idModifyName
    closeVisible: false

    Connections {
        target: authManager
        onUpdatedProfile: {
            console.log("onUpdatedProfile")
            if(authManager.autoRegistered) {
                message.info(qsTr("Nickname set successfully."))
                windowModifyNickname.close()
                authManager.autoRegistered = false
                modifyNicknameEnable = true
                lastNicknameText = ""
                console.log("onUpdatedProfile autoRegistered = true")
            }
        }
        onError: {
             modifyNicknameEnable = true
        }
    }

    Component {
        id: idModifyName
        Item {
            ColumnLayout {
                id: contentContainer
                width: parent.width
                spacing: 0

                ColumnLayout {
                    Layout.preferredWidth: 328
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    Layout.bottomMargin: 20
                    spacing: 10

                    CustomTextField {
                        id: textNewNickname
                        placeholderText: qsTr("Please enter a nickname")
                        text: lastNicknameText
                        focus: true
                        font.pixelSize: 17
                        Layout.preferredWidth: 328
                        Layout.topMargin: 5
//                        validator: RegularExpressionValidator {
//                            regularExpression: /\w{1,20}/
//                        }
                        onTextChanged: {
                            const currentText = textNewNickname.text
                            if (currentText === lastNicknameText)
                                return

                            if (getByteLength(currentText) > 20) {
                            } else {
                                lastNicknameText = currentText
                                const regStr = /[\uD83C|\uD83D|\uD83E][\uDC00-\uDFFF][\u200D|\uFE0F]|[\uD83C|\uD83D|\uD83E][\uDC00-\uDFFF]|[0-9|*|#]\uFE0F\u20E3|[0-9|#]\u20E3|[\u203C-\u3299]\uFE0F\u200D|[\u203C-\u3299]\uFE0F|[\u2122-\u2B55]|\u303D|[\A9|\AE]\u3030|\uA9|\uAE|\u3030/gi
                                lastNicknameText = lastNicknameText.replace(regStr, '')
                            }
                            textNewNickname.text = lastNicknameText
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
                    enabled: !modifyNicknameEnable ? false : (textNewNickname.length > 0 && textNewNickname.text !== authManager.appUserNick)
                    onClicked: {
                        modifyNicknameEnable = false
                        authManager.updateProfile(textNewNickname.text, meetingManager.neAppKey,
                                                  meetingManager.neAccountId, meetingManager.neAccountToken)
                    }
                }
            }
        }
    }
}
