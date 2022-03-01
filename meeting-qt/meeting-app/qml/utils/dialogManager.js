function dynamicDialog(title, message, confirm, cancel, parent = mainWindow, confirmText = '', cancelText = '', showCancel = true) {
    const params = {
        text: title,
        description: message
    }
    if (confirmText !== '') {
        Object.assign(params, { confirmText: confirmText })
    }
    if (cancelText !== '') {
        Object.assign(params, { cancelText: cancelText })
    }
    if(showCancel == false) {
        Object.assign(params, { showCancel: showCancel })
    }
    const dialogHandle = Qt.createComponent("qrc:/qml/components/CustomDialog.qml").createObject(parent, params)
    dialogHandle.confirm.connect(confirm)
    dialogHandle.open()
}
