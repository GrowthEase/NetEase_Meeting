const { spawnSync, spawn } = require("child_process")

function wrapSudo() {
  const installComment = `"would like to update"`
  const sudo = spawnSyncLog("which gksudo || which kdesudo || which pkexec || which beesu")
  const command = [sudo]
  if (/kdesudo/i.test(sudo)) {
    command.push("--comment", installComment)
    command.push("-c")
  } else if (/gksudo/i.test(sudo)) {
    command.push("--message", installComment)
  } else if (/pkexec/i.test(sudo)) {
    command.push("--disable-internal-agent")
  }
  return command.join(" ")
}

function spawnSyncLog(cmd, args, env = {}) {
  console.log(`Executing: ${cmd} with args: ${args}`)
  const response = spawnSync(cmd, args, {
    env: { ...process.env, ...env },
    encoding: "utf-8",
    shell: true,
  })
  console.log('spawnSyncLog response', response)
  return response.stdout.trim()
}

async function spawnLog(cmd, args) {
  return new Promise((resolve, reject) => {
    try {
      const params = { detached: true }
      const p = spawn(cmd, args, params)

      p.on('error', (error) => {
        reject(error)
      })
      p.unref()
      if (p.pid !== undefined) {
        console.log('resolve', resolve)
        resolve(true)
      }
    } catch (error) {
      reject(error)
    }
  })
}

module.exports = {
  wrapSudo,
  spawnSyncLog,
  spawnLog,
}