function dynamicDialog(title, message, confirm, cancel = function () {}, parent = mainWindow, shadow = true) {
    const dialogHandle = Qt.createComponent("qrc:/qml/components/CustomDialog.qml").createObject(parent, {
        text: title,
        description: message,
        dim: shadow
    })
    dialogHandle.confirm.connect(confirm)
    dialogHandle.cancel.connect(cancel)
    dialogHandle.open()
}

function dynamicDialogEx(title, message, leave, end, cancel, parent = mainWindow) {
    const dialogHandle = Qt.createComponent("qrc:/qml/components/CustomDialogEx.qml").createObject(parent, {
        text: title,
        description: message
    })
    dialogHandle.leave.connect(leave)
    dialogHandle.end.connect(end)
    dialogHandle.open()
}
