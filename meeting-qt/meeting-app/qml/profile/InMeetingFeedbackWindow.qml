import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import NetEase.Meeting.MembersModel 1.0

import '../components'

Window {
    id: feedbackWindow

    property bool showOptions: true
    property bool feedbacking: false
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
                                      qsTr("Audio and video are out of sync")]
    property var problemsArray: []
    property int problemsCount: 0
    property bool submiting: false

    width: Qt.platform.os === 'windows' ? mainContainer.width + 20 : mainContainer.width
    height: Qt.platform.os === 'windows' ? mainContainer.height + 20 : mainContainer.height
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    Material.theme: Material.Light

    onVisibleChanged: {
        if(visible) {
            idScrollBar.setPosition(0)
            meetingManager.getMeetingUserList()
        } else {
            problemsArray = []
            submiting = false
            textArea.clear()
            selectComboBox.text = qsTr("none")
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
        }
    }

    Connections {
        target: meetingManager
        onGetMeetingUserListSignal: {
            membersModel.initData(userList);
        }
    }

    MembersModel {
        id: membersModel
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

    Rectangle {
        id: mainContainer
        width: 400
        height: submiting ? 112 : 600
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: Qt.platform.os === 'windows' ? 10 : 0
        anchors.topMargin: Qt.platform.os === 'windows' ? 10 : 0
        radius: Qt.platform.os === 'windows' ? 0 : 10

        onHeightChanged: {
            Qt.callLater(function () {
                feedbackWindow.x = (Screen.width - mainContainer.width) / 2 + Screen.virtualX
                feedbackWindow.y = (Screen.height - mainContainer.height) / 2 + Screen.virtualY
                feedbackWindow.width = Qt.platform.os === 'windows' ? mainContainer.width + 20 : mainContainer.width
                feedbackWindow.height = Qt.platform.os === 'windows' ? mainContainer.height + 20 : mainContainer.height
            })
        }

        ColumnLayout {
            id: feedbackLayout
            anchors.fill: parent
            spacing: 0
            DragArea {
                id: feedbackTitle
                title: qsTr('Feedback')
                Layout.preferredHeight: 52
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredHeight: 60
                Layout.fillWidth: true
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                visible: submiting
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

            Flickable {
                id: idScrollView
                clip: true
                visible: !submiting
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: 400
                contentHeight: col.height
                ScrollBar.vertical: ScrollBar {
                    id: idScrollBar
                    parent: idScrollView
                    width: 6
                    policy: ScrollBar.AlwaysOn

                    onPositionChanged: {
                        if(selectComboBox.active && position < 0.2) {
                            selectComboBox.hidePopup()
                        }
                    }
                }

                ColumnLayout {
                    id: col
                    spacing: 25
                    anchors.top: parent.top
                    anchors.topMargin: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 20

                    Item {
                        id: audioTag
                        height: audioTagLayout.height
                        ColumnLayout {
                            id: audioTagLayout
                            spacing: 20
                            Label {
                                text: qsTr("audio problems")
                                font.pixelSize: 20
                            }

                            ColumnLayout {
                                spacing: 14
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
                            spacing: 20
                            Label {
                                text: qsTr("video problems")
                                font.pixelSize: 20
                            }

                            ColumnLayout {
                                spacing: 14
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
                            spacing: 20
                            Label {
                                text: qsTr("Problem Description")
                                font.pixelSize: 20
                            }

                            Flickable {
                                Layout.preferredWidth: 360
                                Layout.preferredHeight: 80
                                TextArea.flickable: TextArea {
                                    id: textArea
                                    padding: 12
                                    selectByMouse: true
                                    selectByKeyboard: true
                                    wrapMode: Text.WrapAnywhere
                                    placeholderText: qsTr('Other problems')
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

                    Item {
                        id: remoteUsers
                        height: remoteUsersLayout.height
                        ColumnLayout {
                            id: remoteUsersLayout
                            spacing: 20
                            Label {
                                text: qsTr("Problem user")
                                font.pixelSize: 20
                            }

                            CustomSelectComboBox {
                                id: selectComboBox
                                Layout.preferredWidth: 360
                                Layout.preferredHeight: 40
                                listModel: membersModel
                                text: qsTr("none")

                                onSigPressed: {
                                    if(idScrollBar.position < 0.4) {
                                        Qt.callLater(function () {
                                            idScrollBar.setPosition(1.0)
                                        })
                                    }
                                }

                                onSigChecked: {
                                    console.log("CustomSelectComboBox check", checked)
                                    console.log("CustomSelectComboBox index", index)
                                    membersModel.setChecked(checked, index)
                                }

                                onSigConfirm: {
                                    var userList = membersModel.getCheckedUserList()
                                    console.log("userList------", userList)

                                    if(userList.length === 0) {
                                        selectComboBox.text = qsTr("none")
                                        return
                                    }

                                    var comboBoxText = ""
                                    for(let i = 0; i < userList.length; i++) {
                                        comboBoxText = comboBoxText + userList[i] + ";"
                                    }

                                    comboBoxText = comboBoxText.substring(0, comboBoxText.lastIndexOf(';')) //去掉最后一个分号
                                    selectComboBox.text = comboBoxText
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: 20
                    }

                    Item {
                        id: item
                        Layout.preferredHeight: selectComboBox.visibleComboBoxOpen ? selectComboBox.popupHeight : 0
                    }
                }

            }
            Rectangle {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                color: '#EBEDF0'
                visible: !submiting
            }
            CustomButton {
                buttonRadius: 18
                highlighted: true
                visible: !submiting
                enabled: (problemsCount !== 0 || textArea.text.length !== 0)
                Layout.topMargin: 11
                Layout.bottomMargin: 11
                Layout.preferredHeight: 36
                Layout.preferredWidth: 120
                Layout.alignment: Qt.AlignHCenter
                text: qsTr('Submit')
                onClicked: {
                    closeTimer.restart()
                    submiting = true

                    let audioDump = false
                    for (let j = 0; j < problemsArray.length; j++) {
                        var index = problemsTotalArray.indexOf(problemsArray[j])
                        if(index > -1 && index < 8) {
                            audioDump = true
                            break;
                        }
                    }

                    if(selectComboBox.text !== qsTr(("none"))) {
                        var userText = qsTr("problem users") + ":" + selectComboBox.text
                        problemsArray.push(userText)
                    }

                    console.log("need audioDump,", audioDump)
                    feedbackManager.invokeFeedback(problemsArray, textArea.text, audioDump)
                }
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

    function showInMeetingFeedbackWindow() {
        feedbackWindow.show()
        feedbackWindow.x = (Screen.width - feedbackWindow.width) / 2 + Screen.virtualX
        feedbackWindow.y = (Screen.height - feedbackWindow.height) / 2 + Screen.virtualY
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
}
