import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4 as QC14
import QtQuick.Controls.Styles 1.4 as QCS14
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.12

Popup {
    id: root
    width: 260   // 300
    height: 260  // 340
    padding: 0
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    dim: false
    focus: true
    background: Rectangle {
        id: backgroundRect
        radius: Qt.platform.os === 'windows' ? 0 : 2
        border.width: 1
        border.color: "#EBEDF0"
        layer.enabled: true
        layer.effect: DropShadow {
            width: backgroundRect.width
            height: backgroundRect.height
            x: backgroundRect.x
            y: backgroundRect.y
            visible: backgroundRect.visible
            source: backgroundRect
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: "#1917171a"
        }
    }

    property alias calendar: idCalendar

    onClosed: {
        // When created dynamically, is called when the dialog is closed only but the parent object is not destroyed
        //root.destroy()
    }

    QtObject {
        id: idProperty
        property var week: [qsTr("Sun"), qsTr("Mon"), qsTr("Tue"), qsTr("Wed"), qsTr("Thu"), qsTr("Fri"), qsTr("Sat")]
    }

    QC14.Calendar {
        id : idCalendar
        anchors.horizontalCenter: parent.horizontalCenter
        //anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
        width: 245
        height: 245
        frameVisible: false
        dayOfWeekFormat: Locale.ShortFormat

        style: QCS14.CalendarStyle {
            id: idStyle
            gridVisible: false

            background: Rectangle{
                anchors.fill: parent
                color: "#FFFFFF"
            }

            dayDelegate: Rectangle {
                id: idDayDelegate
                Rectangle {
                    anchors.centerIn: parent
                    width: 22
                    height: width
                    radius: width / 2
                    color: "#337EFF"
                    visible: styleData.selected
                }

                Rectangle {
                    id: idValid
                    anchors.centerIn: parent
                    width: 35
                    height: 32
                    color: "#F2F3F5"
                    visible: !styleData.valid
                }

                Label {
                    id: idLabel
                    text: styleData.date.getDate()
                    anchors.centerIn: parent
                    font.pixelSize: 12
                    color: styleData.selected ? "#FFFFFF" :  (styleData.visibleMonth && styleData.valid ? (styleData.hovered ? "#337EFF" : "#222222") : "#CCCCCC")
                }
            }

            dayOfWeekDelegate: Rectangle {
                anchors.centerIn: parent
                width: 37
                height: 37
                color: "transparent"
                Label {
                    id: weekTxt
                    anchors.fill: parent
                    text: Qt.locale().uiLanguages[0] === "zh-CN" ? idProperty.week[styleData.dayOfWeek] : Qt.locale().dayName(styleData.dayOfWeek, control.dayOfWeekFormat)
                    color: "#222222"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            navigationBar: Rectangle {
                color: "transparent"
                height: 40
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    anchors.topMargin: 10
                    Image {
                        source: "qrc:/qml/images/public/calendar/left2.svg"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: width
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 5
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                               control.visibleYear = control.visibleYear - 1;
                            }
                        }
                    }

                    Image {
                        source: "qrc:/qml/images/public/calendar/left.svg"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: width
                        Layout.alignment: Qt.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                control.showPreviousMonth()
                            }
                        }
                    }

                    Label {
                        id: dateText
                        text: styleData.title
                        font.pixelSize: 14
                        Layout.preferredWidth: 85
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    }

                    Image {
                        source: "qrc:/qml/images/public/calendar/right.svg"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: width
                        Layout.alignment: Qt.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                control.showNextMonth()
                            }
                        }
                    }

                    Image {
                        source: "qrc:/qml/images/public/calendar/right2.svg"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: width
                        Layout.alignment: Qt.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                control.showNextYear()
                            }
                        }
                    }
                }
            }
        }
    }
}

