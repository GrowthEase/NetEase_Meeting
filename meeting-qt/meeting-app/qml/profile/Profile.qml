import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../components"
import "../utils/dialogManager.js" as DialogManager

CustomPopup {
    id: popupProfile

    property var popupChangePassword: undefined
    property var popupModifyNickname: undefined
    property var popupFeedback: undefined
    property var popupAboutus: undefined

    x: parent.width - width - 20
    y: 20
    width: 300
    padding: 20
    topPadding: 30
    Connections {
        target: authManager
        onLoggedOut: {
            closeAllProfileDialog()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 3
        RowLayout {
            id: rowAvatar
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            Label {
                text: qsTr("Avatar")
                font.pixelSize: 16
                color: "#222222"
                Layout.alignment: Qt.AlignVCenter
            }
            Avatar {
                id: avatarProfile
                nickname: authManager.appUserNick
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }
        }
        CustomToolSeparator {}
        RowLayout {
            id: rowNickname
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            Label {
                text: qsTr("Nickname")
                font.pixelSize: 16
                color: "#222222"
                Layout.alignment: Qt.AlignVCenter
            }
            Label {
                text: authManager.appUserNick
                color: "#999999"
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }
            Image {
                width: 14
                height: 14
                source: "qrc:/qml/images/front/icon_edit.svg"
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                visible: meetingManager.neLoginType !== 3
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        popupProfile.close()
                        if (popupModifyNickname != undefined) {
                            popupModifyNickname.destroy()
                            popupModifyNickname = undefined
                        }
                        popupModifyNickname = Qt.createComponent("ModifyNickname.qml").createObject(mainWindow)
                        popupModifyNickname.open()
                    }
                }
            }
        }
        CustomToolSeparator {}
        RowLayout {
            id: rowPhone
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            Label {
                text: qsTr("Telephone")
                font.pixelSize: 16
                color: "#222222"
                Layout.alignment: Qt.AlignVCenter
            }
            Label {
                text: authManager.phoneNumber
                color: "#999999"
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }
        }
        CustomToolSeparator {}
        RowLayout {
            id: rowPassword
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            Label {
                text: qsTr("Change password")
                font.pixelSize: 16
                color: "#222222"
                Layout.alignment: Qt.AlignVCenter
            }
            Image {
                width: 14
                height: 14
                source: "qrc:/qml/images/front/icon_edit.svg"
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        meetingManager.prettyMeetingId
                        popupProfile.close()
                        if (popupChangePassword != undefined) {
                            popupChangePassword.destroy()
                            popupChangePassword = undefined
                        }
                        popupChangePassword = Qt.createComponent("ChangePassword.qml").createObject(mainWindow)
                        popupChangePassword.open()
                    }
                }
            }
        }
        CustomToolSeparator {}
        RowLayout {
            id: rowPersonalId
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            Label {
                text: qsTr("Meeting ID")
                font.pixelSize: 16
                color: "#222222"
                Layout.alignment: Qt.AlignVCenter
            }
            Label {
                text: meetingManager.prettyMeetingId
                color: "#999999"
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }
        }
        CustomToolSeparator {}
        RowLayout {
            id: reportAdvice
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            Rectangle{
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 50
                Label {
                    text: qsTr("Suggestions")
                    font.pixelSize: 16
                    color: "#222222"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    width: 14
                    height: 14
                    source: "qrc:/qml/images/public/icons/arrow_right.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    preventStealing: true
                    onEntered: parent.color = "#efefef"
                    onExited: parent.color = "#ffffff"
                    onReleased: parent.color = "#ffffff"
                    onClicked: {
                        popupProfile.close()
                        if (popupFeedback != undefined) {
                            popupFeedback.destroy()
                            popupFeedback = undefined
                        }
                        popupFeedback = Qt.createComponent("ReportPage.qml").createObject(mainWindow)
                        popupFeedback.show()
                    }
                }
            }
        }

        CustomToolSeparator {}
        RowLayout {
            id: aboutus
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            Rectangle{
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 50
                Label {
                    text: qsTr("About")
                    font.pixelSize: 16
                    color: "#222222"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    width: 14
                    height: 14
                    source: "qrc:/qml/images/public/icons/arrow_right.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    preventStealing: true
                    onEntered: parent.color = "#efefef"
                    onExited: parent.color = "#ffffff"
                    onReleased: parent.color = "#ffffff"
                    onClicked: {
                        popupProfile.close()
                        if (popupAboutus != undefined) {
                            popupAboutus.destroy()
                            popupAboutus = undefined
                        }
                        popupAboutus = Qt.createComponent("About.qml").createObject(mainWindow)
                        popupAboutus.show()
                    }
                }
            }
        }
        CustomToolSeparator {}
        Button {
            id: buttonLogout
            text: qsTr("Logout")
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50
            font.pixelSize: 17
            contentItem: Label {
                text: buttonLogout.text
                font: buttonLogout.font
                opacity: enabled ? 1.0 : 0.3
                color: buttonLogout.down ? "#FE3B30" : "#FE3B30"
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                elide: Label.ElideRight
            }
            background: Rectangle {
                color: "#FFFFFF"
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    popupProfile.close()
                    DialogManager.dynamicDialog(qsTr('Exit'), qsTr('Do you want to exit?'), function () {
                        authManager.logout()
                    })
                }
            }
        }
    }

    function closeAllProfileDialog(){
        if (popupChangePassword != undefined) {
            popupChangePassword.destroy()
            popupChangePassword = undefined
        }
        if (popupModifyNickname != undefined) {
            popupModifyNickname.destroy()
            popupModifyNickname = undefined
        }
        if (popupFeedback != undefined) {
            popupFeedback.destroy()
            popupFeedback = undefined
        }
        if (popupAboutus != undefined) {
            popupAboutus.destroy()
            popupAboutus = undefined
        }
    }
}
