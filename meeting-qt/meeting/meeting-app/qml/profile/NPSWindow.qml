import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import NetEase.Meeting.HistoryModel 1.0
import "../components"

CustomPopup {
    id: feedbackWindow
    enum FeedbackStatus {
        None,
        Submitting
    }

    property bool reported: false
    property int status: NPSWindow.FeedbackStatus.None

    function showWindow() {
        textArea.clear();
        reported = false;
        feedbackWindow.open();
    }

    bottomInset: 0
    bottomPadding: 0
    closePolicy: Popup.NoAutoClose
    height: reported ? 294 : 384
    leftInset: 0
    leftPadding: 0
    rightInset: 0
    rightPadding: 0
    topInset: 0
    topPadding: 0
    visible: false
    width: 834

    ListModel {
        id: listModel
    }
    MessageManager {
        id: toast
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        DragArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            closeVisible: true
            title: reported ? '' : qsTr("What is the likelihood of you recommending NetEase Meeting to your colleagues or partners?")
            windowMode: false

            onCloseClicked: {
                feedbackWindow.close();
            }
        }
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: 40
            Layout.rightMargin: 40
            spacing: 0
            visible: !reported

            ListView {
                id: listView

                property int currentHovered: -1

                Layout.fillWidth: true
                Layout.preferredHeight: 70
                Layout.topMargin: 14
                clip: true
                interactive: false
                model: listModel
                orientation: ListView.Horizontal
                spacing: 0
                visible: !reported

                delegate: Rectangle {
                    height: 69
                    width: 69

                    Rectangle {
                        anchors.centerIn: parent
                        color: '#F2F3F5'
                        height: 50
                        radius: width / 2
                        visible: listView.currentIndex !== model.index && listView.currentHovered !== model.index
                        width: 50

                        Label {
                            anchors.centerIn: parent
                            font.pixelSize: 18
                            text: model.index.toString()
                        }
                    }
                    Image {
                        id: animatedImage
                        anchors.centerIn: parent
                        height: 65
                        source: model.image
                        visible: listView.currentIndex === model.index || listView.currentHovered === model.index
                        width: 65
                    }
                    MouseArea {
                        anchors.centerIn: parent
                        cursorShape: Qt.PointingHandCursor
                        height: animatedImage.height
                        hoverEnabled: true
                        width: animatedImage.width

                        onClicked: listView.currentIndex = model.index
                        onEntered: listView.currentHovered = model.index
                        onExited: {
                            if (listView.currentHovered !== model.index)
                                return;
                            listView.currentHovered = -1;
                        }
                    }
                }

                Component.onCompleted: {
                    listModel.append([{
                                "index": 0,
                                "image": 'qrc:/qml/images/front/feedback/angry.svg'
                            }, {
                                "index": 1,
                                "image": 'qrc:/qml/images/front/feedback/angry.svg'
                            }, {
                                "index": 2,
                                "image": 'qrc:/qml/images/front/feedback/angry.svg'
                            }, {
                                "index": 3,
                                "image": 'qrc:/qml/images/front/feedback/sad.svg'
                            }, {
                                "index": 4,
                                "image": 'qrc:/qml/images/front/feedback/sad.svg'
                            }, {
                                "index": 5,
                                "image": 'qrc:/qml/images/front/feedback/sad.svg'
                            }, {
                                "index": 6,
                                "image": 'qrc:/qml/images/front/feedback/sad.svg'
                            }, {
                                "index": 7,
                                "image": 'qrc:/qml/images/front/feedback/happy.svg'
                            }, {
                                "index": 8,
                                "image": 'qrc:/qml/images/front/feedback/happy.svg'
                            }, {
                                "index": 9,
                                "image": 'qrc:/qml/images/front/feedback/stirring.svg'
                            }, {
                                "index": 10,
                                "image": 'qrc:/qml/images/front/feedback/stirring.svg'
                            }]);
                    listView.currentIndex = -1;
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                Layout.topMargin: 8
                visible: !reported

                Label {
                    font.pixelSize: 16
                    text: qsTr('0 - Definitely not.')
                }
                Rectangle {
                    Layout.fillWidth: true
                }
                Label {
                    font.pixelSize: 16
                    text: qsTr('10 - Very willing.')
                }
            }
            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                Layout.topMargin: 16
                visible: !reported

                ScrollBar.vertical: ScrollBar {
                    width: 5

                    onActiveChanged: {
                        if (active) {
                            textArea.focus = false;
                        }
                    }
                }
                TextArea.flickable: TextArea {
                    id: textArea
                    padding: 10
                    placeholderText: listView.currentIndex === -1 ? qsTr('Please select a score first.') : listView.currentIndex <= 6 ? qsTr('What are the points that make you dissatisfied or disappointed? (optional)') : listView.currentIndex >= 7 && listView.currentIndex <= 8 ? qsTr('What aspects do you think can be improved? (optional)') : qsTr('Welcome to share your best experience or feelings. (optional)')
                    selectByKeyboard: true
                    selectByMouse: true
                    wrapMode: Text.WrapAnywhere

                    background: Rectangle {
                        border.color: '#DAE1E9'
                        border.width: 1
                        height: 120
                        radius: 2

                        RowLayout {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8
                            anchors.right: parent.right
                            anchors.rightMargin: 12

                            Label {
                                color: textArea.length === 500 ? '#FE3B30' : '#AAAAAA'
                                text: `${textArea.length}/500`
                            }
                        }
                    }

                    onTextChanged: if (length > 500)
                        remove(500, length)
                }
            }
            CustomButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 36
                Layout.preferredWidth: 135
                Layout.topMargin: 25
                enabled: listView.currentIndex !== -1 && feedbackWindow.status !== NPSWindow.FeedbackStatus.Submitting
                highlighted: true
                text: qsTr('Submit')
                visible: !reported

                onClicked: {
                    feedbackManager.invokeNPSFeedback(listView.currentIndex, textArea.text);
                    feedbackWindow.status = NPSWindow.FeedbackStatus.Submitting;
                    // closeTimer.start()
                }
            }
        }
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 80
            Layout.preferredWidth: 80
            Layout.topMargin: 40
            visible: reported

            Image {
                id: feedbackResultImage
                anchors.centerIn: parent
                height: 80
                source: 'qrc:/qml/images/front/feedback/satisfied.svg'
                width: 80

                Rotation {
                    angle: 30
                    origin.x: feedbackResultImage.width / 2
                    origin.y: feedbackResultImage.height / 2
                }
            }
        }
        Label {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 25
            Layout.topMargin: 4
            font.pixelSize: 18
            font.weight: Font.Medium
            text: qsTr('Thanks for your feedback.')
            visible: reported
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 9
            visible: false

            Label {
                font.pixelSize: 16
                text: qsTr('For more suggestions, please join the POPO group of NetEase Meeting (4781923821')
            }
            Image {
                Layout.preferredHeight: 16
                Layout.preferredWidth: 16
                source: 'qrc:/qml/images/public/icons/icon_copy.png'

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        clipboard.setText('4781923821');
                        idMessage.info(qsTr('POPO group ID has been copied'));
                    }
                }
            }
            Label {
                font.pixelSize: 16
                text: qsTr(')')
            }
        }
        Rectangle {
            Layout.fillHeight: true
        }
    }
    Connections {
        target: feedbackManager

        onFeedbackResult: {
            console.log(`feedback code: ${code}, result: ${result}`);
            feedbackWindow.status = NPSWindow.FeedbackStatus.None;
            if (code === 200) {
                listView.currentIndex = -1;
                reported = true;
            } else {
                toast.warning(qsTr('Failed to submit feedback, please try again later.'));
            }
        }
    }
    Timer {
        id: closeTimer
        interval: 2000
        repeat: false
        running: false

        onTriggered: {
            feedbackWindow.close();
        }
    }
}
