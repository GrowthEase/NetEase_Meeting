import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    property string ssoAppKey: ''
    property string ssoUser: ''
    property string ssoToken: ''

    ColumnLayout {
        anchors.centerIn: parent

        Image {
            id: logo
            Layout.preferredWidth: 220
            Layout.preferredHeight: 58
            source: "qrc:/qml/images/logo.png"
            mipmap: true
        }

        RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                Layout.preferredHeight: 30
                Layout.preferredWidth: 30

                BusyIndicator {
                    anchors.fill: parent
                    running: true
                }
            }

            Label {
                font.pixelSize: 18
                text: qsTr("logging in")
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
