import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

Popup {
    id: root
    width: 260 // 300
    height: 300 // 340
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
        // root.destroy()
    }

    QtObject {
        id: idProperty
        property var week: [qsTr("Sun"), qsTr("Mon"), qsTr("Tue"), qsTr(
                "Wed"), qsTr("Thu"), qsTr("Fri"), qsTr("Sat")]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        Rectangle {
            color: "transparent"
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            RowLayout {
                anchors.fill: parent
                spacing: 0
                anchors.topMargin: 10
                Image {
                    source: "qrc:/qml/images/public/calendar/left2.svg"
                    mipmap: true
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 5
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            let current = new Date(idCalendar.year, idCalendar.month - 1)
                            current.setFullYear(current.getFullYear() - 1)
                            idCalendar.year = current.getFullYear()
                            idCalendar.month = current.getMonth()
                        }
                    }
                }
                Image {
                    source: "qrc:/qml/images/public/calendar/left.svg"
                    mipmap: true
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            let current = new Date(idCalendar.year, idCalendar.month - 1)
                            current.setMonth(current.getMonth() - 1)
                            idCalendar.year = current.getFullYear()
                            idCalendar.month = current.getMonth() + 1
                        }
                    }
                }
                Label {
                    id: dateText
                    text: idCalendar.title
                    font.pixelSize: 14
                    Layout.preferredWidth: 85
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                }
                Image {
                    source: "qrc:/qml/images/public/calendar/right.svg"
                    mipmap: true
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            let current = new Date(idCalendar.year, idCalendar.month - 1)
                            current.setMonth(current.getMonth() + 1)
                            idCalendar.year = current.getFullYear()
                            idCalendar.month = current.getMonth() + 1
                        }
                    }
                }
                Image {
                    source: "qrc:/qml/images/public/calendar/right2.svg"
                    mipmap: true
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            let current = new Date(idCalendar.year, idCalendar.month - 1)
                            current.setFullYear(current.getFullYear() + 1)
                            idCalendar.year = current.getFullYear()
                            idCalendar.month = current.getMonth()
                        }
                    }
                }
            }
        }
        DayOfWeekRow {
            locale: idCalendar.locale
            Layout.fillWidth: true
        }
        MonthGrid {
            id: idCalendar
            property var selectedDate: new Date().setHours(0,0,0,0)
            property var currentDate: new Date().setHours(0,0,0,0)
            property var minimumDate
            property var maximumDate
            month: new Date().getMonth()
            year: new Date().getFullYear()
            locale: Qt.locale("zh_CN")
            Layout.fillWidth: true
            delegate: Rectangle {
                width: 35
                height: 28
                Rectangle {
                    anchors.centerIn: parent
                    width: 22
                    height: width
                    radius: width / 2
                    color: "#337EFF"
                    visible: model.date.valueOf() == idCalendar.selectedDate.valueOf()
                }
                Rectangle {
                    id: disableBackground
                    anchors.fill: parent
                    color: "#F2F3F5"
                    visible: model.date.valueOf() < idCalendar.currentDate.valueOf()
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log('block click')
                        }
                    }
                }
                Label {
                    text: model.day
                    anchors.centerIn: parent
                    font.pixelSize: 12
                    color: model.date.valueOf() == idCalendar.selectedDate.valueOf()
                        ? "#FFFFFF"
                        : (model.date.valueOf() > idCalendar.currentDate.valueOf()
                            ? "#222222"
                            : "#CCCCCC")
                }
                Component.onCompleted: {
                    console.log(`calendar date: ${model.year} - ${model.month} - ${model.day} - ${idCalendar.selectedDate}`)
                }
            }
            // https://doc.qt.io/qt-6/qml-qtquick-controls2-monthgrid.html#clicked-signal
            onClicked: {
                selectedDate = date
                console.log(date)
            }
        }
    }
}
