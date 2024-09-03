;(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined'
    ? factory(exports)
    : typeof define === 'function' && define.amd
    ? define(['exports'], factory)
    : ((global =
        typeof globalThis !== 'undefined' ? globalThis : global || self),
      factory((global.yuvCanvas = {})))
})(this, function (exports) {
  'use strict'

  var commonjsGlobal =
    typeof globalThis !== 'undefined'
      ? globalThis
      : typeof window !== 'undefined'
      ? window
      : typeof global !== 'undefined'
      ? global
      : typeof self !== 'undefined'
      ? self
      : {}

  function createCommonjsModule(fn, module) {
    return (
      (module = { exports: {} }), fn(module, module.exports), module.exports
    )
  }

  var FrameSink = createCommonjsModule(function (module) {
    ;(function () {
      /**
       * Create a YUVCanvas and attach it to an HTML5 canvas element.
       *
       * This will take over the drawing context of the canvas and may turn
       * it into a WebGL 3d canvas if possible. Do not attempt to use the
       * drawing context directly after this.
       *
       * @param {HTMLCanvasElement} canvas - HTML canvas element to attach to
       * @param {YUVCanvasOptions} options - map of options
       * @throws exception if WebGL requested but unavailable
       * @constructor
       * @abstract
       */
      function FrameSink(canvas, options) {
        throw new Error('abstract')
      }

      /**
       * Draw a single YUV frame on the underlying canvas, converting to RGB.
       * If necessary the canvas will be resized to the optimal pixel size
       * for the given buffer's format.
       *
       * @param {YUVBuffer} buffer - the YUV buffer to draw
       * @see {@link https://www.npmjs.com/package/yuv-buffer|yuv-buffer} for format
       */
      FrameSink.prototype.drawFrame = function (buffer) {
        throw new Error('abstract')
      }

      /**
       * Clear the canvas using appropriate underlying 2d or 3d context.
       */
      FrameSink.prototype.clear = function () {
        throw new Error('abstract')
      }

      module.exports = FrameSink
    })()
  })

  var depower = createCommonjsModule(function (module) {
    ;(function () {
      /**
       * Convert a ratio into a bit-shift count; for instance a ratio of 2
       * becomes a bit-shift of 1, while a ratio of 1 is a bit-shift of 0.
       *
       * @author Brion Vibber <brion@pobox.com>
       * @copyright 2016
       * @license MIT-style
       *
       * @param {number} ratio - the integer ratio to convert.
       * @returns {number} - number of bits to shift to multiply/divide by the ratio.
       * @throws exception if given a non-power-of-two
       */
      function depower(ratio) {
        var shiftCount = 0,
          n = ratio >> 1
        while (n != 0) {
          n = n >> 1
          shiftCount++
        }
        if (ratio !== 1 << shiftCount) {
          throw (
            'chroma plane dimensions must be power of 2 ratio to luma plane dimensions; got ' +
            ratio
          )
        }
        return shiftCount
      }

      module.exports = depower
    })()
  })

  var YCbCr = createCommonjsModule(function (module) {
    ;(function () {
      var depower$1 = depower

      /**
       * Basic YCbCr->RGB conversion
       *
       * @author Brion Vibber <brion@pobox.com>
       * @copyright 2014-2019
       * @license MIT-style
       *
       * @param {YUVFrame} buffer - input frame buffer
       * @param {Uint8ClampedArray} output - array to draw RGBA into
       * Assumes that the output array already has alpha channel set to opaque.
       */
      function convertYCbCr(buffer, output) {
        var width = buffer.format.width | 0,
          height = buffer.format.height | 0,
          hdec = depower$1(buffer.format.width / buffer.format.chromaWidth) | 0,
          vdec =
            depower$1(buffer.format.height / buffer.format.chromaHeight) | 0,
          bytesY = buffer.y.bytes,
          bytesCb = buffer.u.bytes,
          bytesCr = buffer.v.bytes,
          strideY = buffer.y.stride | 0,
          strideCb = buffer.u.stride | 0,
          strideCr = buffer.v.stride | 0,
          outStride = width << 2,
          YPtr = 0,
          Y0Ptr = 0,
          Y1Ptr = 0,
          CbPtr = 0,
          CrPtr = 0,
          outPtr = 0,
          outPtr0 = 0,
          outPtr1 = 0,
          colorCb = 0,
          colorCr = 0,
          multY = 0,
          multCrR = 0,
          multCbCrG = 0,
          multCbB = 0,
          x = 0,
          y = 0,
          xdec = 0,
          ydec = 0

        if (hdec == 1 && vdec == 1) {
          // Optimize for 4:2:0, which is most common
          outPtr0 = 0
          outPtr1 = outStride
          ydec = 0
          for (y = 0; y < height; y += 2) {
            Y0Ptr = (y * strideY) | 0
            Y1Ptr = (Y0Ptr + strideY) | 0
            CbPtr = (ydec * strideCb) | 0
            CrPtr = (ydec * strideCr) | 0
            for (x = 0; x < width; x += 2) {
              colorCb = bytesCb[CbPtr++] | 0
              colorCr = bytesCr[CrPtr++] | 0

              // Quickie YUV conversion
              // https://en.wikipedia.org/wiki/YCbCr#ITU-R_BT.2020_conversion
              // multiplied by 256 for integer-friendliness
              multCrR = (((409 * colorCr) | 0) - 57088) | 0
              multCbCrG =
                (((100 * colorCb) | 0) + ((208 * colorCr) | 0) - 34816) | 0
              multCbB = (((516 * colorCb) | 0) - 70912) | 0

              multY = (298 * bytesY[Y0Ptr++]) | 0
              output[outPtr0] = (multY + multCrR) >> 8
              output[outPtr0 + 1] = (multY - multCbCrG) >> 8
              output[outPtr0 + 2] = (multY + multCbB) >> 8
              outPtr0 += 4

              multY = (298 * bytesY[Y0Ptr++]) | 0
              output[outPtr0] = (multY + multCrR) >> 8
              output[outPtr0 + 1] = (multY - multCbCrG) >> 8
              output[outPtr0 + 2] = (multY + multCbB) >> 8
              outPtr0 += 4

              multY = (298 * bytesY[Y1Ptr++]) | 0
              output[outPtr1] = (multY + multCrR) >> 8
              output[outPtr1 + 1] = (multY - multCbCrG) >> 8
              output[outPtr1 + 2] = (multY + multCbB) >> 8
              outPtr1 += 4

              multY = (298 * bytesY[Y1Ptr++]) | 0
              output[outPtr1] = (multY + multCrR) >> 8
              output[outPtr1 + 1] = (multY - multCbCrG) >> 8
              output[outPtr1 + 2] = (multY + multCbB) >> 8
              outPtr1 += 4
            }
            outPtr0 += outStride
            outPtr1 += outStride
            ydec++
          }
        } else {
          outPtr = 0
          for (y = 0; y < height; y++) {
            xdec = 0
            ydec = y >> vdec
            YPtr = (y * strideY) | 0
            CbPtr = (ydec * strideCb) | 0
            CrPtr = (ydec * strideCr) | 0

            for (x = 0; x < width; x++) {
              xdec = x >> hdec
              colorCb = bytesCb[CbPtr + xdec] | 0
              colorCr = bytesCr[CrPtr + xdec] | 0

              // Quickie YUV conversion
              // https://en.wikipedia.org/wiki/YCbCr#ITU-R_BT.2020_conversion
              // multiplied by 256 for integer-friendliness
              multCrR = (((409 * colorCr) | 0) - 57088) | 0
              multCbCrG =
                (((100 * colorCb) | 0) + ((208 * colorCr) | 0) - 34816) | 0
              multCbB = (((516 * colorCb) | 0) - 70912) | 0

              multY = (298 * bytesY[YPtr++]) | 0
              output[outPtr] = (multY + multCrR) >> 8
              output[outPtr + 1] = (multY - multCbCrG) >> 8
              output[outPtr + 2] = (multY + multCbB) >> 8
              outPtr += 4
            }
          }
        }
      }

      module.exports = {
        convertYCbCr: convertYCbCr,
      }
    })()
  })
  YCbCr.convertYCbCr

  var SoftwareFrameSink = createCommonjsModule(function (module) {
    ;(function () {
      var FrameSink$1 = FrameSink,
        YCbCr$1 = YCbCr

      /**
       * @param {HTMLCanvasElement} canvas - HTML canvas eledment to attach to
       * @constructor
       */
      function SoftwareFrameSink(canvas) {
        var self = this,
          ctx = canvas.getContext('2d'),
          imageData = null,
          resampleCanvas = null,
          resampleContext = null

        function initImageData(width, height) {
          imageData = ctx.createImageData(width, height)

          // Prefill the alpha to opaque
          var data = imageData.data,
            pixelCount = width * height * 4
          for (var i = 0; i < pixelCount; i += 4) {
            data[i + 3] = 255
          }
        }

        function initResampleCanvas(cropWidth, cropHeight) {
          resampleCanvas = document.createElement('canvas')
          resampleCanvas.width = cropWidth
          resampleCanvas.height = cropHeight
          resampleContext = resampleCanvas.getContext('2d')
        }

        /**
         * Actually draw a frame into the canvas.
         * @param {YUVFrame} buffer - YUV frame buffer object to draw
         */
        self.drawFrame = function drawFrame(buffer) {
          var format = buffer.format

          if (
            canvas.width !== format.displayWidth ||
            canvas.height !== format.displayHeight
          ) {
            // Keep the canvas at the right size...
            canvas.width = format.displayWidth
            canvas.height = format.displayHeight
          }

          if (
            imageData === null ||
            imageData.width != format.width ||
            imageData.height != format.height
          ) {
            initImageData(format.width, format.height)
          }

          // YUV -> RGB over the entire encoded frame
          YCbCr$1.convertYCbCr(buffer, imageData.data)

          var resample =
            format.cropWidth != format.displayWidth ||
            format.cropHeight != format.displayHeight
          var drawContext
          if (resample) {
            // hack for non-square aspect-ratio
            // putImageData doesn't resample, so we have to draw in two steps.
            if (!resampleCanvas) {
              initResampleCanvas(format.cropWidth, format.cropHeight)
            }
            drawContext = resampleContext
          } else {
            drawContext = ctx
          }

          // Draw cropped frame to either the final or temporary canvas
          drawContext.putImageData(
            imageData,
            -format.cropLeft,
            -format.cropTop, // must offset the offset
            format.cropLeft,
            format.cropTop,
            format.cropWidth,
            format.cropHeight
          )

          if (resample) {
            ctx.drawImage(
              resampleCanvas,
              0,
              0,
              format.displayWidth,
              format.displayHeight
            )
          }
        }

        self.clear = function () {
          ctx.clearRect(0, 0, canvas.width, canvas.height)
        }

        self.destroy = function () {
          ctx.clearRect(0, 0, canvas.width, canvas.height)
        }

        return self
      }

      SoftwareFrameSink.prototype = Object.create(FrameSink$1.prototype)

      module.exports = SoftwareFrameSink
    })()
  })

  var shaders = {
    vertex:
      'precision mediump float;\n\nattribute vec2 aPosition;\nattribute vec2 aLumaPosition;\nattribute vec2 aChromaPosition;\nvarying vec2 vLumaPosition;\nvarying vec2 vChromaPosition;\nvoid main() {\n    gl_Position = vec4(aPosition, 0, 1);\n    vLumaPosition = aLumaPosition;\n    vChromaPosition = aChromaPosition;\n}\n',
    fragment:
      '// inspired by https://github.com/mbebenita/Broadway/blob/master/Player/canvas.js\n\nprecision mediump float;\n\nuniform sampler2D uTextureY;\nuniform sampler2D uTextureCb;\nuniform sampler2D uTextureCr;\nvarying vec2 vLumaPosition;\nvarying vec2 vChromaPosition;\nvoid main() {\n   // Y, Cb, and Cr planes are uploaded as ALPHA textures.\n   float fY = texture2D(uTextureY, vLumaPosition).w;\n   float fCb = texture2D(uTextureCb, vChromaPosition).w;\n   float fCr = texture2D(uTextureCr, vChromaPosition).w;\n\n   // Premultipy the Y...\n   float fYmul = fY * 1.1643828125;\n\n   // And convert that to RGB!\n   gl_FragColor = vec4(\n     fYmul + 1.59602734375 * fCr - 0.87078515625,\n     fYmul - 0.39176171875 * fCb - 0.81296875 * fCr + 0.52959375,\n     fYmul + 2.017234375   * fCb - 1.081390625,\n     1\n   );\n}\n',
    vertexStripe:
      'precision mediump float;\n\nattribute vec2 aPosition;\nattribute vec2 aTexturePosition;\nvarying vec2 vTexturePosition;\n\nvoid main() {\n    gl_Position = vec4(aPosition, 0, 1);\n    vTexturePosition = aTexturePosition;\n}\n',
    fragmentStripe:
      "// extra 'stripe' texture fiddling to work around IE 11's poor performance on gl.LUMINANCE and gl.ALPHA textures\n\nprecision mediump float;\n\nuniform sampler2D uStripe;\nuniform sampler2D uTexture;\nvarying vec2 vTexturePosition;\nvoid main() {\n   // Y, Cb, and Cr planes are mapped into a pseudo-RGBA texture\n   // so we can upload them without expanding the bytes on IE 11\n   // which doesn't allow LUMINANCE or ALPHA textures\n   // The stripe textures mark which channel to keep for each pixel.\n   // Each texture extraction will contain the relevant value in one\n   // channel only.\n\n   float fLuminance = dot(\n      texture2D(uStripe, vTexturePosition),\n      texture2D(uTexture, vTexturePosition)\n   );\n\n   gl_FragColor = vec4(0, 0, 0, fLuminance);\n}\n",
  }

  var WebGLFrameSink = createCommonjsModule(function (module) {
    ;(function () {
      var FrameSink$1 = FrameSink,
        shaders$1 = shaders

      /**
       * Warning: canvas must not have been used for 2d drawing prior!
       *
       * @param {HTMLCanvasElement} canvas - HTML canvas element to attach to
       * @constructor
       */
      function WebGLFrameSink(canvas) {
        var self = this,
          gl = WebGLFrameSink.contextForCanvas(canvas)
        // swap this to enable more error checks, which can slow down rendering

        if (gl === null) {
          throw new Error('WebGL unavailable')
        }

        function compileShader(type, source) {
          var shader = gl.createShader(type)
          gl.shaderSource(shader, source)
          gl.compileShader(shader)

          if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            var err = gl.getShaderInfoLog(shader)
            gl.deleteShader(shader)
            throw new Error(
              'GL shader compilation for ' + type + ' failed: ' + err
            )
          }

          return shader
        }

        var program, unpackProgram

        // In the world of GL there are no rectangles.
        // There are only triangles.
        // THERE IS NO SPOON.
        var rectangle = new Float32Array([
          // First triangle (top left, clockwise)
          -1.0, -1.0, +1.0, -1.0, -1.0, +1.0,

          // Second triangle (bottom right, clockwise)
          -1.0, +1.0, +1.0, -1.0, +1.0, +1.0,
        ])

        var textures = {}
        var framebuffers = {}
        var stripes = {}
        var buf, positionLocation
        var unpackTexturePositionBuffer, unpackTexturePositionLocation
        var stripeLocation, unpackTextureLocation
        var lumaPositionBuffer, lumaPositionLocation
        var chromaPositionBuffer, chromaPositionLocation

        function createOrReuseTexture(name, formatUpdate) {
          if (!textures[name] || formatUpdate) {
            textures[name] = gl.createTexture()
          }
          return textures[name]
        }

        function uploadTexture(name, formatUpdate, width, height, data) {
          var create = !textures[name] || formatUpdate
          var texture = createOrReuseTexture(name, formatUpdate)
          gl.activeTexture(gl.TEXTURE0)
          if (WebGLFrameSink.stripe) {
            var uploadTemp = !textures[name + '_temp'] || formatUpdate
            var tempTexture = createOrReuseTexture(name + '_temp', formatUpdate)
            gl.bindTexture(gl.TEXTURE_2D, tempTexture)
            if (uploadTemp) {
              // new texture
              gl.texParameteri(
                gl.TEXTURE_2D,
                gl.TEXTURE_WRAP_S,
                gl.CLAMP_TO_EDGE
              )
              gl.texParameteri(
                gl.TEXTURE_2D,
                gl.TEXTURE_WRAP_T,
                gl.CLAMP_TO_EDGE
              )
              gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
              gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
              gl.texImage2D(
                gl.TEXTURE_2D,
                0, // mip level
                gl.RGBA, // internal format
                width / 4,
                height,
                0, // border
                gl.RGBA, // format
                gl.UNSIGNED_BYTE, // type
                data // data!
              )
            } else {
              // update texture
              gl.texSubImage2D(
                gl.TEXTURE_2D,
                0, // mip level
                0, // x offset
                0, // y offset
                width / 4,
                height,
                gl.RGBA, // format
                gl.UNSIGNED_BYTE, // type
                data // data!
              )
            }

            var stripeTexture = textures[name + '_stripe']
            var uploadStripe = !stripeTexture || formatUpdate
            if (uploadStripe) {
              stripeTexture = createOrReuseTexture(
                name + '_stripe',
                formatUpdate
              )
            }
            gl.bindTexture(gl.TEXTURE_2D, stripeTexture)
            if (uploadStripe) {
              gl.texParameteri(
                gl.TEXTURE_2D,
                gl.TEXTURE_WRAP_S,
                gl.CLAMP_TO_EDGE
              )
              gl.texParameteri(
                gl.TEXTURE_2D,
                gl.TEXTURE_WRAP_T,
                gl.CLAMP_TO_EDGE
              )
              gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
              gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
              gl.texImage2D(
                gl.TEXTURE_2D,
                0, // mip level
                gl.RGBA, // internal format
                width,
                1,
                0, // border
                gl.RGBA, // format
                gl.UNSIGNED_BYTE, //type
                buildStripe(width) // data!
              )
            }
          } else {
            gl.bindTexture(gl.TEXTURE_2D, texture)
            if (create) {
              gl.texParameteri(
                gl.TEXTURE_2D,
                gl.TEXTURE_WRAP_S,
                gl.CLAMP_TO_EDGE
              )
              gl.texParameteri(
                gl.TEXTURE_2D,
                gl.TEXTURE_WRAP_T,
                gl.CLAMP_TO_EDGE
              )
              gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
              gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
              gl.texImage2D(
                gl.TEXTURE_2D,
                0, // mip level
                gl.ALPHA, // internal format
                width,
                height,
                0, // border
                gl.ALPHA, // format
                gl.UNSIGNED_BYTE, //type
                data // data!
              )
            } else {
              gl.texSubImage2D(
                gl.TEXTURE_2D,
                0, // mip level
                0, // x
                0, // y
                width,
                height,
                gl.ALPHA, // internal format
                gl.UNSIGNED_BYTE, //type
                data // data!
              )
            }
          }
        }

        function unpackTexture(name, formatUpdate, width, height) {
          var texture = textures[name]

          // Upload to a temporary RGBA texture, then unpack it.
          // This is faster than CPU-side swizzling in ANGLE on Windows.
          gl.useProgram(unpackProgram)

          var fb = framebuffers[name]
          if (!fb || formatUpdate) {
            // Create a framebuffer and an empty target size
            gl.activeTexture(gl.TEXTURE0)
            gl.bindTexture(gl.TEXTURE_2D, texture)
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
            gl.texImage2D(
              gl.TEXTURE_2D,
              0, // mip level
              gl.RGBA, // internal format
              width,
              height,
              0, // border
              gl.RGBA, // format
              gl.UNSIGNED_BYTE, //type
              null // data!
            )

            fb = framebuffers[name] = gl.createFramebuffer()
          }

          gl.bindFramebuffer(gl.FRAMEBUFFER, fb)
          gl.framebufferTexture2D(
            gl.FRAMEBUFFER,
            gl.COLOR_ATTACHMENT0,
            gl.TEXTURE_2D,
            texture,
            0
          )

          var tempTexture = textures[name + '_temp']
          gl.activeTexture(gl.TEXTURE1)
          gl.bindTexture(gl.TEXTURE_2D, tempTexture)
          gl.uniform1i(unpackTextureLocation, 1)

          var stripeTexture = textures[name + '_stripe']
          gl.activeTexture(gl.TEXTURE2)
          gl.bindTexture(gl.TEXTURE_2D, stripeTexture)
          gl.uniform1i(stripeLocation, 2)

          // Rectangle geometry
          gl.bindBuffer(gl.ARRAY_BUFFER, buf)
          gl.enableVertexAttribArray(positionLocation)
          gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0)

          // Set up the texture geometry...
          gl.bindBuffer(gl.ARRAY_BUFFER, unpackTexturePositionBuffer)
          gl.enableVertexAttribArray(unpackTexturePositionLocation)
          gl.vertexAttribPointer(
            unpackTexturePositionLocation,
            2,
            gl.FLOAT,
            false,
            0,
            0
          )

          // Draw into the target texture...
          gl.viewport(0, 0, width, height)

          gl.drawArrays(gl.TRIANGLES, 0, rectangle.length / 2)

          gl.bindFramebuffer(gl.FRAMEBUFFER, null)
        }

        function attachTexture(name, register, index) {
          gl.activeTexture(register)
          gl.bindTexture(gl.TEXTURE_2D, textures[name])
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

          gl.uniform1i(gl.getUniformLocation(program, name), index)
        }

        function buildStripe(width) {
          if (stripes[width]) {
            return stripes[width]
          }
          var len = width,
            out = new Uint32Array(len)
          for (var i = 0; i < len; i += 4) {
            out[i] = 0x000000ff
            out[i + 1] = 0x0000ff00
            out[i + 2] = 0x00ff0000
            out[i + 3] = 0xff000000
          }
          return (stripes[width] = new Uint8Array(out.buffer))
        }

        function initProgram(vertexShaderSource, fragmentShaderSource) {
          var vertexShader = compileShader(gl.VERTEX_SHADER, vertexShaderSource)
          var fragmentShader = compileShader(
            gl.FRAGMENT_SHADER,
            fragmentShaderSource
          )

          var program = gl.createProgram()
          gl.attachShader(program, vertexShader)
          gl.attachShader(program, fragmentShader)

          gl.linkProgram(program)
          if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
            var err = gl.getProgramInfoLog(program)
            gl.deleteProgram(program)
            throw new Error('GL program linking failed: ' + err)
          }

          return program
        }

        function init() {
          if (WebGLFrameSink.stripe) {
            unpackProgram = initProgram(
              shaders$1.vertexStripe,
              shaders$1.fragmentStripe
            )
            gl.getAttribLocation(unpackProgram, 'aPosition')

            unpackTexturePositionBuffer = gl.createBuffer()
            var textureRectangle = new Float32Array([
              0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1,
            ])
            gl.bindBuffer(gl.ARRAY_BUFFER, unpackTexturePositionBuffer)
            gl.bufferData(gl.ARRAY_BUFFER, textureRectangle, gl.STATIC_DRAW)

            unpackTexturePositionLocation = gl.getAttribLocation(
              unpackProgram,
              'aTexturePosition'
            )
            stripeLocation = gl.getUniformLocation(unpackProgram, 'uStripe')
            unpackTextureLocation = gl.getUniformLocation(
              unpackProgram,
              'uTexture'
            )
          }
          program = initProgram(shaders$1.vertex, shaders$1.fragment)

          buf = gl.createBuffer()
          gl.bindBuffer(gl.ARRAY_BUFFER, buf)
          gl.bufferData(gl.ARRAY_BUFFER, rectangle, gl.STATIC_DRAW)

          positionLocation = gl.getAttribLocation(program, 'aPosition')
          lumaPositionBuffer = gl.createBuffer()
          lumaPositionLocation = gl.getAttribLocation(program, 'aLumaPosition')
          chromaPositionBuffer = gl.createBuffer()
          chromaPositionLocation = gl.getAttribLocation(
            program,
            'aChromaPosition'
          )
        }

        /**
         * Actually draw a frame.
         * @param {YUVFrame} buffer - YUV frame buffer object
         */
        self.drawFrame = function (buffer) {
          var format = buffer.format
          gl.pixelStorei(gl.UNPACK_ALIGNMENT, format.pixelStorei || 4)

          var formatUpdate =
            !program ||
            canvas.width !== format.displayWidth ||
            canvas.height !== format.displayHeight

          if (formatUpdate) {
            // Keep the canvas at the right size...
            canvas.width = format.displayWidth
            canvas.height = format.displayHeight
            self.clear()
          }

          if (!program) {
            init()
          }
          if (formatUpdate) {
            var setupTexturePosition = function (buffer, location, texWidth) {
              // Warning: assumes that the stride for Cb and Cr is the same size in output pixels
              var textureX0 = format.cropLeft / texWidth
              var textureX1 = (format.cropLeft + format.cropWidth) / texWidth
              var textureY0 =
                (format.cropTop + format.cropHeight) / format.height
              var textureY1 = format.cropTop / format.height
              var textureRectangle = new Float32Array([
                textureX0,
                textureY0,
                textureX1,
                textureY0,
                textureX0,
                textureY1,
                textureX0,
                textureY1,
                textureX1,
                textureY0,
                textureX1,
                textureY1,
              ])

              gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
              gl.bufferData(gl.ARRAY_BUFFER, textureRectangle, gl.STATIC_DRAW)
            }
            setupTexturePosition(
              lumaPositionBuffer,
              lumaPositionLocation,
              buffer.y.stride
            )
            setupTexturePosition(
              chromaPositionBuffer,
              chromaPositionLocation,
              (buffer.u.stride * format.width) / format.chromaWidth
            )
          }

          // Create or update the textures...
          uploadTexture(
            'uTextureY',
            formatUpdate,
            buffer.y.stride,
            format.height,
            buffer.y.bytes
          )
          uploadTexture(
            'uTextureCb',
            formatUpdate,
            buffer.u.stride,
            format.chromaHeight,
            buffer.u.bytes
          )
          uploadTexture(
            'uTextureCr',
            formatUpdate,
            buffer.v.stride,
            format.chromaHeight,
            buffer.v.bytes
          )

          if (WebGLFrameSink.stripe) {
            // Unpack the textures after upload to avoid blocking on GPU
            unpackTexture(
              'uTextureY',
              formatUpdate,
              buffer.y.stride,
              format.height
            )
            unpackTexture(
              'uTextureCb',
              formatUpdate,
              buffer.u.stride,
              format.chromaHeight
            )
            unpackTexture(
              'uTextureCr',
              formatUpdate,
              buffer.v.stride,
              format.chromaHeight
            )
          }

          // Set up the rectangle and draw it
          gl.useProgram(program)
          gl.viewport(0, 0, canvas.width, canvas.height)

          attachTexture('uTextureY', gl.TEXTURE0, 0)
          attachTexture('uTextureCb', gl.TEXTURE1, 1)
          attachTexture('uTextureCr', gl.TEXTURE2, 2)

          // Set up geometry
          gl.bindBuffer(gl.ARRAY_BUFFER, buf)
          gl.enableVertexAttribArray(positionLocation)
          gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0)

          // Set up the texture geometry...
          gl.bindBuffer(gl.ARRAY_BUFFER, lumaPositionBuffer)
          gl.enableVertexAttribArray(lumaPositionLocation)
          gl.vertexAttribPointer(lumaPositionLocation, 2, gl.FLOAT, false, 0, 0)

          gl.bindBuffer(gl.ARRAY_BUFFER, chromaPositionBuffer)
          gl.enableVertexAttribArray(chromaPositionLocation)
          gl.vertexAttribPointer(
            chromaPositionLocation,
            2,
            gl.FLOAT,
            false,
            0,
            0
          )

          // Aaaaand draw stuff.
          gl.drawArrays(gl.TRIANGLES, 0, rectangle.length / 2)
        }

        self.clear = function () {
          gl.viewport(0, 0, canvas.width, canvas.height)
          gl.clearColor(0.0, 0.0, 0.0, 0.0)
          gl.clear(gl.COLOR_BUFFER_BIT)
        }

        self.destroy = function () {
          gl.getExtension('WEBGL_lose_context').loseContext()
        }

        self.clear()

        return self
      }

      // Optional performance hack for Windows; luminance and alpha textures are
      // ssllooww to upload on some machines, so we pack into RGBA and unpack in
      // the shaders.
      //
      // Some browsers / GPUs seem to have no problem with this, others have
      // a huge impact in CPU doing the texture uploads.
      //
      // For instance on macOS 12.2 on a MacBook Pro 2018 with AMD GPU it
      // can real down at high res. This is partially compensated for by
      // improving the upload-vs-update behavior for the alpha textures.
      //
      // Currently keeping it off as of April 2022, but leaving it in so it
      // can be enabled if desired.
      WebGLFrameSink.stripe = false

      WebGLFrameSink.contextForCanvas = function (canvas) {
        var options = {
          // Don't trigger discrete GPU in multi-GPU systems
          preferLowPowerToHighPerformance: true,
          powerPreference: 'low-power',
          // Don't try to use software GL rendering!
          failIfMajorPerformanceCaveat: true,
          // In case we need to capture the resulting output.
          preserveDrawingBuffer: true,
        }
        return (
          canvas.getContext('webgl', options) ||
          canvas.getContext('experimental-webgl', options)
        )
      }

      /**
       * Static function to check if WebGL will be available with appropriate features.
       *
       * @returns {boolean} - true if available
       */
      WebGLFrameSink.isAvailable = function () {
        return true
        /*
	    var canvas = document.createElement('canvas'),
	      gl
	    canvas.width = 1
	    canvas.height = 1
	    try {
	      gl = WebGLFrameSink.contextForCanvas(canvas)
	    } catch (e) {
	      return false
	    }
	    if (gl) {
	      var register = gl.TEXTURE0,
	        width = 4,
	        height = 4,
	        texture = gl.createTexture(),
	        data = new Uint8Array(width * height),
	        texWidth = WebGLFrameSink.stripe ? width / 4 : width,
	        format = WebGLFrameSink.stripe ? gl.RGBA : gl.ALPHA,
	        filter = WebGLFrameSink.stripe ? gl.NEAREST : gl.LINEAR

	      gl.activeTexture(register)
	      gl.bindTexture(gl.TEXTURE_2D, texture)
	      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
	      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
	      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filter)
	      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filter)
	      gl.texImage2D(
	        gl.TEXTURE_2D,
	        0, // mip level
	        format, // internal format
	        texWidth,
	        height,
	        0, // border
	        format, // format
	        gl.UNSIGNED_BYTE, //type
	        data // data!
	      )

	      var err = gl.getError()
	      if (err) {
	        // Doesn't support alpha textures?
	        return false
	      } else {
	        return true
	      }
	    } else {
	      return false
	    }
	    */
      }

      WebGLFrameSink.prototype = Object.create(FrameSink$1.prototype)

      module.exports = WebGLFrameSink
    })()
  })

  var yuvCanvas = createCommonjsModule(function (module) {
    ;(function () {
      var FrameSink$1 = FrameSink,
        SoftwareFrameSink$1 = SoftwareFrameSink,
        WebGLFrameSink$1 = WebGLFrameSink

      /**
       * @typedef {Object} YUVCanvasOptions
       * @property {boolean} webGL - Whether to use WebGL to draw to the canvas and accelerate color space conversion. If left out, defaults to auto-detect.
       */

      var YUVCanvas = {
        FrameSink: FrameSink$1,

        SoftwareFrameSink: SoftwareFrameSink$1,

        WebGLFrameSink: WebGLFrameSink$1,

        /**
         * Attach a suitable FrameSink instance to an HTML5 canvas element.
         *
         * This will take over the drawing context of the canvas and may turn
         * it into a WebGL 3d canvas if possible. Do not attempt to use the
         * drawing context directly after this.
         *
         * @param {HTMLCanvasElement} canvas - HTML canvas element to attach to
         * @param {YUVCanvasOptions} options - map of options
         * @returns {FrameSink} - instance of suitable subclass.
         */
        attach: function (canvas, options) {
          options = options || {}
          var webGL =
            'webGL' in options ? options.webGL : WebGLFrameSink$1.isAvailable()
          if (webGL) {
            console.log('Using WebGLFrameSink for rendering')
            return new WebGLFrameSink$1(canvas, options)
          } else {
            console.log('Using SoftwareFrameSink for rendering')
            return new SoftwareFrameSink$1(canvas, options)
          }
        },
      }

      module.exports = YUVCanvas
    })()
  })

  var yuvCanvasMap = {}

  function getYuvFrame(data, width, height, displayWidth, displayHeight) {
    var uvWidth = width / 2
    var pixelStorei = 1
    if (uvWidth % 8 === 0) {
      pixelStorei = 8
    } else if (uvWidth % 4 === 0) {
      pixelStorei = 4
    } else if (uvWidth % 2 === 0) {
      pixelStorei = 2
    }
    return {
      format: {
        width: width,
        height: height,
        chromaWidth: width / 2,
        chromaHeight: height / 2,
        cropLeft: 0, // default
        cropTop: 0, // default
        cropHeight: height,
        cropWidth: width,
        displayWidth: displayWidth || width, // derived from width via cropWidth
        displayHeight: displayHeight || height, // derived from cropHeight
        pixelStorei: pixelStorei, // default
      },
      y: {
        bytes: data.bytes.subarray(0, data.yOffset),
        stride: data.yStride,
      },
      u: {
        bytes: data.bytes.subarray(data.yOffset, data.uOffset),
        stride: data.uStride,
      },
      v: {
        bytes: data.bytes.subarray(data.uOffset, data.vOffset),
        stride: data.vStride,
      },
    }
  }

  commonjsGlobal.addEventListener(
    'message',
    function (e) {
      var data = e.data
      var uuid = data.uuid
      var type = data.type || 'video'
      var canvas = data.canvas
      var frame = data.frame
      var canvasKey = type + '-' + uuid
      var removeCanvas = data.removeCanvas
      if (canvas) {
        var yuvCanvas$1 = yuvCanvas.attach(canvas)
        yuvCanvasMap[canvasKey] = yuvCanvas$1
      } else if (removeCanvas) {
        delete yuvCanvasMap[canvasKey]
      } else if (frame) {
        var yuvFrame = getYuvFrame(
          frame.data,
          frame.width,
          frame.height,
          frame.displayWidth,
          frame.displayHeight
        )
        var yuvCanvas$1 = yuvCanvasMap[canvasKey]
        if (yuvCanvas$1) {
          yuvCanvas$1.drawFrame(yuvFrame)
        }
      }
    },
    false
  )

  var src = {}

  exports['default'] = src

  Object.defineProperty(exports, '__esModule', { value: true })
})
