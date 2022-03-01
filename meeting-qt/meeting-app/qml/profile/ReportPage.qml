import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.14
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12

import "../components"

Window{
    id: feedback
    title: qsTr("Suggestions")
    color: "#00000000"
    width: 400+10
    height: 377+10
    Material.theme: Material.Light
    flags: Qt.Window | Qt.FramelessWindowHint

    property var problemsArray: []

    Component.onCompleted: {
        restoreProblems()
    }

    MessageManager {
        id: idMessage
    }

    Timer{
        id:closeWindowTimer
        interval: 1500
        running: false
        repeat: false
        onTriggered: {
            comboProblems.clear()
            feedbackContent.clear()
            restoreProblems()
            feedback.close()
        }
    }

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        color: "#3217171A"
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        radius: Qt.platform.os === 'windows' ? 0 : 10
        DragArea {
            width: parent.width
            height: 52
            title: qsTr("Suggestions")
            onCloseClicked: Window.window.hide()
        }
        ColumnLayout{
            spacing: 0
            anchors.fill: parent
            anchors.margins: 30
            Label {
                id: textType
                text: qsTr("Question")
                color: "#333333"
                Layout.topMargin: 25
                font.pixelSize: 16
                font.weight: Font.Medium
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 80
            }
            TextField {
                id: comboProblems
                placeholderText: qsTr("Select question type")
                selectByMouse: true
                topInset: 0
                bottomInset: 0
                topPadding: 0
                bottomPadding: 0
                leftPadding: 15
                rightPadding: 35
                readOnly: true
                Layout.topMargin: 12
                background: Rectangle {
                    implicitWidth: 340
                    implicitHeight: 32
                    border.color: "#CCCCCC"
                    border.width: 1
                    radius: 2
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const menuPostion = comboProblems.mapToItem(mainLayout, 15, comboProblems.height + 10)
                        popupWindow.x = menuPostion.x
                        popupWindow.y = menuPostion.y
                        popupWindow.open()
                    }
                }
                Image {
                    width: 14
                    height: 14
                    anchors.right: comboProblems.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/qml/images/public/button/btn_down_white.svg"
                }
            }
            Label {
                id: description
                text: qsTr("Description")
                color: "#333333"
                font.pixelSize: 16
                font.weight: Font.Medium
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 20
                Layout.preferredWidth: 80
            }
            Rectangle {
                border.width: 1
                border.color: "#CCCCCC"
                radius: 2
                Layout.preferredWidth: 340
                Layout.preferredHeight: 90
                Layout.bottomMargin: 90
                Layout.topMargin: 12
                Flickable {
                    id: flickable
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.right: parent.right
                    anchors.rightMargin: 1
                    TextArea.flickable: TextArea {
                        id: feedbackContent
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        padding: 10
                        placeholderText: qsTr("Description of your problems")
                        background: null
                        onTextChanged: {
                            if (text.length >= 200) {
                                text = text.substring(0, 200)
                                cursorPosition = text.length
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar {
                        width: 5
                        onActiveChanged: {
                            if (active) {
                                feedbackContent.focus = false
                            }
                        }
                    }
                }

                Rectangle {
                    height: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.right: parent.right
                    anchors.rightMargin: 1
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                    z: 1
                }
            }


        }

    }
    CustomButton {
        id: btnSubmit
        width: 92
        height: 36
        highlighted: true
        text: qsTr("Submit")
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 30
        anchors.bottomMargin: 30
        enabled: comboProblems.text.length > 0
        onClicked: {
            btnSubmit.enabled = false
            feedbackManager.invokeFeedback(problemsArray, feedbackContent.text)
        }
    }
    Popup {
        id: popupWindow
        width: 340
        height: 260
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        focus: true
        padding: 15
        bottomMargin: 10
        background: Rectangle {
            radius: 2
            border.width: 1
            border.color: "#CCCCCC"
        }
        ListModel {
            id: listModel
        }
        ListView {
            id: listView
            width: parent.width
            height: parent.height - 50
            model: listModel
            delegate: ItemDelegate {
                width: 310
                height: 32
                enabled: model.selectable

                Label {
                    id: labelProblem
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: model.level === 1 ? 10 : 20
                    text: model.text
                    color: "#333333"
                    states: [
                        State {
                            name: "clicked"
                            PropertyChanges { target: labelProblem; color: "#337EFF" }
                            PropertyChanges { target: selectedIcon; visible: true }
                        }
                    ]
                }
                Image {
                    id: selectedIcon
                    width: 12
                    height: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 13
                    source: "qrc:/qml/images/public/icons/right.svg"
                    visible: false
                }
                Image {
                    id: downIcon
                    width: 12
                    height: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 13
                    source: "qrc:/qml/images/public/button/btn_down_white.svg"
                    visible: !model.selectable
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (labelProblem.state === "") {
                            let hasProblem = false
                            for (let i = 0; i < problemsArray.length; i++) {
                                if (problemsArray[i] === labelProblem.text) {
                                    hasProblem = true
                                    break
                                }
                            }
                            if (!hasProblem) problemsArray.push(labelProblem.text)
                        } else {
                            for (let j = 0; j < problemsArray.length; j++) {
                                if (problemsArray[j] === labelProblem.text) {
                                    problemsArray.splice(j, 1)
                                    break
                                }
                            }
                        }
                        labelProblem.state === 'clicked' ? labelProblem.state = "" : labelProblem.state = 'clicked';
                    }
                }
            }
            ScrollBar.vertical: ScrollBar {
                width: 5
            }
        }
        CustomToolSeparator {
            id: separator
            width: parent.width
            anchors.top: listView.bottom
            anchors.topMargin: 20
        }
        CustomButton {
            id: buttonOK
            anchors.top: separator.bottom
            anchors.topMargin: 6
            anchors.right: buttonCancel.left
            anchors.rightMargin: 5
            width: 80
            height: 32
            highlighted: true
            text: qsTr("OK")
            buttonRadius: 16
            onClicked: {
                let problems = ''
                for (let i = 0; i < problemsArray.length; i++) {
                    problems += problemsArray[i]
                    if (i !== problemsArray.length - 1) {
                        problems += ","
                    }
                }
                comboProblems.text = problems
                popupWindow.close()
            }
        }
        CustomButton {
            id: buttonCancel
            anchors.top: separator.bottom
            anchors.topMargin: 6
            anchors.rightMargin: 30
            anchors.bottomMargin: 30
            anchors.right: parent.right
            borderColor: "#E1E3E6"
            normalBkColor: "#FFFFFF"
            normalTextColor: "#666666"
            width: 92
            height: 36
            text: qsTr("Cancel")
            buttonRadius: 16
            onClicked: {
                popupWindow.close()
            }
        }
    }

    Connections {
        target: feedbackManager
        onFeedbackResult: {
            btnSubmit.enabled = Qt.binding(function () {
                return comboProblems.text.length > 0
            })

            if (code === 200) {
                idMessage.info(qsTr("We have received your feedback and thank you for your support."))
                closeWindowTimer.restart()

            } else {
                console.error("Failed to report user suggestion, error = ", code, ", message = ", result)
                idMessage.error(qsTr("Looks like something went wrong, please try again."))
            }

        }
    }

    function restoreProblems() {
        listModel.clear()
        listModel.append({ selectable: false, level: 1, text: qsTr("Sound problems") })
        listModel.append({ selectable: true, level: 2, text: qsTr("Noise") })
        listModel.append({ selectable: true, level: 2, text: qsTr("Delay") })
        listModel.append({ selectable: true, level: 2, text: qsTr("Intermittent") })
        listModel.append({ selectable: false, level: 1, text: qsTr("Video problems") })
        listModel.append({ selectable: true, level: 2, text: qsTr("Blurry") })
        listModel.append({ selectable: true, level: 2, text: qsTr("Stuck") })
        listModel.append({ selectable: true, level: 2, text: qsTr("Not synchronized") })
        listModel.append({ selectable: true, level: 1, text: qsTr("Interactive experience") })
        listModel.append({ selectable: true, level: 1, text: qsTr("Other") })
    }
}

