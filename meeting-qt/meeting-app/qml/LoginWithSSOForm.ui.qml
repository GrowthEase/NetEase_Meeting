import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import 'components'

Item {
    property alias header: header
    property alias textCode: textCode
    property alias buttonSwitch: buttonSwitch
    property alias buttonSubmit: buttonSubmit
    property bool loginByEmail: false
    property alias privacyCheck: idPrivacyCheck
    property alias privacyPolicy: privacyPolicy
    property alias userServiceAgreement: userServiceAgreement

    anchors.fill: parent

    ColumnLayout {
        anchors.centerIn: parent

        PageHeader {
            id: header
            Layout.preferredHeight: 36
            Layout.preferredWidth: 330
            title: qsTr("Login with SSO")
        }

        CustomTextField {
            id: textCode
            placeholderText: qsTr("Code of your company")
            font.pixelSize: 17
            focus: true
            Layout.preferredWidth: 300
            Layout.topMargin: 40
            Layout.alignment: Qt.AlignHCenter
        }

        LabelButton {
            id: buttonSwitch
            visible: false
            text: qsTr('Login by email')
            font.pixelSize: 14
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 20
        }

        CustomButton {
            id: buttonSubmit
            enabled: textCode.text.length > 0
            highlighted: true
            text: qsTr("Next")
            font.pixelSize: 16
            Layout.preferredHeight: 50
            Layout.preferredWidth: 320
            Layout.topMargin: 80
            Layout.bottomMargin: 10
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
