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
    property bool hasOtherProblems: false
    property var problemsTotalArray: [qsTr("The voice of the other party has a long time delay"),
                                      qsTr("Play mechanical sound"),
                                      qsTr("The other party's voice is very stuck"),
                                      qsTr("Murmur"),
                                      qsTr("Echo"),
                                      qsTr("Can't hear the other party's voice"),
                                      qsTr("The other party can't hear me"),
                                      qsTr("Low volume"),
                                      qsTr("Video freezes for a long time"),
                                      qsTr("Intermittent video"),
                                      qsTr("Screen tearing"),
                                      qsTr("The picture is too bright"),
                                      qsTr("Blurred picture"),
                                      qsTr("The picture is noisy"),
                                      qsTr("Audio and video are out of sync"),
                                      qsTr("Quit unexpectedly")]

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
            if(mainContainer.state != 'submiting') {
                mainContainer.state = 'unknown'
            }
            checkBox_0.checked = false
            checkBox_1.checked = false
            checkBox_2.checked = false
            checkBox_3.checked = false
            checkBox_4.checked = false
            checkBox_5.checked = false
            checkBox_6.checked = false
            checkBox_7.checked = false
            checkBox_8.checked = false
            checkBox_9.checked = false
            checkBox_10.checked = false
            checkBox_11.checked = false
            checkBox_12.checked = false
            checkBox_13.checked = false
            checkBox_14.checked = false
            checkBox_15.checked = false
            checkBox_other.checked = false
        } else {
            if(mainContainer.state == 'submiting') {
                if(meetingManager.getCurrentMeetingStatus() === 4) {
                    closeTimer.restart()
                }
            } else {
                if (showOptions) {
                    authHideTimer.restart()
                }
            }
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
                name: 'submiting'
            },
            State {
                name: 'submited'
            },
            State {
                name: 'submitFailed'
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
                closeVisible: mainContainer.state != 'submiting'
                title: showOptions ? qsTr('How about this meeting?') : qsTr('Feedback')
                Layout.preferredHeight: 52
                Layout.fillWidth: true
            }

            RowLayout {
                id: rowSubmiting
                visible: mainContainer.state === 'submiting' || mainContainer.state === 'submitFailed'
                spacing: 4
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.preferredHeight: 60
                Rectangle {
                    visible: mainContainer.state === 'submiting'
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    BusyIndicator {
                        anchors.fill: parent
                        running: true
                    }
                }
                Label {
                    text: qsTr('Your feedback is being submitted, please wait...')
                    color: "#337EFF"
                    visible: mainContainer.state === 'submiting'
                }
                Label {
                    text: qsTr('feedback error, please try later')
                    color: "#F24957"
                    visible: mainContainer.state === 'submitFailed'
                }
            }

            // Buttons
            RowLayout {
                id: options
                spacing: 10
                visible: showOptions && mainContainer.state !== 'submiting' && mainContainer.state !== 'submited'
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
                            mipmap: true
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
                            mipmap: true
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

            ColumnLayout {
                id: columnOptions
                visible: mainContainer.state == 'bad'
                spacing: 20
                Layout.topMargin: showOptions ? 0 : 20
                Layout.leftMargin: 24

                Item {
                    id: audioTag
                    height: audioTagLayout.height
                    ColumnLayout {
                        id: audioTagLayout
                        spacing: 16
                        Label {
                            text: qsTr("audio problems")
                            font.pixelSize: 20
                        }

                        ColumnLayout {
                            spacing: 12
                            RowLayout {
                                spacing: 24
                                CustomCheckBox {
                                    id: checkBox_0
                                    text:problemsTotalArray[0]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_1
                                    text:problemsTotalArray[1]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }

                            RowLayout {
                                spacing: 24
                                CustomCheckBox {
                                    id: checkBox_2
                                    text:problemsTotalArray[2]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_3
                                    text:problemsTotalArray[3]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_4
                                    text:problemsTotalArray[4]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }

                            RowLayout {
                                spacing: 24
                                CustomCheckBox {
                                    id: checkBox_5
                                    text:problemsTotalArray[5]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_6
                                    text:problemsTotalArray[6]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }

                            CustomCheckBox {
                                id: checkBox_7
                                text:problemsTotalArray[7]
                                onCheckedChanged: onCheckboxClicked(checked, text)

                            }
                        }

                    }
                }

                Item {
                    id: videoTag
                    height: videoTagLayout.height
                    ColumnLayout {
                        id: videoTagLayout
                        spacing: 16
                        Label {
                            text: qsTr("video problems")
                            font.pixelSize: 20
                        }

                        ColumnLayout {
                            spacing: 12
                            RowLayout {
                                spacing: 24
                                CustomCheckBox {
                                    id: checkBox_8
                                    text:problemsTotalArray[8]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_9
                                    text:problemsTotalArray[9]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }

                            RowLayout {
                                spacing: 24
                                CustomCheckBox {
                                    id: checkBox_10
                                    text:problemsTotalArray[10]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_11
                                    text:problemsTotalArray[11]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }

                            RowLayout {
                                spacing: 24
                                CustomCheckBox {
                                    id: checkBox_12
                                    text:problemsTotalArray[12]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_13
                                    text:problemsTotalArray[13]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_14
                                    text:problemsTotalArray[14]
                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }
                        }

                    }
                }

                Item {
                    id: otherProblem
                    height: otherProblemLayout.height
                    ColumnLayout {
                        id: otherProblemLayout
                        Layout.fillWidth: true
                        spacing: 16
                        Label {
                            text: qsTr("Others")
                            font.pixelSize: 20
                        }

                        ColumnLayout {
                            spacing: 12
                            Layout.fillWidth: true

                            CustomCheckBox {
                                id: checkBox_15
                                text:problemsTotalArray[15]
                                onCheckedChanged: onCheckboxClicked(checked, text)
                            }
                            CustomCheckBox {
                                id: checkBox_other
                                text: qsTr("There are other problems")
                                onCheckedChanged: {
                                    hasOtherProblems = checkBox_other.checkState == Qt.Checked
                                }
                            }

                            Flickable {
                                Layout.preferredHeight: 84
                                Layout.preferredWidth: 350
                                TextArea.flickable: TextArea {
                                    id: textArea
                                    padding: 12
                                    selectByMouse: true
                                    selectByKeyboard: true
                                    wrapMode: Text.WrapAnywhere
                                    placeholderText: qsTr('Please describe your problem \n When you select "There are other problems", you need to fill in a specific description before submitting')
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
                        }
                    }

                }

                Item {
                    Layout.preferredHeight: 1
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
                enabled: ((problemsCount !== 0 && !hasOtherProblems) || textArea.text.length !== 0
                          ||(hasOtherProblems && textArea.text.length !== 0))
                Layout.topMargin: 11
                Layout.bottomMargin: 11
                Layout.preferredHeight: 36
                Layout.preferredWidth: 120
                Layout.alignment: Qt.AlignHCenter
                text: qsTr('Submit')
                onClicked: {
                    console.log('Invoke feedback in front, problems:', JSON.stringify(problemsArray), textArea.text)
                    mainContainer.state = 'submiting'
                    mouseAreaBad.enabled = false

                    let audioDump = false
                    for (let j = 0; j < problemsArray.length; j++) {
                        var index = problemsTotalArray.indexOf(problemsArray[j])
                        if(index > -1 && index < 8) {
                            audioDump = true
                            console.log("need audioDump,", audioDump)
                            break;
                        }
                    }

                    feedbackManager.invokeFeedback(problemsArray, textArea.text, audioDump)
                }
            }
            Rectangle {
                Layout.preferredHeight: 60
                Layout.fillWidth: true
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                visible: mainContainer.state == 'good' || mainContainer.state === 'submited'
                RowLayout {
                    anchors.centerIn: parent
                    Image {
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: 24
                        mipmap: true
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
            console.log("closeTimer onTriggered")
            feedbackWindow.hide()
        }
    }

    function showFeedbackWindow(options = true) {
        feedbackWindow.show()
        if(mainContainer.state != 'submiting') {
            mainContainer.state = options ? 'unknown' : 'bad'
            showOptions = options
        } else {
            showOptions = false
        }
        feedbackWindow.x = (Screen.width - feedbackWindow.width) / 2 + Screen.virtualX
        feedbackWindow.y = (Screen.height - feedbackWindow.height) / 2 + Screen.virtualY
    }

    Connections {
        target: feedbackManager
        onFeedbackResult: {
            if(code === 200) {
                mainContainer.state = 'submited'
            } else {
                mainContainer.state = 'submitFailed'
            }
            if(feedbackWindow.visible) {
                closeTimer.restart()
            }
        }

        onZiplogFinished: {
            if(meetingManager.getCurrentMeetingStatus() === 4) {
                feedbackWindow.hide()
            }
        }
    }

    function onCheckboxClicked(checkState, checkText){
        if (checkState) {
            let found = false
            for (let j = 0; j < problemsArray.length; j++) {
                if (problemsArray[j] === checkText) {
                    found = true
                }
            }
            if (!found) {
                problemsArray.push(checkText)
            }
        } else {
            for (let i = 0; i < problemsArray.length; i++) {
                if (problemsArray[i] === checkText) {
                    problemsArray.splice(i, 1)
                    break
                }
            }
        }
        Qt.callLater(function() { problemsCount = problemsArray.length })
        console.log('--------------------------------------', problemsArray.length, JSON.stringify(problemsArray))
    }
}
