type SaveAnnotationOptions = {
  screenData: string
  wbData: string
}

function getImage(url: string): Promise<HTMLImageElement> {
  const image = new Image()

  if (/^http/.test(url)) {
    image.setAttribute('crossOrigin', 'anonymous')
  }

  image.src = url
  return new Promise<HTMLImageElement>((resolve) => {
    image.onload = function () {
      return resolve(image)
    }
  })
}

async function getAnnotationBase64String(opts: SaveAnnotationOptions) {
  const { screenData, wbData } = opts
  const screenDataImage = screenData ? await getImage(screenData) : null
  const wbDataImage = await getImage(wbData)

  const canvas = document.createElement('canvas')

  canvas.width = screenDataImage?.width || wbDataImage.width
  canvas.height = screenDataImage?.height || wbDataImage.height
  const ctx = canvas.getContext('2d')

  if (ctx) {
    screenDataImage ? ctx.drawImage(screenDataImage, 0, 0) : null
    const wbDataImage = await getImage(wbData)

    ctx.drawImage(
      wbDataImage,
      0,
      0,
      canvas.width,
      canvas.height
    )
    return canvas.toDataURL()
  }
}
async function saveAnnotation(opts: SaveAnnotationOptions) {
  const url = await getAnnotationBase64String(opts)
  if (!url) {
    return
  }
  const aDownloadLink = document.createElement('a')

  aDownloadLink.download = `annotation-${Date.now()}.png`
  aDownloadLink.href = url
  aDownloadLink.click()
}
export {getAnnotationBase64String}
export default saveAnnotation
