import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../components"

CustomPopup {
    id: popupChangePassword
    width: 400
    height: contentContainer.height
    x: (parent.width - width) / 2
    y: (mainWindow.height - height) / 2
    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0
    padding: 0

    Component.onCompleted: {
        // textOldPassword.clear()
        textNewPassword.clear()
        textConfirmPassword.clear()
    }

    ColumnLayout {
        id: contentContainer
        width: parent.width
        spacing: 0

        DragArea {
            id: btnPopupClose
            title: qsTr("Change Password")
            windowMode: false
            titleFontSize: 18
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            onCloseClicked: {
                onClicked: popupChangePassword.close()
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 320
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            Layout.bottomMargin: 20
            spacing: 10

//            PasswordField {
//                id: textOldPassword
//                placeholderText: qsTr("Old password")
//                focus: true
//                font.pixelSize: 17
//                KeyNavigation.tab: textNewPassword
//                Layout.preferredWidth: 320
//                Layout.topMargin: 5
//            }

            PasswordField {
                id: textNewPassword
                placeholderText: qsTr("New password")
                font.pixelSize: 17
                KeyNavigation.tab: textConfirmPassword
                Layout.preferredWidth: 320
            }

            PasswordField {
                id: textConfirmPassword
                placeholderText: qsTr("Confirm password")
                font.pixelSize: 17
                Layout.preferredWidth: 320
            }

            LabelButton {
                text: qsTr("Forgot password")
                font.pixelSize: 14
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: -15
                Layout.leftMargin: 4
                visible: false
                onClicked: {
                    popupChangePassword.close()
                    if (popupForgotPassword != undefined) {
                        popupForgotPassword.destroy()
                        popupForgotPassword = undefined
                    }
                    popupForgotPassword = Qt.createComponent("ForgotPassword.qml").createObject(mainWindow)
                    popupForgotPassword.open()
                }
            }
        }

        Rectangle {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: '#EBEDF0'
        }

        CustomButton {
            id: buttonSubmit
            text: qsTr("Finished")
            Layout.preferredHeight: 36
            Layout.preferredWidth: 92
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            highlighted: true
            enabled: bindingFunction()
            onClicked: {
                if (textNewPassword.text !== textConfirmPassword.text) {
                    message.warning(qsTr("The new passwords entered twice are not the same, please try again."))
                    textNewPassword.text = ""
                    textConfirmPassword.text = ""
                    return
                }
//                if (textNewPassword.text === textOldPassword.text) {
//                    message.warning(qsTr("The new password cannot be the same as the old password."))
//                    return
//                }
                buttonSubmit.enabled = false
                /*
                authManager.verifyPassword(textOldPassword.text,
                                           authManager.appUserId,
                                           authManager.appUserToken)
                */
                authManager.resetPasswordFlag = true
                authManager.resetPassword(meetingManager.neAppKey,
                                          meetingManager.neAccountId,
                                          meetingManager.neAccountToken,
                                          textNewPassword.text)
            }
        }
    }

    function bindingFunction() {
        return (textNewPassword.text.length >= 8 && textNewPassword.text.length <= 16) &&
                (textConfirmPassword.text.length >= 8 && textConfirmPassword.text.length <= 16)
    }

    Connections {
        target: authManager
        onVerifiedPassword: {
            authManager.resetPasswordFlag = true
            authManager.resetPassword(authManager.phonePrefix,
                                      authManager.phoneNumber,
                                      textNewPassword.text)
        }
        onResetPasswordSig: {
            if (popupChangePassword.visible) {
                message.info(qsTr("Password changed successfully."))
                authManager.logout(false, true)
                pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/HomePage.qml'))
            }
        }
        onError: {
            authManager.resetPasswordFlag = false
            buttonSubmit.enabled = Qt.binding(bindingFunction)
        }
    }

    Connections {
        target: meetingManager
        onLogoutSignal: {
            if (errorCode === 0) {
                updateEnable = true
                pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/HomePage.qml'))
            } else {
                message.error(qsTr('Failed to logout from apaas server'))
            }
        }
    }
}
