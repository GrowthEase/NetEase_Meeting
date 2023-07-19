import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    property var accountInfo

    signal signOut()

    Component.onCompleted: {
        profileModel.append({ key: qsTr('Account'), value: accountInfo.accountName })
        profileModel.append({ key: qsTr('Account ID'), value: accountInfo.accountId })
        profileModel.append({ key: qsTr('Nickname'), value: accountInfo.displayName })
        profileModel.append({ key: qsTr('Personal ID'), value: accountInfo.personalId })
        profileModel.append({ key: qsTr('Short ID'), value: accountInfo.shortPersonalId })
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        ListView {
            Layout.preferredHeight: profileModel.count * 36
            Layout.fillWidth: true
            model: ListModel {
                id: profileModel
            }
            delegate: ItemDelegate {
                height: 36
                width: parent.width
                RowLayout {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        text: model.key
                        font.weight: Font.Medium
                        Layout.leftMargin: 15
                        Layout.preferredWidth: 80
                    }
                    Label {
                        text: model.value || 'None'
                        horizontalAlignment: Qt.AlignRight
                        font.weight: Font.Light
                        Layout.fillWidth: true
                        Layout.rightMargin: 15
                    }
                }
            }
        }
        Button {
            text: qsTr('Sign out')
            onClicked: signOut()
            Layout.minimumHeight: 25
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
