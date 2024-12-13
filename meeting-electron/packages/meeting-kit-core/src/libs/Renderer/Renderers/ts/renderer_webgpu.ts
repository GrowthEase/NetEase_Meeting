import { VideoFrame } from '../../IRenderer'

interface IFormat {
  textureWidth: number
  textureHeight: number
  viewWidth: number
  cropWidth: number
  xOffsetRate: number
}

interface ITextures {
  y: GPUTexture
  u: GPUTexture
  v: GPUTexture
}

interface IOption {
  background?: number[]
}

interface IState {
  background: number[]
  canvas?: HTMLCanvasElement
  lastFormat?: IFormat
  device?: GPUDevice
  textureFormat?: GPUTextureFormat
  renderBundle?: GPURenderBundle
  ctx?: GPUCanvasContext
  textures?: ITextures
  vertexBuf?: GPUBuffer
}

const code = `
  struct OurVertexShaderOutput {
    @builtin(position) position: vec4f,
    @location(0) texcoord: vec2f,
  };
  
  @vertex fn vs(
    @builtin(vertex_index) vertexIndex : u32,
    @location(0) xOffset: f32
  ) -> OurVertexShaderOutput {
    var pos = array<vec2<f32>, 6>(
      vec2<f32>( 1.0,  1.0),
      vec2<f32>(-1.0, -1.0),
      vec2<f32>(-1.0,  1.0),
      vec2<f32>( 1.0,  1.0),
      vec2<f32>( 1.0, -1.0),
      vec2<f32>(-1.0, -1.0),
    );
  
    var uv = array<vec2<f32>, 6>(
      vec2<f32>(1.0, 0.0),
      vec2<f32>(0.0, 1.0),
      vec2<f32>(0.0, 0.0),
      vec2<f32>(1.0, 0.0),
      vec2<f32>(1.0, 1.0),
      vec2<f32>(0.0, 1.0),
    );
  
    var vsOutput: OurVertexShaderOutput;
    let xy = pos[vertexIndex];
    vsOutput.position = vec4f(xy, 0.0, 1.0);
    vsOutput.texcoord = vec2f(uv[vertexIndex].x - xOffset, uv[vertexIndex].y);
    return vsOutput;
  }
  
  @group(0) @binding(0) var ourSampler: sampler;
  @group(0) @binding(1) var ourTextureY: texture_2d<f32>;
  @group(0) @binding(2) var ourTextureU: texture_2d<f32>;
  @group(0) @binding(3) var ourTextureV: texture_2d<f32>;
  
  @fragment fn fs(fsInput: OurVertexShaderOutput) -> @location(0) vec4f {
    let x = fsInput.texcoord.x;
    // let uv = vec2f(x, fsInput.texcoord.y);
  
    let Y = select(0.0, textureSample(ourTextureY, ourSampler, fsInput.texcoord).x, x > 0.0);
    let U = select(0.0, textureSample(ourTextureU, ourSampler, fsInput.texcoord).x, x > 0.0);
    let V = select(0.0, textureSample(ourTextureV, ourSampler, fsInput.texcoord).x, x > 0.0);
  
    let fYmul = Y * 1.1643828125;
    let r = fYmul + 1.59602734375 * V - 0.870787598;
    let g = fYmul - 0.39176171875 * U - 0.81296875 * V + 0.52959375;
    let b = fYmul + 2.01723046875 * U - 1.081389160375;
  
    return vec4f(r, g, b, 0.0);
  }
  `

export interface IVideoFrame {
  stride_y: number
  stride_u: number
  stride_v: number
  width: number
  height: number
  buf_y: Uint8Array
  buf_u: Uint8Array
  buf_v: Uint8Array
  renderTime: number
  decodeTime?: number
}

const default_background_color = [61 / 255, 61 / 255, 61 / 255, 1]

/**
 * todo:
 * 考虑直接在 初始化画布的时候就将高度处理好
 * 需要处理 canvas 的百分比
 *
 *  */
export default class WebGPURender {
  public isInit: boolean = false
  private state: IState = {
    background: default_background_color,
  }
  static isSupport() {
    return !!navigator.gpu
  }
  constructor(canvas: HTMLCanvasElement, private option: IOption) {
    this.state.canvas = canvas
  }

  async init() {
    const adapter = await navigator.gpu?.requestAdapter()
    const device = await adapter?.requestDevice()
    const ctx = this.state.canvas?.getContext('webgpu')
    const format = navigator.gpu?.getPreferredCanvasFormat()

    if (!device || !adapter || !ctx || !format) {
      throw new Error('webgpu render init error')
    }

    this.state.device = device
    this.state.textureFormat = format
    this.state.ctx = ctx
    ctx.configure({
      device,
      format,
    })
    this.isInit = true
  }

  // 只考虑 yuv420
  async drawFrame(videoFrame: VideoFrame) {
    const frame = {
      buf_y: videoFrame.yBuffer,
      buf_u: videoFrame.uBuffer,
      buf_v: videoFrame.vBuffer,
      stride_y: videoFrame.yStride,
      stride_u: videoFrame.uStride,
      stride_v: videoFrame.vStride,
      width: videoFrame.width,
      height: videoFrame.height,
      renderTime: 0,
    }

    if (this.state.canvas) {
      this.state.canvas.width = frame.stride_y
      this.state.canvas.height = frame.height
    }

    let { lastFormat, renderBundle, textures, vertexBuf } = this.state

    const { device, ctx } = this.state

    if (!ctx || !device) {
      throw new Error('device or ctx undefined, need call init first')
    }

    let needUpdate = false

    // 判断是否需要重置source
    if (
      lastFormat?.textureWidth !== frame.stride_y ||
      lastFormat?.textureHeight !== frame.height ||
      lastFormat?.viewWidth !== frame.width
    ) {
      lastFormat = this.format(frame)
      this.state.lastFormat = lastFormat
      needUpdate = true
    }

    if (!renderBundle || needUpdate) {
      ;[renderBundle, textures, vertexBuf] =
        this.createTexturesAndRenderBundle(lastFormat)
      this.state.renderBundle = renderBundle
      this.state.vertexBuf = vertexBuf
      this.state.textures = textures
    }

    if (!textures) {
      throw new Error('create texture error')
    }

    this.writeTextures(frame, device, lastFormat, textures)

    const commander = device.createCommandEncoder()
    const pass = commander.beginRenderPass({
      colorAttachments: [
        {
          view: ctx.getCurrentTexture().createView(),
          clearValue: this.state.background,
          loadOp: 'clear',
          storeOp: 'store',
        },
      ],
    })

    pass.setScissorRect(
      lastFormat.cropWidth,
      0,
      lastFormat.viewWidth,
      lastFormat.textureHeight
    )
    pass.executeBundles([renderBundle])
    pass.end()

    device.queue.submit([commander.finish()])
  }

  public clear() {
    const { device, ctx } = this.state

    if (device && ctx) {
      const commander = device.createCommandEncoder()

      commander.beginRenderPass({
        colorAttachments: [
          {
            view: ctx.getCurrentTexture().createView(),
            clearValue: this.state.background,
            loadOp: 'clear',
            storeOp: 'store',
          },
        ],
      })
    }
  }

  destroy() {
    // 清理 纹理
    if (this.state.textures) {
      this.state.textures.y.destroy()
      this.state.textures.u.destroy()
      this.state.textures.v.destroy()
      this.state.textures = undefined
    }

    // 清理顶点缓冲区
    if (this.state.vertexBuf) {
      this.state.vertexBuf.destroy()
      this.state.vertexBuf = undefined
    }

    if (this.state.ctx) {
      this.state.ctx.unconfigure()
      this.state.ctx = undefined
    }

    if (this.state.device) {
      this.state.device.destroy()
      this.state.device = undefined
    }

    this.state = {
      background: default_background_color,
    }

    this.isInit = false
  }

  // 帧 data 宽度和 frame 宽度不一致，所以需要处理
  private format(frame: IVideoFrame) {
    return {
      textureWidth: frame.stride_y,
      textureHeight: frame.height,
      viewWidth: frame.width,
      cropWidth: (frame.stride_y - frame.width) / 2,
      xOffsetRate: (frame.stride_y - frame.width) / 2 / frame.stride_y,
    }
  }

  private writeTextures(
    frame: IVideoFrame,
    device: GPUDevice,
    format: IFormat,
    textures: ITextures
  ) {
    device.queue.writeTexture(
      { texture: textures.y },
      frame.buf_y,
      { bytesPerRow: format.textureWidth },
      { width: format.textureWidth, height: format.textureHeight }
    )

    device.queue.writeTexture(
      { texture: textures.u },
      frame.buf_u,
      { bytesPerRow: format.textureWidth / 2 },
      { width: format.textureWidth / 2, height: format.textureHeight / 2 }
    )

    device.queue.writeTexture(
      { texture: textures.v },
      frame.buf_v,
      { bytesPerRow: format.textureWidth / 2 },
      { width: format.textureWidth / 2, height: format.textureHeight / 2 }
    )
  }

  private createTexturesAndRenderBundle(
    format: IFormat
  ): [GPURenderBundle, ITextures, GPUBuffer] {
    const { device, textureFormat } = this.state

    if (!device || !textureFormat) {
      throw new Error('device or textureFormat undefined, need call init first')
    }

    const textures = {
      y: device.createTexture({
        format: 'r8unorm',
        size: [format.textureWidth, format.textureHeight],
        usage:
          GPUTextureUsage.COPY_DST |
          GPUTextureUsage.RENDER_ATTACHMENT |
          GPUTextureUsage.TEXTURE_BINDING,
      }),
      u: device.createTexture({
        format: 'r8unorm',
        size: [format.textureWidth / 2, format.textureHeight / 2],
        usage:
          GPUTextureUsage.COPY_DST |
          GPUTextureUsage.RENDER_ATTACHMENT |
          GPUTextureUsage.TEXTURE_BINDING,
      }),
      v: device.createTexture({
        format: 'r8unorm',
        size: [format.textureWidth / 2, format.textureHeight / 2],
        usage:
          GPUTextureUsage.COPY_DST |
          GPUTextureUsage.RENDER_ATTACHMENT |
          GPUTextureUsage.TEXTURE_BINDING,
      }),
    }
    const vertexXOffset = new Float32Array([
      format.xOffsetRate,
      format.xOffsetRate,
      format.xOffsetRate,
      format.xOffsetRate,
      format.xOffsetRate,
      format.xOffsetRate,
    ])

    const vertexBuf = device.createBuffer({
      size: vertexXOffset.byteLength,
      usage: GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
    })

    device.queue.writeBuffer(vertexBuf, 0, vertexXOffset)
    const groupLayout = device.createBindGroupLayout({
      entries: [
        {
          binding: 0,
          visibility: GPUShaderStage.FRAGMENT,
          sampler: { type: 'filtering' },
        },
        {
          binding: 1,
          visibility: GPUShaderStage.FRAGMENT,
          texture: {
            sampleType: 'float',
            viewDimension: '2d',
            multisampled: false,
          },
        },
        {
          binding: 2,
          visibility: GPUShaderStage.FRAGMENT,
          texture: {
            sampleType: 'float',
            viewDimension: '2d',
            multisampled: false,
          },
        },
        {
          binding: 3,
          visibility: GPUShaderStage.FRAGMENT,
          texture: {
            sampleType: 'float',
            viewDimension: '2d',
            multisampled: false,
          },
        },
      ],
    })

    const group = device.createBindGroup({
      layout: groupLayout,
      entries: [
        {
          binding: 0,
          resource: device.createSampler({}),
        },
        {
          binding: 1,
          resource: textures.y.createView(),
        },
        {
          binding: 2,
          resource: textures.u.createView(),
        },
        {
          binding: 3,
          resource: textures.v.createView(),
        },
      ],
    })

    const totalModule = device.createShaderModule({
      label: 'vs',
      code: code,
    })

    const pipeline = device.createRenderPipeline({
      label: 'render pipeline',
      layout: device.createPipelineLayout({
        bindGroupLayouts: [groupLayout],
      }),
      vertex: {
        module: totalModule,
        entryPoint: 'vs',
        buffers: [
          {
            arrayStride: 4,
            attributes: [
              {
                shaderLocation: 0,
                offset: 0,
                format: 'float32',
              },
            ],
          },
        ],
      },
      fragment: {
        module: totalModule,
        entryPoint: 'fs',
        targets: [{ format: textureFormat }],
      },
      primitive: {
        topology: 'triangle-strip',
      },
    })

    const bundleEncoder = device.createRenderBundleEncoder({
      colorFormats: [textureFormat],
    })

    bundleEncoder.setPipeline(pipeline)
    bundleEncoder.setBindGroup(0, group)
    bundleEncoder.setVertexBuffer(0, vertexBuf)
    bundleEncoder.draw(6)
    const renderBundle = bundleEncoder.finish()

    return [renderBundle, textures, vertexBuf]
  }
}
