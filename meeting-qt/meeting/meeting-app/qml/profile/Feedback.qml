import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
import "../components"

Window {
    id: feedbackWindow

    property bool hasOtherProblems: false
    property var problemsArray: []
    property int problemsCount: 0
    property var problemsTotalArray: [qsTr("Voice delay"), qsTr("Robotic sound"), qsTr("Audio stuttering"), qsTr("Murmur"), qsTr("Echo"), qsTr("Can't hear others"), qsTr("Can't hear my voice"), qsTr("Low volume"), qsTr("Stuttering"), qsTr("Cutting out"), qsTr("Screen tearing"), qsTr("Overexposed/Underexposed"), qsTr("Blurred"), qsTr("Visual noise"), qsTr("A/V out of sync"), qsTr("Quit unexpectedly")]
    property bool showOptions: true

    function onCheckboxClicked(checkState, checkText) {
        if (checkState) {
            let found = false;
            for (let j = 0; j < problemsArray.length; j++) {
                if (problemsArray[j] === checkText) {
                    found = true;
                }
            }
            if (!found) {
                problemsArray.push(checkText);
            }
        } else {
            for (let i = 0; i < problemsArray.length; i++) {
                if (problemsArray[i] === checkText) {
                    problemsArray.splice(i, 1);
                    break;
                }
            }
        }
        Qt.callLater(function () {
                problemsCount = problemsArray.length;
            });
    }
    function showFeedbackWindow(options = true) {
        feedbackWindow.show();
        if (mainContainer.state != 'submiting') {
            mainContainer.state = options ? 'unknown' : 'bad';
            showOptions = options;
        } else {
            showOptions = false;
        }
        feedbackWindow.x = (Screen.width - feedbackWindow.width) / 2 + Screen.virtualX;
        feedbackWindow.y = (Screen.height - feedbackWindow.height) / 2 + Screen.virtualY;
    }

    Material.theme: Material.Light
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    height: Qt.platform.os === 'windows' ? mainContainer.height + 20 : mainContainer.height
    width: Qt.platform.os === 'windows' ? mainContainer.width + 20 : mainContainer.width

    onVisibleChanged: {
        if (!visible) {
            textArea.clear();
            mouseAreaBad.enabled = true;
            mouseAreaGood.enabled = true;
            problemsCount = 0;
            problemsArray = [];
            authHideTimer.stop();
            if (mainContainer.state != 'submiting') {
                mainContainer.state = 'unknown';
            }
            checkBox_0.checked = false;
            checkBox_1.checked = false;
            checkBox_2.checked = false;
            checkBox_3.checked = false;
            checkBox_4.checked = false;
            checkBox_5.checked = false;
            checkBox_6.checked = false;
            checkBox_7.checked = false;
            checkBox_8.checked = false;
            checkBox_9.checked = false;
            checkBox_10.checked = false;
            checkBox_11.checked = false;
            checkBox_12.checked = false;
            checkBox_13.checked = false;
            checkBox_14.checked = false;
            checkBox_15.checked = false;
            checkBox_other.checked = false;
        } else {
            if (mainContainer.state == 'submiting') {
                if (meetingManager.getCurrentMeetingStatus() === 4)
                    closeTimer.restart();
            } else {
                if (showOptions)
                    authHideTimer.restart();
            }
            console.log(`mainContainer.height when visibility changed: ${mainContainer.height}`);
        }
    }

    Rectangle {
        id: mainContainer
        anchors.left: parent.left
        anchors.leftMargin: Qt.platform.os === 'windows' ? 10 : 0
        anchors.top: parent.top
        anchors.topMargin: Qt.platform.os === 'windows' ? 10 : 0
        height: feedbackLayout.height
        radius: Qt.platform.os === 'windows' ? 0 : 10
        width: feedbackLayout.width

        states: [
            State {
                name: 'unknown'
            },
            State {
                name: "good"
            },
            State {
                name: "bad"
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
                    feedbackWindow.width = Qt.platform.os === 'windows' ? mainContainer.width + 20 : mainContainer.width;
                    feedbackWindow.height = Qt.platform.os === 'windows' ? mainContainer.height + 20 : mainContainer.height;
                    feedbackWindow.x = (Screen.width - feedbackWindow.width) / 2 + Screen.virtualX;
                    feedbackWindow.y = (Screen.height - feedbackWindow.height) / 2 + Screen.virtualY;
                    console.log(`mainContainer.height when height changed: ${mainContainer.height}`);
                });
        }

        ColumnLayout {
            id: feedbackLayout
            spacing: 0
            width: 400

            DragArea {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                closeVisible: mainContainer.state != 'submiting'
                title: showOptions ? qsTr('How about this meeting?') : qsTr('Feedback')
            }
            RowLayout {
                id: rowSubmiting
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.preferredHeight: 60
                spacing: 4
                visible: mainContainer.state === 'submiting' || mainContainer.state === 'submitFailed'

                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: 28
                    visible: mainContainer.state === 'submiting'

                    BusyIndicator {
                        anchors.fill: parent
                        running: true
                    }
                }
                Label {
                    color: "#337EFF"
                    text: qsTr('Your feedback is being submitted, please wait...')
                    visible: mainContainer.state === 'submiting'
                }
                Label {
                    color: "#F24957"
                    text: qsTr('feedback error, please try later')
                    visible: mainContainer.state === 'submitFailed'
                }
            }

            // Buttons
            RowLayout {
                id: options
                Layout.bottomMargin: 25
                Layout.fillWidth: true
                Layout.leftMargin: 24
                Layout.preferredHeight: 50
                Layout.rightMargin: 24
                Layout.topMargin: 16
                spacing: 10
                visible: showOptions && mainContainer.state !== 'submiting' && mainContainer.state !== 'submited'

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
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
                            color: '#222222'
                            text: qsTr('Good')
                        }
                    }
                    MouseArea {
                        id: mouseAreaGood
                        anchors.fill: parent
                        cursorShape: Qt.ClosedHandCursor

                        onClicked: {
                            mainContainer.state = 'good';
                            authHideTimer.stop();
                            closeTimer.restart();
                            mouseAreaBad.enabled = false;
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
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
                            color: '#222222'
                            text: qsTr('Bad')
                        }
                    }
                    MouseArea {
                        id: mouseAreaBad
                        anchors.fill: parent
                        cursorShape: Qt.ClosedHandCursor

                        onClicked: {
                            authHideTimer.stop();
                            mainContainer.state = 'bad';
                            mouseAreaGood.enabled = false;
                        }
                    }
                }
            }
            ColumnLayout {
                id: columnOptions
                Layout.leftMargin: 24
                Layout.topMargin: showOptions ? 0 : 20
                spacing: 20
                visible: mainContainer.state == 'bad'

                Item {
                    id: audioTag
                    height: audioTagLayout.height

                    ColumnLayout {
                        id: audioTagLayout
                        spacing: 16

                        Label {
                            font.pixelSize: 20
                            text: qsTr("audio problems")
                        }
                        ColumnLayout {
                            spacing: 12

                            RowLayout {
                                spacing: 24

                                CustomCheckBox {
                                    id: checkBox_0
                                    text: problemsTotalArray[0]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_1
                                    text: problemsTotalArray[1]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }
                            RowLayout {
                                spacing: 24

                                CustomCheckBox {
                                    id: checkBox_2
                                    text: problemsTotalArray[2]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_3
                                    text: problemsTotalArray[3]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_4
                                    text: problemsTotalArray[4]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }
                            RowLayout {
                                spacing: 24

                                CustomCheckBox {
                                    id: checkBox_5
                                    text: problemsTotalArray[5]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_6
                                    text: problemsTotalArray[6]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }
                            CustomCheckBox {
                                id: checkBox_7
                                text: problemsTotalArray[7]

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
                            font.pixelSize: 20
                            text: qsTr("video problems")
                        }
                        ColumnLayout {
                            spacing: 12

                            RowLayout {
                                spacing: 24

                                CustomCheckBox {
                                    id: checkBox_8
                                    text: problemsTotalArray[8]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_9
                                    text: problemsTotalArray[9]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }
                            RowLayout {
                                spacing: 24

                                CustomCheckBox {
                                    id: checkBox_10
                                    text: problemsTotalArray[10]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_11
                                    text: problemsTotalArray[11]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                            }
                            RowLayout {
                                spacing: 24

                                CustomCheckBox {
                                    id: checkBox_12
                                    text: problemsTotalArray[12]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_13
                                    text: problemsTotalArray[13]

                                    onCheckedChanged: onCheckboxClicked(checked, text)
                                }
                                CustomCheckBox {
                                    id: checkBox_14
                                    text: problemsTotalArray[14]

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
                            font.pixelSize: 20
                            text: qsTr("Others")
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            CustomCheckBox {
                                id: checkBox_15
                                text: problemsTotalArray[15]

                                onCheckedChanged: onCheckboxClicked(checked, text)
                            }
                            CustomCheckBox {
                                id: checkBox_other
                                text: qsTr("There are other problems")

                                onCheckedChanged: {
                                    hasOtherProblems = checkBox_other.checkState == Qt.Checked;
                                }
                            }
                            Flickable {
                                Layout.preferredHeight: 84
                                Layout.preferredWidth: 350

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
                                    padding: 12
                                    placeholderText: qsTr('Please describe your problem.')
                                    selectByKeyboard: true
                                    selectByMouse: true
                                    wrapMode: Text.WrapAnywhere

                                    background: Rectangle {
                                        border.color: '#E1E3E6'
                                        border.width: 1
                                        height: 80
                                        radius: 4
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
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: '#EBEDF0'
                visible: mainContainer.state == 'bad'
            }
            CustomButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 11
                Layout.preferredHeight: 36
                Layout.preferredWidth: 120
                Layout.topMargin: 11
                buttonRadius: 18
                enabled: ((problemsCount !== 0 && !hasOtherProblems) || textArea.text.length !== 0 || (hasOtherProblems && textArea.text.length !== 0))
                highlighted: true
                text: qsTr('Submit')
                visible: mainContainer.state == 'bad'

                onClicked: {
                    console.log('Invoke feedback in front, problems:', JSON.stringify(problemsArray), textArea.text);
                    mainContainer.state = 'submiting';
                    mouseAreaBad.enabled = false;
                    let audioDump = false;
                    for (let j = 0; j < problemsArray.length; j++) {
                        var index = problemsTotalArray.indexOf(problemsArray[j]);
                        if (index > -1 && index < 8) {
                            audioDump = true;
                            console.log("need audioDump,", audioDump);
                            break;
                        }
                    }
                    feedbackManager.invokeFeedback(problemsArray, textArea.text, audioDump);
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 24
                Layout.preferredHeight: 60
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
                        color: '#333333'
                        font.pixelSize: 16
                        text: qsTr('Thanks for your report~')
                    }
                }
            }
        }
    }
    DropShadow {
        anchors.fill: mainContainer
        color: "#3217171A"
        horizontalOffset: 0
        radius: 10
        samples: 16
        source: mainContainer
        spread: 0
        verticalOffset: 0
        visible: Qt.platform.os === 'windows'

        Behavior on radius  {
            PropertyAnimation {
                duration: 100
            }
        }
    }
    Timer {
        id: authHideTimer
        interval: 6000
        repeat: false
        running: false

        onTriggered: {
            feedbackWindow.hide();
        }
    }
    Timer {
        id: closeTimer
        interval: 1500
        repeat: false
        running: false

        onTriggered: {
            console.log("closeTimer onTriggered");
            feedbackWindow.hide();
        }
    }
    Connections {
        target: feedbackManager

        onFeedbackResult: {
            if (code === 200) {
                mainContainer.state = 'submited';
            } else {
                mainContainer.state = 'submitFailed';
            }
            if (feedbackWindow.visible) {
                closeTimer.restart();
            }
        }
        onZiplogFinished: {
            if (meetingManager.getCurrentMeetingStatus() === 4) {
                feedbackWindow.hide();
            }
        }
    }
}
