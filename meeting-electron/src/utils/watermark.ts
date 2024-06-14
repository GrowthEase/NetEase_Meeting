import React from 'react'

export type WatermarkParams = {
  container?: React.RefObject<HTMLElement> | HTMLElement | null
  type?: 1 | 2 // 1: 单条居中，2：全屏多条
  width?: number
  height?: number
  textAlign?: CanvasTextAlign
  textBaseline?: CanvasTextBaseline
  fontSize?: number
  fontOpacity?: number
  color?: string
  content?: string
  rotate?: number
  zIndex?: number
  offsetX?: number
  offsetY?: number
  bottom?: number
}

const drawWatermark = (params: WatermarkParams): void => {
  const {
    type = 2,
    textAlign = 'center' as CanvasTextAlign,
    textBaseline = 'middle' as CanvasTextBaseline,
    fontSize = type === 1 ? 30 : 12,
    fontOpacity = 0.16,
    color = '#C2C2C2',
    content = 'This is a watermark ',
    rotate = -15,
    zIndex = 999,
    offsetX = 150,
    offsetY = 100,
    bottom = 0,
  } = params

  let container = params.container

  if (container === undefined || container === null) {
    container = document.body
  }

  if (!(container instanceof HTMLElement)) {
    container = container.current
  }

  if (container === null) return

  const width = container.offsetWidth
  const height = container.offsetHeight

  const contentMaxWidth = type === 1 ? 344 : 192
  const lineHeight = type === 1 ? 32 : 18

  let __wm = container.querySelector('.__wm') as HTMLCanvasElement

  if (!__wm) {
    const canvas = document.createElement('canvas')

    canvas.setAttribute('width', width + 'px')
    canvas.setAttribute('height', height + 'px')
    __wm = canvas
    const styleStr = `
    position:absolute;
    top:0;
    left:0;
    bottom:${bottom}px;
    right:0;
    width:100%;
    height: calc(100% - ${bottom}px);
    z-index:${zIndex};
    pointer-events:none;
  `

    __wm.setAttribute('style', styleStr)
    __wm.classList.add('__wm')
    container.style.position = 'relative'
    container.appendChild(__wm)
  }

  const ctx = __wm.getContext('2d')

  if (!ctx) return
  ctx.textAlign = textAlign
  ctx.textBaseline = textBaseline
  ctx.font = `${fontSize}px PingFang SC`
  ctx.globalAlpha = fontOpacity
  ctx.fillStyle = color
  const contentWidth = ctx.measureText(content).width
  const validDrawWidth = Math.min(contentMaxWidth, contentWidth)
  const radians = (Math.PI / 180) * rotate // 角度转弧度

  if (type === 1) {
    ctx.save() // 保存当前状态
    ctx.translate(width / 2, height / 2)
    ctx.rotate(radians)
    drawWrapText({
      text: content,
      context: ctx,
      x: 0,
      y: 0,
      maxWidth: contentMaxWidth,
      lineHeight,
    })
    ctx.restore() // 恢复之前保存的状态
  } else {
    const adjustWidth = validDrawWidth * Math.cos(Math.abs(radians))
    const adjustHeight = validDrawWidth * Math.sin(Math.abs(radians))
    // 1. 根据canvas的宽高计算出最多可以绘制多少个水印，几行，几列
    const row = Math.ceil(height / (offsetY + lineHeight))
    const col = Math.ceil(width / (offsetX + validDrawWidth)) + 1

    // 2. 根据行列数，计算出每个水印的坐标并绘制
    for (let r = 0; r <= row; r++) {
      const coordY = r * (offsetY + adjustHeight) + offsetY

      for (let c = 0; c <= col; c++) {
        const coordX = c * (offsetX + adjustWidth) + offsetX

        ctx.save() // 保存当前状态
        ctx.translate(coordX, coordY)
        ctx.rotate(radians)
        drawWrapText({
          text: content,
          context: ctx,
          x: 0 - offsetX,
          y: 0,
          maxWidth: contentMaxWidth,
          lineHeight,
        })
        ctx.restore() // 恢复之前保存的状态
      }
    }
  }
}

function stopDrawWatermark(
  container: WatermarkParams['container'] = document.body
): void {
  if (container === undefined || container === null) return
  if (!(container instanceof HTMLElement)) {
    container = container.current
  }

  if (container === null) return

  const __wm = container.querySelector('canvas.__wm') as HTMLCanvasElement

  if (__wm) {
    __wm.parentNode?.removeChild(__wm)
    // __wm.getContext('2d')?.clearRect(0, 0, __wm.offsetWidth, __wm.offsetHeight)
  }
}

// 文字超长时换行绘制
const drawWrapText = function ({ text, context, x, y, maxWidth, lineHeight }) {
  if (typeof text != 'string' || typeof x != 'number' || typeof y != 'number') {
    return
  }

  const canvas = context.canvas

  if (typeof maxWidth == 'undefined') {
    maxWidth = (canvas && canvas.width) || 300
  }

  if (typeof lineHeight == 'undefined') {
    lineHeight =
      (canvas && parseInt(window.getComputedStyle(canvas).lineHeight)) ||
      parseInt(window.getComputedStyle(document.body).lineHeight)
  }

  // 字符分隔为数组
  const arrText = text.split('')
  let line = ''

  for (let n = 0; n < arrText.length; n++) {
    const testLine = line + arrText[n]
    const metrics = context.measureText(testLine)
    const testWidth = metrics.width

    if (testWidth > maxWidth && n > 0) {
      context.fillText(line, x, y)
      line = arrText[n]
      y += lineHeight
    } else {
      line = testLine
    }
  }

  context.fillText(line, x, y)
}

export { drawWatermark, stopDrawWatermark }
