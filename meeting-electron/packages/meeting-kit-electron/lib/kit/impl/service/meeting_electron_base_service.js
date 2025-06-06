"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var ElectronBaseService = /** @class */ (function () {
    function ElectronBaseService(_win) {
        this._win = _win;
    }
    ElectronBaseService.prototype.setWin = function (win) {
        this._win = win;
    };
    return ElectronBaseService;
}());
exports.default = ElectronBaseService;