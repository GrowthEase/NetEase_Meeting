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

async function saveAnnotation(opts: SaveAnnotationOptions) {
  const { screenData, wbData } = opts
  const screenDataImage = await getImage(screenData)
  const canvas = document.createElement('canvas')

  canvas.width = screenDataImage.width
  canvas.height = screenDataImage.height
  const ctx = canvas.getContext('2d')

  if (ctx) {
    ctx.drawImage(screenDataImage, 0, 0)
    const wbDataImage = await getImage(wbData)

    ctx.drawImage(
      wbDataImage,
      0,
      0,
      screenDataImage.width,
      screenDataImage.height
    )
    const aDownloadLink = document.createElement('a')

    aDownloadLink.download = `annotation-${Date.now()}.png`
    aDownloadLink.href = canvas.toDataURL()
    aDownloadLink.click()
  }
}

export default saveAnnotation
