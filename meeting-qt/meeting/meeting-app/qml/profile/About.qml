import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.14
// import QtQuick.Controls.Styles 1.4
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material 2.12

import "../components"

Window {
    id:aboutus
    title: qsTr("About")
    width: 400+17
    height:485+17
    Material.theme: Material.Light
    color: "#00000000"
    flags: Qt.Window | Qt.FramelessWindowHint

    Component.onCompleted: {
        listModel.append({ text: qsTr("User Services Agreement"), url: "https://netease.im/meeting/clauses?serviceType=0" })
        listModel.append({ text: qsTr("Privacy Policy"), url: "https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml" })
        listModel.append({ text: qsTr("Third party copyright"), url: "file:///" + meetingManager.getThirdPartyCopyrightFile() })
    }

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        color: "#3217171A"
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    MessageManager {
        id: message
    }

    Rectangle  {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        radius: Qt.platform.os === 'windows' ? 0 : 10

        DragArea {
            height: 52
            width: parent.width
            title: qsTr("About")
            onCloseClicked: Window.window.hide()
        }

        ColumnLayout {
            spacing: 0
            anchors.fill: parent
            anchors.topMargin: 30
            Image {
                id: aboutLogo
                source: "qrc:/qml/images/about_logo.png"
                mipmap: true
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 124
                Layout.preferredWidth: 118
                Layout.topMargin: 55
                Layout.bottomMargin: 50
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -135
                Layout.preferredWidth: 130
                Layout.preferredHeight: 22
                color: "#FFFFFF"
                Label {
                    id: versionValue
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Version: %1").arg(Qt.application.version) + (configManager.getTestEnv() ? qsTr("(Test Env)") : "")
                    font.pixelSize: 12
                    color: "#9f333333"
                    MouseArea {
                        anchors.fill: parent
                        property int clickedCount: 0
                        onClicked: {
                            if (Qt.LeftButton === mouse.button) {
                                clickedCount++
                                if (clickedCount >= 10) {
                                    clickedCount = 0
                                    configManager.setTestEnv(!configManager.getTestEnv())
                                    versionValue.text = qsTr("Version: %1").arg(Qt.application.version) + (configManager.getTestEnv() ? qsTr("(Test Env)") : "")
                                    message.info(qsTr("You need to restart the client."))
                                }
                            } else {
                                clickedCount = 0
                            }
                        }
                    }
                }
            }

            CustomToolSeparator {
                Layout.leftMargin: 30
                Layout.rightMargin: 30
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -85
            }

            Rectangle {
                id: listviewLayout
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -50
                Layout.preferredHeight: listView.contentHeight
                Layout.fillWidth: true

                ListView {
                    id: listView
                    spacing: 0
                    height: listModel.count * 56
                    width: parent.width
                    model: ListModel {
                        id: listModel
                    }
                    delegate: Rectangle {
                        height: 56
                        width: listView.width
                        Label {
                            color: "#222222"
                            font.pixelSize: 14
                            text: model.text
                            anchors.left: parent.left
                            anchors.leftMargin: 30
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Image {
                            source: "qrc:/qml/images/public/icons/arrow_right.png"
                            mipmap: true
                            anchors.right: parent.right
                            anchors.rightMargin: 30
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        CustomToolSeparator {
                            width: parent.width - 60
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            preventStealing: true
                            onEntered: parent.color = "#efefef"
                            onExited: parent.color = "#ffffff"
                            onReleased: parent.color = "#ffffff"
                            onClicked: {
                                Qt.openUrlExternally(model.url)
                            }
                        }
                    }
                }
            }

            Label {
                color: "#333333"
                font.pixelSize: 12
                text: qsTr("Copyright NetEase ©1997-%1").arg(new Date().getFullYear())
                Layout.bottomMargin: 30
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
