import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../components"

CustomPopup {
    property var clientUpdateInfo
    property int updateType: 2
    property bool download: false

    id: root
    width: 320
    height: 209
    padding: 0
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    margins: 0
    closePolicy: Popup.NoAutoClose

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    function decodeUnicode(str) {
        return unescape(str.replace(/\\u/gi, '%u'))
    }

    onClosed: {
        if (updateType === 5) {
            mainWindow.close()
        }
    }

    Label {
        id: title
        visible: !download
        text: decodeUnicode(clientUpdateInfo.title)
        font.pixelSize: 18
        font.bold: true
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
    }

    ScrollView {
        id: view
        visible: !download
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.bottom: horizontalSep.top
        anchors.bottomMargin: 6
        TextArea {
            id: textArea
            wrapMode: TextArea.Wrap
            selectByMouse: true
            readOnly: true
            topPadding: 0
            bottomPadding: 0
            leftPadding: 20
            rightPadding: 20
            font.pixelSize: 14
            text: decodeUnicode(clientUpdateInfo.description)
            background: null
        }
    }

    Label {
        id: titleProgress
        visible: download
        text: "0.0 M/0.0 M"
        font.pixelSize: 12
        anchors.top: parent.top
        anchors.topMargin: 65
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
    }

    CustomProgressBar {
        id: idProgressBar
        visible: download
        value: 0.0
        anchors.top: parent.top
        anchors.topMargin: 85
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        Layout.fillWidth: true
    }

    RowLayout {
        id: idAnimatedImage
        visible: Qt.platform.os === 'osx' && download && (Math.abs(100.0 - idProgressBar.value) <= Number.EPSILON)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: idProgressBar.bottom
        anchors.topMargin: 6
        height: 24
        spacing: 2

        AnimatedImage {
            id: animation
            Layout.preferredHeight: 24
            Layout.preferredWidth: 24
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            source: "qrc:/qml/images/public/icons/loading-ring-medium.gif"
            antialiasing:true
            smooth: true
            playing: idAnimatedImage.visible
        }

        Label {
            text: qsTr("Installing...")
            color: "#337EFF"
            font.pixelSize: 12
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        }
    }

    CustomToolSeparator {
        id: horizontalSep
        anchors.bottom: btnCancel.top
        leftPadding: 1
        orientation: Qt.Horizontal
        contentItem: Rectangle {
            implicitWidth: root.width-1
            implicitHeight: 1
            color: "#EDEEF0"
        }
    }

    CustomButton {
        id: btnCancel
        visible: !download
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        width: parent.width / 2 - 2
        height: 42
        text: updateType === 5 ? qsTr("Quit") : qsTr("Later")
        buttonRadius: Qt.platform.os === 'windows' ? 1 : 8
        borderColor: "#FFFFFF"
        normalTextColor: "#333333"
        borderSize: 0
        onClicked: {
            if (updateType === 5) {
                mainWindow.close()
            } else {
                updateIgnore = clientUpdater.getLatestVersion()
                root.close()
            }
        }
    }
    
    CustomToolSeparator {
        id: verticalSep
        visible: !download
        orientation: Qt.Vertical
        anchors.left: btnCancel.right
        anchors.top: horizontalSep.bottom
        contentItem: Rectangle {
            implicitHeight: btnCancel.height
            implicitWidth: 1
            color: "#EDEEF0"
        }
    }

    CustomButton {
        id: btnUpdate
        text: !download ? qsTr("Update Now") : qsTr("Cancel")
        anchors.right: parent.right
        anchors.rightMargin: 1
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        width: !download ? parent.width / 2 - 2 : parent.width - 2
        height: 42
        buttonRadius: Qt.platform.os === 'windows' ? 1 : 8
        borderColor: "#FFFFFF"
        normalTextColor: !download ? "#337EFF" : "#333333"
        borderSize: 0
        onClicked: {
            if (text === qsTr("Cancel")){
                clientUpdater.stopUpdate()
                download = false
                titleProgress.text = "0.0 M/0.0 M"
                idProgressBar.value = 0.0
            }
            else {
                clientUpdater.update()
                download = true
            }
        }
    }

    Connections {
        target: clientUpdater
        onDownloadProgressSignal: {
            titleProgress.text = fReceived.toFixed(1) + " M/" + fTotal.toFixed(1) + " M"
            idProgressBar.value = fReceived / fTotal * 100
        }
        onDownloadResultSignal: {
            if (!bSucc) {
                toast.show(qsTr('Failed to download, please try agine.'))
                if (btnUpdate.text === qsTr("Cancel")){
                    btnUpdate.clicked()
                }
            }
        }
    }

    function base64() {
        // private property
        _keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

        // public method for encoding
        this.encode = function (input) {
            var output = "";
            var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
            var i = 0;
            input = _utf8_encode(input);
            while (i < input.length) {
                chr1 = input.charCodeAt(i++);
                chr2 = input.charCodeAt(i++);
                chr3 = input.charCodeAt(i++);
                enc1 = chr1 >> 2;
                enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
                enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
                enc4 = chr3 & 63;
                if (isNaN(chr2)) {
                    enc3 = enc4 = 64;
                } else if (isNaN(chr3)) {
                    enc4 = 64;
                }
                output = output +
                        _keyStr.charAt(enc1) + _keyStr.charAt(enc2) +
                        _keyStr.charAt(enc3) + _keyStr.charAt(enc4);
            }
            return output;
        }

        // public method for decoding
        this.decode = function (input) {
            var output = "";
            var chr1, chr2, chr3;
            var enc1, enc2, enc3, enc4;
            var i = 0;
            input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
            while (i < input.length) {
                enc1 = _keyStr.indexOf(input.charAt(i++));
                enc2 = _keyStr.indexOf(input.charAt(i++));
                enc3 = _keyStr.indexOf(input.charAt(i++));
                enc4 = _keyStr.indexOf(input.charAt(i++));
                chr1 = (enc1 << 2) | (enc2 >> 4);
                chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
                chr3 = ((enc3 & 3) << 6) | enc4;
                output = output + String.fromCharCode(chr1);
                if (enc3 !== 64) {
                    output = output + String.fromCharCode(chr2);
                }
                if (enc4 !== 64) {
                    output = output + String.fromCharCode(chr3);
                }
            }
            output = _utf8_decode(output);
            return output;
        }

        // private method for UTF-8 encoding
        _utf8_encode = function (string) {
            string = string.replace(/\r\n/g,"\n");
            var utftext = "";
            for (var n = 0; n < string.length; n++) {
                var c = string.charCodeAt(n);
                if (c < 128) {
                    utftext += String.fromCharCode(c);
                } else if((c > 127) && (c < 2048)) {
                    utftext += String.fromCharCode((c >> 6) | 192);
                    utftext += String.fromCharCode((c & 63) | 128);
                } else {
                    utftext += String.fromCharCode((c >> 12) | 224);
                    utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                    utftext += String.fromCharCode((c & 63) | 128);
                }

            }
            return utftext;
        }

        // private method for UTF-8 decoding
        _utf8_decode = function (utftext) {
            var string = "";
            var i = 0;
            var c = c1 = c2 = 0;
            while ( i < utftext.length ) {
                c = utftext.charCodeAt(i);
                if (c < 128) {
                    string += String.fromCharCode(c);
                    i++;
                } else if((c > 191) && (c < 224)) {
                    c2 = utftext.charCodeAt(i+1);
                    string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
                    i += 2;
                } else {
                    c2 = utftext.charCodeAt(i+1);
                    c3 = utftext.charCodeAt(i+2);
                    string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
                    i += 3;
                }
            }
            return string;
        }
    }
}
