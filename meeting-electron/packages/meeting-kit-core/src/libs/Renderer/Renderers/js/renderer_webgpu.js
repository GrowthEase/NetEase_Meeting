"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
var code = "\n  struct OurVertexShaderOutput {\n    @builtin(position) position: vec4f,\n    @location(0) texcoord: vec2f,\n  };\n  \n  @vertex fn vs(\n    @builtin(vertex_index) vertexIndex : u32,\n    @location(0) xOffset: f32\n  ) -> OurVertexShaderOutput {\n    var pos = array<vec2<f32>, 6>(\n      vec2<f32>( 1.0,  1.0),\n      vec2<f32>(-1.0, -1.0),\n      vec2<f32>(-1.0,  1.0),\n      vec2<f32>( 1.0,  1.0),\n      vec2<f32>( 1.0, -1.0),\n      vec2<f32>(-1.0, -1.0),\n    );\n  \n    var uv = array<vec2<f32>, 6>(\n      vec2<f32>(1.0, 0.0),\n      vec2<f32>(0.0, 1.0),\n      vec2<f32>(0.0, 0.0),\n      vec2<f32>(1.0, 0.0),\n      vec2<f32>(1.0, 1.0),\n      vec2<f32>(0.0, 1.0),\n    );\n  \n    var vsOutput: OurVertexShaderOutput;\n    let xy = pos[vertexIndex];\n    vsOutput.position = vec4f(xy, 0.0, 1.0);\n    vsOutput.texcoord = vec2f(uv[vertexIndex].x - xOffset, uv[vertexIndex].y);\n    return vsOutput;\n  }\n  \n  @group(0) @binding(0) var ourSampler: sampler;\n  @group(0) @binding(1) var ourTextureY: texture_2d<f32>;\n  @group(0) @binding(2) var ourTextureU: texture_2d<f32>;\n  @group(0) @binding(3) var ourTextureV: texture_2d<f32>;\n  \n  @fragment fn fs(fsInput: OurVertexShaderOutput) -> @location(0) vec4f {\n    let x = fsInput.texcoord.x;\n    // let uv = vec2f(x, fsInput.texcoord.y);\n  \n    let Y = select(0.0, textureSample(ourTextureY, ourSampler, fsInput.texcoord).x, x > 0.0);\n    let U = select(0.0, textureSample(ourTextureU, ourSampler, fsInput.texcoord).x, x > 0.0);\n    let V = select(0.0, textureSample(ourTextureV, ourSampler, fsInput.texcoord).x, x > 0.0);\n  \n    let fYmul = Y * 1.1643828125;\n    let r = fYmul + 1.59602734375 * V - 0.870787598;\n    let g = fYmul - 0.39176171875 * U - 0.81296875 * V + 0.52959375;\n    let b = fYmul + 2.01723046875 * U - 1.081389160375;\n  \n    return vec4f(r, g, b, 0.0);\n  }\n  ";
var default_background_color = [61 / 255, 61 / 255, 61 / 255, 1];
/**
 * todo:
 * 考虑直接在 初始化画布的时候就将高度处理好
 * 需要处理 canvas 的百分比
 *
 *  */
var WebGPURender = /** @class */ (function () {
    function WebGPURender(canvas, option) {
        this.option = option;
        this.isInit = false;
        this.state = {
            background: default_background_color,
        };
        this.state.canvas = canvas;
    }
    WebGPURender.isSupport = function () {
        return !!navigator.gpu;
    };
    WebGPURender.prototype.init = function () {
        var _a, _b, _c;
        return __awaiter(this, void 0, void 0, function () {
            var adapter, device, ctx, format;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0: return [4 /*yield*/, ((_a = navigator.gpu) === null || _a === void 0 ? void 0 : _a.requestAdapter())];
                    case 1:
                        adapter = _d.sent();
                        return [4 /*yield*/, (adapter === null || adapter === void 0 ? void 0 : adapter.requestDevice())];
                    case 2:
                        device = _d.sent();
                        ctx = (_b = this.state.canvas) === null || _b === void 0 ? void 0 : _b.getContext('webgpu');
                        format = (_c = navigator.gpu) === null || _c === void 0 ? void 0 : _c.getPreferredCanvasFormat();
                        if (!device || !adapter || !ctx || !format) {
                            throw new Error('webgpu render init error');
                        }
                        this.state.device = device;
                        this.state.textureFormat = format;
                        this.state.ctx = ctx;
                        ctx.configure({
                            device: device,
                            format: format,
                        });
                        this.isInit = true;
                        return [2 /*return*/];
                }
            });
        });
    };
    // 只考虑 yuv420
    WebGPURender.prototype.drawFrame = function (videoFrame) {
        return __awaiter(this, void 0, void 0, function () {
            var frame, _a, lastFormat, renderBundle, textures, vertexBuf, _b, device, ctx, needUpdate, commander, pass;
            var _c;
            return __generator(this, function (_d) {
                frame = {
                    buf_y: videoFrame.yBuffer,
                    buf_u: videoFrame.uBuffer,
                    buf_v: videoFrame.vBuffer,
                    stride_y: videoFrame.yStride,
                    stride_u: videoFrame.uStride,
                    stride_v: videoFrame.vStride,
                    width: videoFrame.width,
                    height: videoFrame.height,
                    renderTime: 0,
                };
                if (this.state.canvas) {
                    this.state.canvas.width = frame.stride_y;
                    this.state.canvas.height = frame.height;
                }
                _a = this.state, lastFormat = _a.lastFormat, renderBundle = _a.renderBundle, textures = _a.textures, vertexBuf = _a.vertexBuf;
                _b = this.state, device = _b.device, ctx = _b.ctx;
                if (!ctx || !device) {
                    throw new Error('device or ctx undefined, need call init first');
                }
                needUpdate = false;
                // 判断是否需要重置source
                if ((lastFormat === null || lastFormat === void 0 ? void 0 : lastFormat.textureWidth) !== frame.stride_y ||
                    (lastFormat === null || lastFormat === void 0 ? void 0 : lastFormat.textureHeight) !== frame.height ||
                    (lastFormat === null || lastFormat === void 0 ? void 0 : lastFormat.viewWidth) !== frame.width) {
                    lastFormat = this.format(frame);
                    this.state.lastFormat = lastFormat;
                    needUpdate = true;
                }
                if (!renderBundle || needUpdate) {
                    ;
                    _c = this.createTexturesAndRenderBundle(lastFormat), renderBundle = _c[0], textures = _c[1], vertexBuf = _c[2];
                    this.state.renderBundle = renderBundle;
                    this.state.vertexBuf = vertexBuf;
                    this.state.textures = textures;
                }
                if (!textures) {
                    throw new Error('create texture error');
                }
                this.writeTextures(frame, device, lastFormat, textures);
                commander = device.createCommandEncoder();
                pass = commander.beginRenderPass({
                    colorAttachments: [
                        {
                            view: ctx.getCurrentTexture().createView(),
                            clearValue: this.state.background,
                            loadOp: 'clear',
                            storeOp: 'store',
                        },
                    ],
                });
                pass.setScissorRect(lastFormat.cropWidth, 0, lastFormat.viewWidth, lastFormat.textureHeight);
                pass.executeBundles([renderBundle]);
                pass.end();
                device.queue.submit([commander.finish()]);
                return [2 /*return*/];
            });
        });
    };
    WebGPURender.prototype.clear = function () {
        var _a = this.state, device = _a.device, ctx = _a.ctx;
        if (device && ctx) {
            var commander = device.createCommandEncoder();
            commander.beginRenderPass({
                colorAttachments: [
                    {
                        view: ctx.getCurrentTexture().createView(),
                        clearValue: this.state.background,
                        loadOp: 'clear',
                        storeOp: 'store',
                    },
                ],
            });
        }
    };
    WebGPURender.prototype.destroy = function () {
        // 清理 纹理
        if (this.state.textures) {
            this.state.textures.y.destroy();
            this.state.textures.u.destroy();
            this.state.textures.v.destroy();
            this.state.textures = undefined;
        }
        // 清理顶点缓冲区
        if (this.state.vertexBuf) {
            this.state.vertexBuf.destroy();
            this.state.vertexBuf = undefined;
        }
        if (this.state.ctx) {
            this.state.ctx.unconfigure();
            this.state.ctx = undefined;
        }
        if (this.state.device) {
            this.state.device.destroy();
            this.state.device = undefined;
        }
        this.state = {
            background: default_background_color,
        };
        this.isInit = false;
    };
    // 帧 data 宽度和 frame 宽度不一致，所以需要处理
    WebGPURender.prototype.format = function (frame) {
        return {
            textureWidth: frame.stride_y,
            textureHeight: frame.height,
            viewWidth: frame.width,
            cropWidth: (frame.stride_y - frame.width) / 2,
            xOffsetRate: (frame.stride_y - frame.width) / 2 / frame.stride_y,
        };
    };
    WebGPURender.prototype.writeTextures = function (frame, device, format, textures) {
        device.queue.writeTexture({ texture: textures.y }, frame.buf_y, { bytesPerRow: format.textureWidth }, { width: format.textureWidth, height: format.textureHeight });
        device.queue.writeTexture({ texture: textures.u }, frame.buf_u, { bytesPerRow: format.textureWidth / 2 }, { width: format.textureWidth / 2, height: format.textureHeight / 2 });
        device.queue.writeTexture({ texture: textures.v }, frame.buf_v, { bytesPerRow: format.textureWidth / 2 }, { width: format.textureWidth / 2, height: format.textureHeight / 2 });
    };
    WebGPURender.prototype.createTexturesAndRenderBundle = function (format) {
        var _a = this.state, device = _a.device, textureFormat = _a.textureFormat;
        if (!device || !textureFormat) {
            throw new Error('device or textureFormat undefined, need call init first');
        }
        var textures = {
            y: device.createTexture({
                format: 'r8unorm',
                size: [format.textureWidth, format.textureHeight],
                usage: GPUTextureUsage.COPY_DST |
                    GPUTextureUsage.RENDER_ATTACHMENT |
                    GPUTextureUsage.TEXTURE_BINDING,
            }),
            u: device.createTexture({
                format: 'r8unorm',
                size: [format.textureWidth / 2, format.textureHeight / 2],
                usage: GPUTextureUsage.COPY_DST |
                    GPUTextureUsage.RENDER_ATTACHMENT |
                    GPUTextureUsage.TEXTURE_BINDING,
            }),
            v: device.createTexture({
                format: 'r8unorm',
                size: [format.textureWidth / 2, format.textureHeight / 2],
                usage: GPUTextureUsage.COPY_DST |
                    GPUTextureUsage.RENDER_ATTACHMENT |
                    GPUTextureUsage.TEXTURE_BINDING,
            }),
        };
        var vertexXOffset = new Float32Array([
            format.xOffsetRate,
            format.xOffsetRate,
            format.xOffsetRate,
            format.xOffsetRate,
            format.xOffsetRate,
            format.xOffsetRate,
        ]);
        var vertexBuf = device.createBuffer({
            size: vertexXOffset.byteLength,
            usage: GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
        });
        device.queue.writeBuffer(vertexBuf, 0, vertexXOffset);
        var groupLayout = device.createBindGroupLayout({
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
        });
        var group = device.createBindGroup({
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
        });
        var totalModule = device.createShaderModule({
            label: 'vs',
            code: code,
        });
        var pipeline = device.createRenderPipeline({
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
        });
        var bundleEncoder = device.createRenderBundleEncoder({
            colorFormats: [textureFormat],
        });
        bundleEncoder.setPipeline(pipeline);
        bundleEncoder.setBindGroup(0, group);
        bundleEncoder.setVertexBuffer(0, vertexBuf);
        bundleEncoder.draw(6);
        var renderBundle = bundleEncoder.finish();
        return [renderBundle, textures, vertexBuf];
    };
    return WebGPURender;
}());
exports.default = WebGPURender;
