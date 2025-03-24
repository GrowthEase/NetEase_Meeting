"use strict";
var Menu = require('electron').Menu;
var contextMenu;
function showElectronPopover(items, window) {
    updateElectronPopover(items, window);
    if (items) {
        contextMenu === null || contextMenu === void 0 ? void 0 : contextMenu.popup();
    }
}
function hideElectronPopover() {
    contextMenu === null || contextMenu === void 0 ? void 0 : contextMenu.closePopup();
}
function updateElectronPopover(items, window) {
    if (items) {
        var template = items.map(function (item) {
            return {
                label: item.label,
                type: item.type === 'divider' ? 'separator' : 'normal',
                id: item.key,
                click: function () {
                    window.webContents.send('popoverItemClick', item);
                },
            };
        });
        contextMenu = Menu.buildFromTemplate(template);
    }
}
module.exports = {
    showElectronPopover: showElectronPopover,
    hideElectronPopover: hideElectronPopover,
    updateElectronPopover: updateElectronPopover,
};