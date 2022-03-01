import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "components/"

Item {
    anchors.fill: parent

    property bool verified: false
    property alias textPhoneNumber: textPhoneNumber
    property alias textCode: textCode
    property alias textNickname: textNickname
    property alias labelNickname: labelNickname
    property alias textPassword: textPassword
    property alias labelPassword: labelPassword
    property alias buttonSubmit: buttonSubmit
    property alias header: header
    property alias privacyPolicy: privacyPolicy
    property alias userServiceAgreement: userServiceAgreement
    property string lastNicknameText: ''
    property alias privacyCheck: idPrivacyCheck

    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 45
        anchors.horizontalCenter: parent.horizontalCenter
        width: columnLayout.width
        height: childrenRect.height

        ColumnLayout {
            id: columnLayout

            PageHeader {
                id: header
                Layout.preferredHeight: 36
                Layout.preferredWidth: 330
                title: qsTr("Register new account")
            }

            PhoneNumberField {
                id: textPhoneNumber
                placeholderText: qsTr("Phone number")
                KeyNavigation.tab: textCode
                Layout.preferredWidth: 330
                Layout.topMargin: 20
                visible: !verified
                focus: true
            }

            AuthCodeField {
                id: textCode
                enableSendButton: textPhoneNumber.length === 13
                Layout.topMargin: 12
                Layout.preferredWidth: 330
                visible: !verified
            }

            CustomTextField {
                id: textNickname
                font.pixelSize: 17
                placeholderText: qsTr("Nickname")
                Layout.preferredWidth: 330
                Layout.topMargin: 20
                visible: verified
                KeyNavigation.tab: textPassword
            }

            Label {
                id: labelNickname
                font.pixelSize: 12
                color: "#337EFF"
                Layout.topMargin: -8
                visible: false
            }

            PasswordField {
                id: textPassword
                font.pixelSize: 17
                placeholderText: qsTr("Password")
                Layout.preferredWidth: 330
                Layout.topMargin: 20
                visible: verified
                KeyNavigation.tab: buttonSubmit
            }

            Label {
                id: labelPassword
                font.pixelSize: 12
                color: "#337EFF"
                text: qsTr("8~16 characters, supports letters and numbers")
                Layout.topMargin: -8
                visible: false
            }

            CustomButton {
                id: buttonSubmit
                highlighted: true
                text: qsTr("Next")
                enabled: verified ? textNickname.length > 0
                                    && textPassword.length >= 8
                                    && textPassword.length <= 16 : textPhoneNumber.length === 13
                                    && textCode.length > 0
                font.pixelSize: 16
                Layout.preferredHeight: 50
                Layout.preferredWidth: 320
                Layout.topMargin: 45
                Layout.bottomMargin: 10
            }
        }
    }

    RowLayout {
        spacing: 8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20

        CustomCheckBox {
            id: idPrivacyCheck
            text: qsTr("I have read and agreed to NetEase Meeting")
            font.pixelSize: 12
            checked: isAgreePrivacyPolicy
        }

        LabelButton {
            id: privacyPolicy
            text: qsTr("privacy policy")
            font.pixelSize: 12
        }

        Label {
            text: qsTr("and")
            font.pixelSize: 12
            color: "#666666"
        }

        LabelButton {
            id: userServiceAgreement
            text: qsTr("user service agreement")
            font.pixelSize: 12
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
