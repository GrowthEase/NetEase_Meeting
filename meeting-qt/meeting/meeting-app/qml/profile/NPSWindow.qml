import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import NetEase.Meeting.HistoryModel 1.0

import "../components"

CustomPopup {
    id: feedbackWindow
    width: 834
    height: reported ? 294 : 384
    closePolicy: Popup.NoAutoClose
    visible: false
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    enum FeedbackStatus {
        None,
        Submitting
    }

    property bool reported: false
    property int status: NPSWindow.FeedbackStatus.None

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
            title: reported ? '' : qsTr("What is the likelihood of you recommending NetEase Meeting to your colleagues or partners?")
            closeVisible: true
            windowMode: false
            Layout.preferredHeight: 50
            Layout.fillWidth: true
            onCloseClicked: {
                feedbackWindow.close()
            }
        }
        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 40
            Layout.rightMargin: 40
            visible: !reported
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                Layout.topMargin: 14
                visible: !reported
                orientation: ListView.Horizontal
                spacing: 0
                model: listModel
                clip: true
                interactive: false
                property int currentHovered: -1
                delegate: Rectangle {
                    width: 69
                    height: 69
                    Rectangle {
                        width: 50
                        height: 50
                        anchors.centerIn: parent
                        radius: width / 2
                        color: '#F2F3F5'
                        visible: listView.currentIndex !== model.index && listView.currentHovered !== model.index
                        Label {
                            font.pixelSize: 18
                            anchors.centerIn: parent
                            text: model.index.toString()
                        }
                    }
                    Image {
                        id: animatedImage
                        width: 65
                        height: 65
                        anchors.centerIn: parent
                        source: model.image
                        visible: listView.currentIndex === model.index || listView.currentHovered === model.index
                    }
                    MouseArea {
                        width: animatedImage.width
                        height: animatedImage.height
                        anchors.centerIn: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: listView.currentIndex = model.index
                        onEntered: listView.currentHovered = model.index
                        onExited: {
                            if (listView.currentHovered !== model.index) return
                            listView.currentHovered = -1
                        }
                    }
                }
                Component.onCompleted: {
                    listModel.append([{
                        index: 0,
                        image: 'qrc:/qml/images/front/feedback/angry.svg'
                    }, {
                        index: 1,
                        image: 'qrc:/qml/images/front/feedback/angry.svg'
                    }, {
                        index: 2,
                        image: 'qrc:/qml/images/front/feedback/angry.svg'
                    }, {
                        index: 3,
                        image: 'qrc:/qml/images/front/feedback/sad.svg'
                    }, {
                        index: 4,
                        image: 'qrc:/qml/images/front/feedback/sad.svg'
                    }, {
                        index: 5,
                        image: 'qrc:/qml/images/front/feedback/sad.svg'
                    }, {
                        index: 6,
                        image: 'qrc:/qml/images/front/feedback/sad.svg'
                    }, {
                        index: 7,
                        image: 'qrc:/qml/images/front/feedback/happy.svg'
                    }, {
                        index: 8,
                        image: 'qrc:/qml/images/front/feedback/happy.svg'
                    }, {
                        index: 9,
                        image: 'qrc:/qml/images/front/feedback/stirring.svg'
                    }, {
                        index: 10,
                        image: 'qrc:/qml/images/front/feedback/stirring.svg'
                    }])
                    listView.currentIndex = -1
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
                Rectangle { Layout.fillWidth: true }
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
                TextArea.flickable: TextArea {
                    id: textArea
                    padding: 10
                    selectByMouse: true
                    selectByKeyboard: true
                    wrapMode: Text.WrapAnywhere
                    placeholderText: listView.currentIndex === -1
                        ? qsTr('Please select a score first.')
                        : listView.currentIndex <= 6
                            ? qsTr('What are the points that make you dissatisfied or disappointed? (optional)')
                            : listView.currentIndex >=7 && listView.currentIndex <= 8
                                ? qsTr('What aspects do you think can be improved? (optional)')
                                : qsTr('Welcome to share your best experience or feelings. (optional)')
                    background: Rectangle {
                        border.width: 1
                        border.color: '#DAE1E9'
                        height: 120
                        radius: 2
                        RowLayout {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: 12
                            anchors.bottomMargin: 8
                            Label { text: `${textArea.length}/500`; color: textArea.length === 500 ? '#FE3B30' : '#AAAAAA' }
                        }
                    }
                    onTextChanged: if (length > 500) remove(500, length);
                }
                ScrollBar.vertical: ScrollBar {
                    width: 5
                    onActiveChanged: {
                        if (active) {
                            textArea.focus = false
                        }
                    }
                }
            }
            CustomButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 135
                Layout.preferredHeight: 36
                Layout.topMargin: 25
                visible: !reported
                enabled: listView.currentIndex !== -1 && feedbackWindow.status !== NPSWindow.FeedbackStatus.Submitting
                highlighted: true
                text: qsTr('Submit')
                onClicked: {
                    feedbackManager.invokeNPSFeedback(listView.currentIndex, textArea.text)
                    feedbackWindow.status = NPSWindow.FeedbackStatus.Submitting
                    // closeTimer.start()
                }
            }
        }
        Rectangle {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            Layout.topMargin: 40
            Layout.alignment: Qt.AlignHCenter
            visible: reported
            Image {
                id: feedbackResultImage
                width: 80
                height: 80
                anchors.centerIn: parent
                source: 'qrc:/qml/images/front/feedback/satisfied.svg'
                Rotation {
                    origin.x: feedbackResultImage.width / 2
                    origin.y: feedbackResultImage.height / 2
                    angle: 30
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
            Layout.topMargin: 9
            Layout.alignment: Qt.AlignHCenter
            visible: false
            Label {
                font.pixelSize: 16
                text: qsTr('For more suggestions, please join the POPO group of NetEase Meeting (4781923821')
            }
            Image {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                source: 'qrc:/qml/images/public/icons/icon_copy.png'
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        clipboard.setText('4781923821')
                        idMessage.info(qsTr('POPO group ID has been copied'))
                    }
                }
            }
            Label {
                font.pixelSize: 16
                text: qsTr(')')
            }
        }
        Rectangle { Layout.fillHeight: true }
    }

    Connections {
        target: feedbackManager
        onFeedbackResult: {
            console.log(`feedback code: ${code}, result: ${result}`)
            feedbackWindow.status = NPSWindow.FeedbackStatus.None
            if (code === 200) {
                listView.currentIndex = -1
                reported = true
            } else {
                toast.warning(qsTr('Failed to submit feedback, please try again later.'))
            }
        }
    }

    Timer {
        id: closeTimer
        repeat: false
        running: false
        interval: 2000
        onTriggered: {
            feedbackWindow.close()
        }
    }

    function showWindow() {
        textArea.clear()
        reported = false
        feedbackWindow.open()
    }
}
