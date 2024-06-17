const { ipcMain, app } = require('electron');
const os = require('os');
const network = require('network');
const si = require('systeminformation');
const isWin32 = process.platform === 'win32';

const timer = null;

function initMonitoring() {
  ipcMain.handle('getMonitoringInfo', async () => {
    const cpuUse = await si.currentLoad();
    const cpus = os.cpus();
    const cpu = {
      physicalCores: cpus.length,
      speed:
        cpus.reduce((acc, cpu) => acc + cpu.speed, 0) /
        cpus.length /
        (isWin32 ? 1000 : 10),
    };
    const memory = {
      total: os.totalmem(),
      used: os.totalmem() - os.freemem(),
    };
    const appMetrics = app.getAppMetrics();

    return new Promise((resolve) => {
      network.get_active_interface(function (err, obj) {
        let network = obj || { type: 'No network', desc: 'No network' };

        if (isWin32 && obj) {
          network = {
            type: obj.type,
            desc: obj.type === 'Wireless' ? 'Wi-Fi' : 'Ethernet',
          };
        }

        return resolve({
          cpu,
          cpuUse,
          memory,
          appMetrics,
          network: network,
        });
      });
    });
  });
}

module.exports = {
  initMonitoring,
};
