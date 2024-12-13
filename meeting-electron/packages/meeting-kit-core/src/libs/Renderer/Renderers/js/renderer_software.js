"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// eslint-disable-next-line @typescript-eslint/no-var-requires
var YUVBuffer = require('yuv-buffer');
// eslint-disable-next-line @typescript-eslint/no-var-requires
var YUVCanvas = require('yuv-canvas');
var SoftwareRenderer = /** @class */ (function () {
    function SoftwareRenderer(canvas) {
        this.isInit = false;
        this.frameSink = YUVCanvas.attach(canvas, {
            webGL: false,
        });
        this.isInit = true;
    }
    SoftwareRenderer.prototype.drawFrame = function (videoFrame) {
        if (!this.frameSink)
            return;
        var width = videoFrame.width, height = videoFrame.height, yStride = videoFrame.yStride, uStride = videoFrame.uStride, vStride = videoFrame.vStride, yBuffer = videoFrame.yBuffer, uBuffer = videoFrame.uBuffer, vBuffer = videoFrame.vBuffer;
        this.frameSink.drawFrame(YUVBuffer.frame(YUVBuffer.format({
            width: width,
            height: height,
            chromaWidth: width / 2,
            chromaHeight: height / 2,
            cropLeft: yStride - width,
        }), {
            bytes: yBuffer,
            stride: yStride,
        }, {
            bytes: uBuffer,
            stride: uStride,
        }, {
            bytes: vBuffer,
            stride: vStride,
        }));
    };
    SoftwareRenderer.prototype.clear = function () {
        var _a;
        (_a = this.frameSink) === null || _a === void 0 ? void 0 : _a.clear();
    };
    SoftwareRenderer.prototype.destroy = function () {
        this.frameSink = undefined;
        this.isInit = false;
    };
    return SoftwareRenderer;
}());
exports.default = SoftwareRenderer;
