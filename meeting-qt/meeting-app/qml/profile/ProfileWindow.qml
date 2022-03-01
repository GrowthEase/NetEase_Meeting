import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "../components"
import "../utils/dialogManager.js" as DialogManager

Window {
    id: profileWindow

    property var popupChangePassword: undefined
    property var popupModifyNickname: undefined
    property var popupForgotPassword: undefined
    property var popupFeedback: undefined
    property var popupAboutus: undefined

    width: profileLayout.width + 20
    height: profileLayout.height + 20
    color: "#00000000"
    flags: Qt.Window | Qt.FramelessWindowHint// | Qt.WindowStaysOnTopHint

    Material.theme: Material.Light

    onActiveFocusItemChanged: {
        if (!activeFocusItem)
            profileWindow.close()
    }

    CustomPopup {
        id: tooltips
        width: 180
        height: 82
        padding: 10
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Label {
                text: qsTr('Inner meeting ID:')
                font.pixelSize: 12
                color: '#333333'
            }
            TextArea {
                text: qsTr('Can only be used inside the company')
                font.pixelSize: 12
                color: '#333333'
                Layout.preferredWidth: parent.width
                wrapMode: Text.WrapAnywhere
                background: null
            }
        }
    }

    CustomPopup {
        id: editionInfo
        width: 200
        height: 145
        padding: 14
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Label {
                text: qsTr('Current version functions:')
                font.pixelSize: 12
                color: '#333333'
            }
            Label {
                text: authManager.maxDuration
                font.pixelSize: 12
                color: '#333333'
            }
            Label {
                text: authManager.maxMemberCount
                font.pixelSize: 12
                color: '#333333'
            }
            Label {
                Layout.topMargin: 8
                Layout.maximumWidth: 200 - 20
                text: authManager.extraInfo
                font.pixelSize: 12
                color: '#333333'
                wrapMode: Label.WrapAnywhere
            }
        }
    }

    Rectangle {
        id: mainColumnLayout
        anchors.fill: parent
        anchors.margins: 10
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            id: profileLayout
            width: 300
            spacing: 0
            Item { Layout.fillHeight: true }
            RowLayout {
                id: rowAvatar
                Layout.preferredWidth: parent.width
                Layout.minimumHeight: 80
                Layout.topMargin: 10
                Avatar {
                    id: avatarProfile
                    nickname: authManager.appUserNick
                    radius: 24
                    Layout.preferredHeight: 48
                    Layout.preferredWidth: 48
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.leftMargin: 20
                    Layout.rightMargin: 10
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    RowLayout {
                        Label {
                            text: authManager.appUserNick
                            font.pixelSize: 20
                            color: '#333333'
                            Layout.maximumWidth: 180
                            elide: Label.ElideRight
                        }
                        Image {
                            width: 14
                            height: 14
                            source: "qrc:/qml/images/front/icon_edit.svg"
                            visible: meetingManager.neLoginType !== 0 && meetingManager.neLoginType !== 3
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.rightMargin: 20
                            MouseArea {
                                id: nickNameEditBtn
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    profileWindow.close()
                                    if (popupModifyNickname != undefined) {
                                        popupModifyNickname.destroy()
                                        popupModifyNickname = undefined
                                    }
                                    popupModifyNickname = Qt.createComponent("ModifyNickname.qml").createObject(mainWindow)
                                    popupModifyNickname.open()
                                }
                            }
                            Accessible.role: Accessible.Button
                            Accessible.name: "nickNameEdit"
                            Accessible.onPressAction: if (enabled) nickNameEditBtn.clicked(Qt.LeftButton)
                        }
                    }

                    RowLayout {
                        Label {
                            text: authManager.curDisplayCompany
                            font.pixelSize: 12
                            color: "#999999"
                            Layout.maximumWidth: 180
                            elide: Label.ElideRight
                        }
                        Image {
                            Layout.preferredHeight: 14
                            Layout.preferredWidth: 14
                            source: 'qrc:/qml/images/front/icon-switch.svg'
                            MouseArea {
                                id: appListSwitchBtn
                                anchors.fill: parent
                                onClicked: {
                                    appList.open()
                                    profileWindow.close()
                                }
                            }
                            Accessible.role: Accessible.Button
                            Accessible.name: "appListSwitch"
                            Accessible.onPressAction: if (enabled) appListSwitchBtn.clicked(Qt.LeftButton)
                        }
                    }
                }
                Item { Layout.fillWidth: true }
            }
            Rectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: '#EBEDF0'
                visible: authManager.curDisplayVersion !== ''
            }
            RowLayout {
                id: rowEdition
                visible: authManager.curDisplayVersion !== ''
                Layout.preferredWidth: parent.width
                Layout.minimumHeight: 56
                Label {
                    text: qsTr("CurrentVersion")
                    font.pixelSize: 16
                    color: "#222222"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 20
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: authManager.curDisplayVersion
                    color: "#999999"
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                }
                Image {
                    Layout.preferredHeight: 16
                    Layout.preferredWidth: 16
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    source: 'qrc:/qml/images/front/short_id_info.svg'
                    Layout.leftMargin: 8
                    Layout.rightMargin: 20
                    MouseArea {
                        id: appInfoBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            const point = parent.mapToItem(null, 0, 10)
                            editionInfo.x = point.x - editionInfo.width
                            editionInfo.y = point.y
                            editionInfo.open()
                        }
                        onExited: {
                            editionInfo.close()
                        }
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: "versionInfo"
                    Accessible.onPressAction: if (enabled) appInfoBtn.entered()
                }
            }
//            Rectangle { Layout.leftMargin: 20; Layout.rightMargin: 20; Layout.preferredHeight: 1; Layout.fillWidth: true; color: '#EBEDF0' }
//            RowLayout {
//                id: rowNickname
//                Layout.preferredWidth: parent.width
//                Layout.minimumHeight: 56
//                Label {
//                    text: qsTr("Nickname")
//                    font.pixelSize: 16
//                    color: "#222222"
//                    Layout.alignment: Qt.AlignVCenter
//                    Layout.leftMargin: 20
//                }
//                Item { Layout.fillWidth: true }
//                Label {
//                    text: authManager.appUserNick
//                    color: "#999999"
//                    elide: Text.ElideRight
//                    Layout.maximumWidth: 120
//                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
//                    Layout.rightMargin: authManager.loginType === 0 ? 0 : 20
//                }
//                Image {
//                    width: 14
//                    height: 14
//                    source: "qrc:/qml/images/front/icon_edit.svg"
//                    visible: authManager.loginType === 0
//                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
//                    Layout.rightMargin: 20
//                    MouseArea {
//                        anchors.fill: parent
//                        cursorShape: Qt.PointingHandCursor
//                        onClicked: {
//                            profileWindow.close()
//                            if (popupModifyNickname != undefined) {
//                                popupModifyNickname.destroy()
//                                popupModifyNickname = undefined
//                            }
//                            popupModifyNickname = Qt.createComponent("ModifyNickname.qml").createObject(mainWindow)
//                            popupModifyNickname.open()
//                        }
//                    }
//                }
//            }
            Rectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: '#EBEDF0'
                visible: meetingManager.neUsername !== ''
            }
            RowLayout {
                id: rowPhone
                visible: meetingManager.neUsername !== ''
                Layout.preferredWidth: parent.width
                Layout.minimumHeight: 56
                Label {
                    text: qsTr("Telephone")
                    font.pixelSize: 16
                    color: "#222222"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 20
                }
                Label {
                    text: meetingManager.neUsername
                    color: "#999999"
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.rightMargin: 20
                }
            }
            Rectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: '#EBEDF0'
                visible: meetingManager.neLoginType !== 0 && meetingManager.neLoginType !== 3
            }
            RowLayout {
                id: rowPassword
                visible: meetingManager.neLoginType !== 0 && meetingManager.neLoginType !== 3
                Layout.preferredWidth: parent.width
                Layout.minimumHeight: 56
                Label {
                    id: changePasswordLabel
                    text: qsTr("Change password")
                    font.pixelSize: 16
                    color: "#222222"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 20
                }
                Image {
                    width: 14
                    height: 14
                    source: "qrc:/qml/images/front/icon_edit.svg"
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.rightMargin: 20
                    MouseArea {
                        id: changePasswordBtn
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            meetingManager.prettyMeetingId
                            profileWindow.close()
                            if (popupChangePassword != undefined) {
                                popupChangePassword.destroy()
                                popupChangePassword = undefined
                            }
                            popupChangePassword = Qt.createComponent("ChangePassword.qml").createObject(mainWindow)
                            popupChangePassword.open()
                        }
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: changePasswordLabel.text
                    Accessible.onPressAction: if (enabled) changePasswordBtn.clicked(Qt.LeftButton)
                }
            }
            Rectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: '#EBEDF0'
                visible: meetingManager.personalShortMeetingId !== ''
            }
            RowLayout {
                id: rowShortId
                visible: meetingManager.personalShortMeetingId !== ''// && authManager.loginType === 1
                Layout.preferredWidth: parent.width
                Layout.minimumHeight: 56
                Label {
                    text: qsTr("Short ID")
                    font.pixelSize: 16
                    color: "#222222"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 20
                }
                Rectangle {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 20
                    Layout.alignment: Qt.AlignVCenter
                    border.width: 1
                    border.color: '#33337EFF'
                    color: '#19337EFF'
                    Label {
                        anchors.centerIn: parent
                        text: qsTr('Only Inner')
                        font.pixelSize: 12
                        color: '#337EFF'
                    }
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: meetingManager.personalShortMeetingId
                    color: "#999999"
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                }
                Image {
                    Layout.preferredHeight: 16
                    Layout.preferredWidth: 16
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    source: 'qrc:/qml/images/front/short_id_info.svg'
                    Layout.leftMargin: 8
                    Layout.rightMargin: 20
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            const point = parent.mapToItem(null, 0, 10)
                            tooltips.x = point.x - tooltips.width
                            tooltips.y = point.y
                            tooltips.open()
                        }
                        onExited: {
                            tooltips.close()
                        }
                    }
                }
            }
            Rectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.preferredHeight: 1
                Layout.fillWidth: true; color: '#EBEDF0'
            }
            RowLayout {
                id: rowPersonalId
                Layout.preferredWidth: parent.width
                Layout.minimumHeight: 56
                Label {
                    text: qsTr("Meeting ID")
                    font.pixelSize: 16
                    color: "#222222"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 20
                }
                Label {
                    text: meetingManager.prettyMeetingId
                    color: "#999999"
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.rightMargin: 20
                }
            }
            Rectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.preferredHeight: 1
                Layout.fillWidth: true; color: '#EBEDF0'
            }
            RowLayout {
                id: rowSettings
                Layout.preferredWidth: parent.width
                Layout.minimumHeight: 56
                Rectangle {
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 56
                    Label {
                        id: settingsLabel
                        text: qsTr("Settings")
                        font.pixelSize: 16
                        color: "#222222"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }

                    Image {
                        width: 14
                        height: 14
                        source: "qrc:/qml/images/public/icons/arrow_right.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                    }

                    MouseArea {
                        id: settingsBtn
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        preventStealing: true
                        onEntered: parent.color = "#efefef"
                        onExited: parent.color = "#ffffff"
                        onReleased: parent.color = "#ffffff"
                        onClicked: {
                            meetingManager.showSettings()
                        }
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: settingsLabel.text
                    Accessible.onPressAction: if (enabled) settingsBtn.clicked(Qt.LeftButton)
                }
            }
            Rectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: '#EBEDF0'
            }
            RowLayout {
                id: reportAdvice
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 56
                Rectangle{
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 56
                    Label {
                        id: feedbackLabel
                        text: qsTr("Suggestions")
                        font.pixelSize: 16
                        color: "#222222"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }

                    Image {
                        width: 14
                        height: 14
                        source: "qrc:/qml/images/public/icons/arrow_right.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                    }

                    MouseArea {
                        id: feedbackBtn
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        preventStealing: true
                        onEntered: parent.color = "#efefef"
                        onExited: parent.color = "#ffffff"
                        onReleased: parent.color = "#ffffff"
                        onClicked: {
                            feedback.showOptions = false
                            feedback.showFeedbackWindow(false)
//                            profileWindow.close()
//                            if (popupFeedback != undefined) {
//                                popupFeedback.destroy()
//                                popupFeedback = undefined
//                            }
//                            popupFeedback = Qt.createComponent("ReportPage.qml").createObject(mainWindow)
//                            popupFeedback.show()
                        }
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: feedbackLabel.text
                    Accessible.onPressAction: if (enabled) feedbackBtn.clicked(Qt.LeftButton)
                }
            }
            Rectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: '#EBEDF0'
            }
            RowLayout {
                id: aboutus
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 56
                Rectangle{
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 56
                    Label {
                        id: aboutLabel
                        text: qsTr("About")
                        font.pixelSize: 16
                        color: "#222222"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }

                    Image {
                        width: 14
                        height: 14
                        source: "qrc:/qml/images/public/icons/arrow_right.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                    }

                    MouseArea {
                        id: aboutBtn
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        preventStealing: true
                        onEntered: parent.color = "#efefef"
                        onExited: parent.color = "#ffffff"
                        onReleased: parent.color = "#ffffff"
                        onClicked: {
                            profileWindow.close()
                            if (popupAboutus != undefined) {
                                popupAboutus.destroy()
                                popupAboutus = undefined
                            }
                            popupAboutus = Qt.createComponent("About.qml").createObject(mainWindow)
                            popupAboutus.show()
                        }
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: aboutLabel.text
                    Accessible.onPressAction: if (enabled) aboutBtn.clicked(Qt.LeftButton)
                }
            }
            Rectangle {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: '#EBEDF0'
            }
            Button {
                id: buttonLogout
                text: qsTr("Logout")
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 56
                font.pixelSize: 15
                contentItem: Label {
                    text: buttonLogout.text
                    font: buttonLogout.font
                    opacity: enabled ? 1.0 : 0.3
                    color: buttonLogout.down ? "#FE3B30" : "#FE3B30"
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    elide: Label.ElideRight

                    Accessible.role: Accessible.Button
                    Accessible.name: buttonLogout.text
                    Accessible.onPressAction: if (buttonLogout.enabled) logoutBtn.clicked(Qt.LeftButton)
                }
                background: Rectangle {
                    color: "#FFFFFF"
                }
                MouseArea {
                    id: logoutBtn
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        profileWindow.close()
                        DialogManager.dynamicDialog(qsTr('Exit'), qsTr('Do you want to exit?'), function () {
                            authManager.logout(true, true)
                        }, function () {
                        }, frontPage)
                    }
                }
            }
        }
    }

    DropShadow {
        anchors.fill: mainColumnLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainColumnLayout
        color: "#3217171A"
        spread: 0
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    Connections {
        target: authManager
        onLoggedOut: {
            closeAllProfileDialog()
        }
    }

    function closeAllProfileDialog(){
        if (popupForgotPassword !== undefined) {
            popupForgotPassword.destroy()
            popupForgotPassword = undefined
        }
        if (popupChangePassword !== undefined) {
            popupChangePassword.destroy()
            popupChangePassword = undefined
        }
        if (popupModifyNickname !== undefined) {
            popupModifyNickname.destroy()
            popupModifyNickname = undefined
        }
        if (popupFeedback !== undefined) {
            popupFeedback.destroy()
            popupFeedback = undefined
        }
        if (popupAboutus !== undefined) {
            popupAboutus.destroy()
            popupAboutus = undefined
        }
    }
}
