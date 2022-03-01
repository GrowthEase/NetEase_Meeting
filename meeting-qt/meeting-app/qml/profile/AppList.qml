import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../components"

CustomPopup {
    id: appsPopup
    height: mainLayout.height
    width: mainLayout.width
    padding: 0
    topInset: 0
    bottomInset: 0
    leftInset: 0
    rightInset: 0

    Component.onCompleted: {
    }

    ColumnLayout {
        id: mainLayout
        width: 300

        DragArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            title: qsTr('Apps')
            windowMode: false
            onCloseClicked: {
                appsPopup.close()
            }
        }

        ListView {
            id: listView
            Layout.preferredHeight: model.count * 42
            Layout.preferredWidth: 300
            Layout.topMargin: 10
            Layout.bottomMargin: 20
            model: ListModel {
                id: appListModel
            }
            delegate: ItemDelegate {
                height: 42
                width: listView.width
                enabled: meetingManager.neAppKey !== model.appKey
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 16
                    color: '#333333'
                    text: model.appName
                    width: parent.width - 50
                    elide: Label.ElideRight
                }
                Image {
                    width: 14
                    height: 14
                    visible: meetingManager.neAppKey === model.appKey
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    source: 'qrc:/qml/images/front/icon-selected.svg'
                }
                onClicked: {
                    authManager.switchApp(model.appKey, meetingManager.neAccountId, meetingManager.neAccountToken)
                }
            }
        }
    }

    Connections {
        target: authManager
        onGotAccountApps: {
            console.info('Got account app list: ', JSON.stringify(accountApps))
            appListModel.clear()
            for (let i = 0; i < accountApps.length; i++) {
                appListModel.append({ appName: accountApps[i].appName, appKey: accountApps[i].appKey })
            }
        }
        onSwitchedApp: {
            authManager.logout(true, true)
        }
    }
}
