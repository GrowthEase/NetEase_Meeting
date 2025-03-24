const { Menu } = require('electron')

let contextMenu

function showElectronPopover(items, window) {
  updateElectronPopover(items, window)
  if (items) {
    contextMenu?.popup()
  }
}

function hideElectronPopover() {
  contextMenu?.closePopup()
}

function updateElectronPopover(items, window) {
  if (items) {
    const template = items.map((item) => {
      return {
        label: item.label,
        type: item.type === 'divider' ? 'separator' : 'normal',
        id: item.key,
        click: () => {
          window.webContents.send('popoverItemClick', item)
        },
      }
    })

    contextMenu = Menu.buildFromTemplate(template)
  }
}

module.exports = {
  showElectronPopover,
  hideElectronPopover,
  updateElectronPopover,
}
