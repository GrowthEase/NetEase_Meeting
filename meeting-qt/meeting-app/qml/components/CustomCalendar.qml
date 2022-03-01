import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

CustomTextFieldEx {
    id: idRoot
    property var aliasName: 'customCalendar'    // 起个名称
    property var currentDate: undefined         // 当前日期
    property var minimumDate: undefined         // 可选最小日期
    property var maximumDate: undefined         // 可选最大日期
    property bool manualInput: true             // 是否可以手动输入日期
    property bool noEdit: false                 // 是否可以编辑日期
    property var popupParent: undefined         // 父窗口

    visibleCalendar: true
    readOnly: !manualInput || noEdit
    selectByMouse: manualInput

    // 隐藏日历窗口
    function hideCalendar() {
        if (idCalendarPopup.visible) {
            idCalendarPopup.close()
        }
    }

    onCurrentDateChanged: {
        const dateTmp = new Date(currentDate)
        text = dateTmp.toLocaleDateString(Qt.locale(), "yyyy-MM-dd")
    }

    CustomCalendarPopup {
        id: idCalendarPopup
    }

    onPressed: {
        if (noEdit) { return }

        if (minimumDate !== undefined)
            idCalendarPopup.calendar.minimumDate = minimumDate

        if (maximumDate !== undefined)
            idCalendarPopup.calendar.maximumDate = maximumDate

        currentDate = Date.fromLocaleDateString(Qt.locale(), text, "yyyy-MM-dd")
        idCalendarPopup.calendar.visibleYear = currentDate.getFullYear()
        idCalendarPopup.calendar.visibleMonth = currentDate.getMonth()
        idCalendarPopup.calendar.selectedDate = currentDate

        idCalendarPopup.x = idRoot.x
        idCalendarPopup.y = idRoot.y + idRoot.height + 5
        idCalendarPopup.open()
        //console.log("idCalendarPopup:", idCalendarPopup.x, idCalendarPopup.y)
    }

    Component.onCompleted: {
        idCalendarPopup.calendar.clicked.connect( function() {
            currentDate = idCalendarPopup.calendar.selectedDate
            idCalendarPopup.close()
        })
    }

    Accessible.role: Accessible.Button
    Accessible.name: aliasName
    Accessible.onPressAction: if (enabled) pressed(Qt.LeftButton)
}


