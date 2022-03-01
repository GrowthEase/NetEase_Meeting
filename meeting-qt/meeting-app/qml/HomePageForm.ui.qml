import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import "components/"

Item {
    id: root

    property alias buttonJoin: buttonJoin
    property alias buttonLogin: buttonLogin
    property alias buttonSSO: buttonSSO
    property alias buttonRegister: buttonRegister
    property alias privacyPolicy: privacyPolicy
    property alias userServiceAgreement: userServiceAgreement
    property alias privacyCheck: idPrivacyCheck
    property alias appTipArea: idAppTipArea

    anchors.fill: parent

    CustomTipArea {
        id: idAppTipArea
        visible: false
        width: 468
        anchors.top: root.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: container
        anchors.top: parent.top
        anchors.topMargin: 70
        anchors.horizontalCenter: parent.horizontalCenter
        width: columnLayout.width
        height: childrenRect.height

        Image {
            id: logo
            width: 220
            height: 58
            anchors.top: container.top
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qml/images/logo.png"
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            id: columnLayout
            anchors.top: logo.bottom
            anchors.topMargin: 73

            CustomButton {
                id: buttonJoin
                Layout.preferredHeight: 50
                Layout.preferredWidth: 320
                text: qsTr("Join")
                highlighted: true
                font.pixelSize: 16
            }

            CustomButton {
                id: buttonLogin
                Layout.preferredHeight: 50
                Layout.preferredWidth: 320
                text: qsTr("Login")
                Layout.topMargin: 10
                font.pixelSize: 16
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignHCenter
                spacing: 30
                LabelButton {
                    id: buttonRegister
                    visible: false
                    text: qsTr("Register")
                    Layout.topMargin: 6
                    Layout.preferredHeight: 30
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 14
                }
                LabelButton {
                    id: buttonSSO
                    text: qsTr("SSO")
                    Layout.topMargin: 6
                    Layout.preferredHeight: 30
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 14
                }
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
