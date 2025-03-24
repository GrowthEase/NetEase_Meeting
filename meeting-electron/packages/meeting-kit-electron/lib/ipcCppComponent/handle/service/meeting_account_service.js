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
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
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
var neroom_types_1 = require("neroom-types");
var NEMeetingAccountServiceHandle = /** @class */ (function () {
    function NEMeetingAccountServiceHandle(meetingAccountService, listenerInvokeCallback) {
        var _this = this;
        this._accountService = meetingAccountService;
        this._listenerInvokeCallback = listenerInvokeCallback;
        this._accountService.addListener({
            onKickOut: function () {
                _this._listenerInvokeCallback(1, 101, '{}', 0);
            },
            onAuthInfoExpired: function () {
                _this._listenerInvokeCallback(1, 102, '{}', 0);
            },
            onReconnected: function () {
                _this._listenerInvokeCallback(1, 103, '{}', 0);
            },
            onAccountInfoUpdated: function (accountInfo) {
                _this._listenerInvokeCallback(1, 104, JSON.stringify({
                    accountInfo: accountInfo,
                }), 0);
            },
        });
    }
    NEMeetingAccountServiceHandle.prototype.onMethodHandle = function (cid, data) {
        return __awaiter(this, void 0, Promise, function () {
            var res, _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = cid;
                        switch (_a) {
                            case 1: return [3 /*break*/, 1];
                            case 3: return [3 /*break*/, 3];
                            case 5: return [3 /*break*/, 5];
                            case 7: return [3 /*break*/, 7];
                            case 9: return [3 /*break*/, 9];
                            case 11: return [3 /*break*/, 11];
                            case 13: return [3 /*break*/, 13];
                            case 15: return [3 /*break*/, 15];
                            case 17: return [3 /*break*/, 17];
                            case 19: return [3 /*break*/, 19];
                            case 21: return [3 /*break*/, 21];
                            case 27: return [3 /*break*/, 23];
                            case 29: return [3 /*break*/, 25];
                            case 31: return [3 /*break*/, 27];
                            case 33: return [3 /*break*/, 29];
                        }
                        return [3 /*break*/, 31];
                    case 1: return [4 /*yield*/, this.tryAutoLogin()];
                    case 2:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 3: return [4 /*yield*/, this.loginByToken(data)];
                    case 4:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 5: return [4 /*yield*/, this.loginByPassword(data)];
                    case 6:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 7: return [4 /*yield*/, this.requestSmsCodeForLogin(data)];
                    case 8:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 9: return [4 /*yield*/, this.requestSmsCodeForGuest(data)];
                    case 10:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 11: return [4 /*yield*/, this.loginBySmsCode(data)];
                    case 12:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 13: return [4 /*yield*/, this.generateSSOLoginWebURL(data)];
                    case 14:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 15: return [4 /*yield*/, this.loginBySSOUri(data)];
                    case 16:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 17: return [4 /*yield*/, this.loginByEmail(data)];
                    case 18:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 19: return [4 /*yield*/, this.loginByPhoneNumber(data)];
                    case 20:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 21: return [4 /*yield*/, this.getAccountInfo()];
                    case 22:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 23: return [4 /*yield*/, this.resetPassword(data)];
                    case 24:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 25: return [4 /*yield*/, this.updateAvatar(data)];
                    case 26:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 27: return [4 /*yield*/, this.updateNickname(data)];
                    case 28:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 29: return [4 /*yield*/, this.logout()];
                    case 30:
                        res = _b.sent();
                        return [3 /*break*/, 32];
                    case 31: return [2 /*return*/, JSON.stringify((0, neroom_types_1.FailureBodySync)(undefined, 'method not found'))];
                    case 32: return [2 /*return*/, JSON.stringify(res)];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.tryAutoLogin = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._accountService.tryAutoLogin()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.loginByToken = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, userUuid, token;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), userUuid = _a.userUuid, token = _a.token;
                        return [4 /*yield*/, this._accountService.loginByToken(userUuid, token)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.loginByPassword = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, userUuid, password;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), userUuid = _a.userUuid, password = _a.password;
                        return [4 /*yield*/, this._accountService.loginByPassword(userUuid, password)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.requestSmsCodeForLogin = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var phoneNumber;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        phoneNumber = JSON.parse(data).phoneNumber;
                        return [4 /*yield*/, this._accountService.requestSmsCodeForLogin(phoneNumber)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.requestSmsCodeForGuest = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var phoneNumber;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        phoneNumber = JSON.parse(data).phoneNumber;
                        return [4 /*yield*/, this._accountService.requestSmsCodeForGuest(phoneNumber)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.loginBySmsCode = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, phoneNumber, smsCode;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), phoneNumber = _a.phoneNumber, smsCode = _a.smsCode;
                        return [4 /*yield*/, this._accountService.loginBySmsCode(phoneNumber, smsCode)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.generateSSOLoginWebURL = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var schemaUrl;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        schemaUrl = JSON.parse(data).schemaUrl;
                        return [4 /*yield*/, this._accountService.generateSSOLoginWebURL(schemaUrl)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.loginBySSOUri = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var ssoUri;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        ssoUri = JSON.parse(data).ssoUri;
                        return [4 /*yield*/, this._accountService.loginBySSOUri(ssoUri)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.loginByEmail = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, email, password;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), email = _a.email, password = _a.password;
                        return [4 /*yield*/, this._accountService.loginByEmail(email, password)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.loginByPhoneNumber = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, phoneNumber, password;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), phoneNumber = _a.phoneNumber, password = _a.password;
                        return [4 /*yield*/, this._accountService.loginByPhoneNumber(phoneNumber, password)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.getAccountInfo = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._accountService.getAccountInfo()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.resetPassword = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var _a, userUuid, newPassword, oldPassword;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = JSON.parse(data), userUuid = _a.userUuid, newPassword = _a.newPassword, oldPassword = _a.oldPassword;
                        return [4 /*yield*/, this._accountService.resetPassword(userUuid, newPassword, oldPassword)];
                    case 1: return [2 /*return*/, _b.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.updateAvatar = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var imagePath;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        imagePath = JSON.parse(data).imagePath;
                        return [4 /*yield*/, this._accountService.updateAvatar(imagePath)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.updateNickname = function (data) {
        return __awaiter(this, void 0, void 0, function () {
            var nickname;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        nickname = JSON.parse(data).nickname;
                        return [4 /*yield*/, this._accountService.updateNickname(nickname)];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    NEMeetingAccountServiceHandle.prototype.logout = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._accountService.logout()];
                    case 1: return [2 /*return*/, _a.sent()];
                }
            });
        });
    };
    return NEMeetingAccountServiceHandle;
}());
exports.default = NEMeetingAccountServiceHandle;