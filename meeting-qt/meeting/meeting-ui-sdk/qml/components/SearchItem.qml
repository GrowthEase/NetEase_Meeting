import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {
    id: root
    signal textChanged(string text)

    function resetSearchBar() {
        searchBar.text = '';
    }
    function trim(str) {
        return str.replace(/^\s+|\s+$/gm, '');
    }

    RowLayout {
        anchors.fill: parent
        spacing: 6

        Image {
            id: searchLogo
            Layout.leftMargin: 10
            Layout.preferredHeight: 16
            Layout.preferredWidth: 16
            Layout.topMargin: -10
            mipmap: true
            source: "qrc:/qml/images/public/icons/search.svg"
            visible: true
        }
        TextField {
            id: searchBar
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.rightMargin: 10
            Layout.topMargin: -3
            color: "#333333"
            font.pixelSize: 15
            placeholderText: qsTr("Search member")
            placeholderTextColor: "#A8ACB3"
            selectByMouse: true

            background: Rectangle {
                height: 0
            }

            onTextChanged: {
                root.textChanged(trim(text));
            }
        }
    }
}
