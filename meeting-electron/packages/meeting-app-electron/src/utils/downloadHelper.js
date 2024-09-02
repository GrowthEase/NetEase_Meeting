const fs = require('fs')
const electronDl = require('electron-dl')
const download = electronDl.download

const { createHash } = require('crypto')
let isDownloading = false
let cancelled = false
let canceledBySelf = false
let downloadItem = null

function hashFile(file, algorithm = 'md5', encoding = 'hex', options) {
  return new Promise((resolve, reject) => {
    const hash = createHash(algorithm)

    hash.on('error', reject).setEncoding(encoding)

    fs.createReadStream(file, {
      ...options,
      highWaterMark:
        1024 * 1024 /* better to use more memory but hash faster */,
    })
      .on('error', reject)
      .on('end', () => {
        hash.end()
        resolve(hash.digest(encoding))
      })
      .pipe(hash, { end: false })
  })
}

function downloadUpdateFile({
  window,
  fileUrl,
  filePath,
  fileName,
  done,
  onprogress,
  md5,
  forceUpdate,
}) {
  console.log('tempPath>>>>>>>', fileUrl, filePath)
  if (isDownloading) {
    console.log('已有请求正在下载 忽略: ', fileUrl)
    return
  }

  canceledBySelf = false
  if (forceUpdate && isDownloading) {
    console.log('强制更新开始')
    downloadItem?.cancel?.()
  }

  isDownloading = true
  cancelled = false
  // if (!fs.existsSync(global.tempPath)) fs.mkdirSync(global.tempPath);
  download(window, fileUrl, {
    saveAs: false,
    directory: filePath,
    filename: fileName,
    overwrite: true,
    openFolderWhenDone: false,
    onStarted: (item) => {
      downloadItem = item
      item.on('updated', (event, state) => {
        if (state === 'interrupted') {
          // done?.(new Error('下载被中断'));
          item.cancel()
          cancelled = true
          isDownloading = false
        }
      })
      console.log('onStarted')
    },
    onCancel: (item) => {
      console.log('onCancel')
    },
    onCompleted: (item) => {
      console.log('onCompleted')
    },
    onProgress: (progress) => {
      const { percent } = progress

      console.log('progress', percent)
      onprogress?.(Math.round(percent * 100))
    },
  })
    .then(async (dl) => {
      console.log('下载成功', dl.getSavePath())
      isDownloading = false
      try {
        console.log('md4 file', dl.getSavePath())
        const updateFileMd5 = await hashFile(dl.getSavePath())

        console.log('md5', updateFileMd5)
        if (updateFileMd5 !== md5) {
          const error = new Error('文件md5校验失败，请重新下载')

          done?.(error)
        } else {
          done?.()
        }
      } catch (e) {
        console.log('Check md5 failed', e)
        done?.(e)
      }
    })
    .catch((err) => {
      console.log('cancelled', cancelled, err)
      // 表示强制下载时候取消上一次下载，不需要报错
      if ((forceUpdate && !cancelled) || canceledBySelf) {
        console.log('强制下载', canceledBySelf)
        return
      }

      isDownloading = false
      if (err instanceof electronDl.CancelError) {
        done?.(new Error('下载被中断'))
      } else {
        done?.(new Error(err))
      }
    })
    .finally(() => {
      cancelled = false
    })
}

function cancelUpdate() {
  canceledBySelf = true
  downloadItem?.cancel?.()
  isDownloading = false
}

module.exports = {
  downloadUpdateFile,
  cancelUpdate,
}
