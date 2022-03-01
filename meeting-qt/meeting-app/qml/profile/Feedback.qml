import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import '../components'

Window {
    id: feedbackWindow

    property bool showOptions: true
    property var problemsArray: []
    property int problemsCount: 0

    width: Qt.platform.os === 'windows' ? mainContainer.width + 20 : mainContainer.width
    height: Qt.platform.os === 'windows' ? mainContainer.height + 20 : mainContainer.height
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    Material.theme: Material.Light

    onVisibleChanged: {
        if (!visible) {
            textArea.clear()
            mouseAreaBad.enabled = true
            mouseAreaGood.enabled = true
            problemsCount = 0
            problemsArray = []
            authHideTimer.stop()
            repeaterModel.clear()
            mainContainer.state = 'unknown'
        } else {
            if (showOptions) {
                authHideTimer.restart()
            }
            repeaterModel.append({ option: qsTr('No sound') })
            repeaterModel.append({ option: qsTr('Noise') })
            repeaterModel.append({ option: qsTr('Sound freezes') })
            repeaterModel.append({ option: qsTr('No video') })
            repeaterModel.append({ option: qsTr('Video freezes') })
            repeaterModel.append({ option: qsTr('Blurred video') })
            repeaterModel.append({ option: qsTr('Sound and picture are out of sync') })
            repeaterModel.append({ option: qsTr('Quit unexpectedly') })
        }
    }

    Rectangle {
        id: mainContainer
        width: feedbackLayout.width
        height: feedbackLayout.height
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: Qt.platform.os === 'windows' ? 10 : 0
        anchors.topMargin: Qt.platform.os === 'windows' ? 10 : 0
        radius: Qt.platform.os === 'windows' ? 0 : 10
        states: [
            State {
                name: 'unknown'
            },
            State {
                name: "good";
            },
            State {
                name: "bad";
            },
            State {
                name: 'submit'
            }
        ]

        onHeightChanged: {
            Qt.callLater(function () {
                feedbackWindow.x = (Screen.width - feedbackWindow.width) / 2 + Screen.virtualX
                feedbackWindow.y = (Screen.height - feedbackWindow.height) / 2 + Screen.virtualY
                feedbackWindow.width = Qt.platform.os === 'windows' ? mainContainer.width + 20 : mainContainer.width
                feedbackWindow.height = Qt.platform.os === 'windows' ? mainContainer.height + 20 : mainContainer.height
            })
        }

        ColumnLayout {
            id: feedbackLayout
            width: 400
            spacing: 0

            DragArea {
                title: showOptions ? qsTr('How about this meeting?') : qsTr('Feedback')
                Layout.preferredHeight: 52
                Layout.fillWidth: true
            }
            // Buttons
            RowLayout {
                id: options
                spacing: 10
                visible: showOptions && mainContainer.state !== 'submit'
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.topMargin: 16
                Layout.bottomMargin: 25
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                Rectangle {
                    Layout.preferredHeight: 50
                    Layout.fillWidth: true
                    color: mainContainer.state === 'good' ? '#18337EFF' : '#F2F3F5'
                    radius: 4
                    RowLayout {
                        anchors.centerIn: parent
                        Image {
                            Layout.preferredHeight: 21
                            Layout.preferredWidth: 21
                            source: mainContainer.state === 'good' ? 'qrc:/qml/images/front/feedback/thumb-up-active.svg' : 'qrc:/qml/images/front/feedback/thumb-up.svg'
                        }
                        Label {
                            text: qsTr('Good')
                            color: '#222222'
                        }
                    }
                    MouseArea {
                        id: mouseAreaGood
                        anchors.fill: parent
                        cursorShape: Qt.ClosedHandCursor
                        onClicked: {
                            mainContainer.state = 'good'
                            authHideTimer.stop()
                            closeTimer.restart()
                            mouseAreaBad.enabled = false
                        }
                    }
                }
                Rectangle {
                    Layout.preferredHeight: 50
                    Layout.fillWidth: true
                    color: mainContainer.state == 'bad' ? '#18F24957' : '#F2F3F5'
                    radius: 4
                    RowLayout {
                        anchors.centerIn: parent
                        Image {
                            Layout.preferredHeight: 21
                            Layout.preferredWidth: 21
                            source: mainContainer.state == 'bad' ? 'qrc:/qml/images/front/feedback/thumbs-down-active.svg' : 'qrc:/qml/images/front/feedback/thumbs-down.svg'
                        }
                        Label {
                            text: qsTr('Bad')
                            color: '#222222'
                        }
                    }
                    MouseArea {
                        id: mouseAreaBad
                        anchors.fill: parent
                        cursorShape: Qt.ClosedHandCursor
                        onClicked: {
                            authHideTimer.stop()
                            mainContainer.state = 'bad'
                            mouseAreaGood.enabled = false
                        }
                    }
                }
            }
            // Bad result
            Label {
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr('What are your problems?')
                visible: mainContainer.state == 'bad'
                wrapMode: Label.WrapAnywhere
                Layout.topMargin: showOptions ? 0 : 25
                Layout.fillWidth: true
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                Layout.bottomMargin: 16
            }
            Repeater {
                Layout.preferredHeight: 230
                Layout.fillWidth: true
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                model: ListModel {
                    id: repeaterModel
                }
                delegate: CustomCheckBox {
                    text: model.option
                    Layout.leftMargin: 24
                    Layout.bottomMargin: 8
                    visible: mainContainer.state === 'bad'
                    onCheckedChanged: {
                        if (checked) {
                            let found = false
                            for (let j = 0; j < problemsArray.length; j++) {
                                if (problemsArray[j] === model.option) {
                                    found = true
                                }
                            }
                            if (!found) {
                                problemsArray.push(model.option)
                            }
                        } else {
                            for (let i = 0; i < problemsArray.length; i++) {
                                if (problemsArray[i] === model.option) {
                                    problemsArray.splice(i, 1)
                                    break
                                }
                            }
                        }
                        Qt.callLater(function() { problemsCount = problemsArray.length })
                        console.log('--------------------------------------', problemsArray.length, JSON.stringify(problemsArray))
                    }
                }
            }
            Flickable {
                Layout.fillWidth: true
                Layout.topMargin: 20
                Layout.bottomMargin: 20
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                Layout.preferredHeight: 80
                Layout.maximumHeight: 80
                visible: mainContainer.state == 'bad'
                TextArea.flickable: TextArea {
                    id: textArea
                    padding: 12
                    selectByMouse: true
                    selectByKeyboard: true
                    wrapMode: Text.WrapAnywhere
                    placeholderText: qsTr('Other problems.')
                    background: Rectangle {
                        border.width: 1
                        border.color: '#E1E3E6'
                        height: 80
                        radius: 4
                    }
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
            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                visible: mainContainer.state == 'bad'
                color: '#EBEDF0'
            }
            CustomButton {
                buttonRadius: 18
                highlighted: true
                visible: mainContainer.state == 'bad'
                enabled: problemsCount !== 0 || textArea.text.length !== 0
                Layout.topMargin: 11
                Layout.bottomMargin: 11
                Layout.preferredHeight: 36
                Layout.preferredWidth: 120
                Layout.alignment: Qt.AlignHCenter
                text: qsTr('Submit')
                onClicked: {
                    console.log('Invoke feedback in front, problems:', JSON.stringify(problemsArray), textArea.text)
                    mainContainer.state = 'submit'
                    mouseAreaBad.enabled = false
                    closeTimer.restart()
                    feedbackManager.invokeFeedback(problemsArray, textArea.text)
                }
            }
            Rectangle {
                Layout.preferredHeight: 60
                Layout.fillWidth: true
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                visible: mainContainer.state == 'good' || mainContainer.state === 'submit'
                RowLayout {
                    anchors.centerIn: parent
                    Image {
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: 24
                        source: 'qrc:/qml/images/front/feedback/smlie-active.svg'
                    }
                    Label {
                        font.pixelSize: 16
                        color: '#333333'
                        text: qsTr('Thanks for your report~')
                    }
                }
            }
        }
    }

    DropShadow {
        anchors.fill: mainContainer
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainContainer
        color: "#3217171A"
        spread: 0
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    Timer {
        id: authHideTimer
        repeat: false
        running: false
        interval: 6000
        onTriggered: {
            feedbackWindow.hide()
        }
    }

    Timer {
        id: closeTimer
        repeat: false
        running: false
        interval: 1500
        onTriggered: {
            feedbackWindow.hide()
        }
    }

    function showFeedbackWindow(options = true) {
        feedbackWindow.show()
        mainContainer.state = options ? 'unknown' : 'bad'
        showOptions = options
        feedbackWindow.x = (Screen.width - feedbackWindow.width) / 2 + Screen.virtualX
        feedbackWindow.y = (Screen.height - feedbackWindow.height) / 2 + Screen.virtualY
    }
}
