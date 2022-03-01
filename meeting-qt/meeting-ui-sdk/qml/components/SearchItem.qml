import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

Rectangle {
    id: root

    signal textChanged(string text)

    RowLayout {
        anchors.fill: parent
        spacing: 6

        Image {
            id: searchLogo
            Layout.preferredHeight: 16
            Layout.preferredWidth: 16
            visible: true
            source: "qrc:/qml/images/public/icons/search.svg"
            Layout.leftMargin: 10
            Layout.topMargin: -10
        }

        TextField {
            id: searchBar
//          maximumLength: 10
            font.pixelSize: 15
            placeholderTextColor: "#A8ACB3"
            placeholderText: qsTr("Search member")
            selectByMouse: true
            Layout.alignment: Qt.AlignVCenter
            Layout.topMargin: -3
            Layout.fillWidth: true
            color: "#333333"
            background: Rectangle {
                height: 0
            }
//            validator: RegExpValidator {
//                regExp: /\w{1,10}/
//            }
            onTextChanged: {
                root.textChanged(trim(text));
            }
        }
    }

    function resetSearchBar() {
        searchBar.text = ''
    }

    function trim(str){
        return str.replace(/^\s+|\s+$/gm,'')
    }
}

