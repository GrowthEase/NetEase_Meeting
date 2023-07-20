#pragma once
// Dynamic library
//#define NEPLauncher_EXPORT
// Static Library
#define NEPLauncher_STATIC

#ifdef NEPLauncher_STATIC
#define NEPLauncher_API
#elif defined NEPLauncher_EXPORT
#define NEPLauncher_API __declspec(dllexport)
#else
#define NEPLauncher_API
#endif

#ifdef __cplusplus
extern "C" {
#endif

/// <summary>
/// 透传回调函数，由游戏方实现
/// <param name="data">需要透传的数据</param>
/// <param name="len">数据长度</param>
/// <param name="type">服务类型：8 - 初始化配置、策略透传；16 - 嫌疑数据透传</param>
/// </summary>
typedef bool(__stdcall* TRANSCALLBACK)(LPCSTR msg, uint64_t len, int serviceType);

/// <summary>
/// 初始化接口
/// </summary>
/// <param name="szProductId">易盾分配的productId，可登录易盾后台获取</param>
/// <param name="pCallBack">用于数据透传的回调函数，默认为空</param>
/// <returns></returns>
NEPLauncher_API bool NEP_Init(LPCWSTR szProductId, TRANSCALLBACK callback = NULL);

/// <summary>
/// 登录接口，设置账号信息
/// </summary>
/// <param name="szBusinessId">业务 ID，必填</param>
/// <param name="szAccount">玩家账号，必填</param>
/// <param name="szRoleId"> 角色 ID，必填</param>
/// <param name="szRoleName">角色名称</param>
/// <param name="nServerId">服务器 ID</param>
/// <param name="szServerName">服务器名称</param>
/// <param name="nRoleLevel">角色等级</param>
/// <param name="nState"> 仅记录账号(0) 角色登录(1) 登出(2)</param>
/// <param name="szGameJson">用户需要上传的额外信息，对应一个 json 字符串</param>
/// <returns></returns>
NEPLauncher_API bool NEP_SetRoleInfo(LPCWSTR szBusinessId,
                                     LPCWSTR szAccount,
                                     LPCWSTR szRoleId,
                                     LPCWSTR szRoleName,
                                     INT nServerId,
                                     LPCWSTR szServerName,
                                     INT nRoleLevel,
                                     INT nState = 1,
                                     LPCSTR szGameJson = NULL);

/// <summary>
/// 交互接口
/// </summary>
/// <param name="buffer">要传递给 SDK 的数据</param>
/// <param name="len">数据长度</param>
/// <param name="serviceType">服务类型：8 - 初始化配置、策略透传；16 - 嫌疑数据透传</param>
/// <returns></returns>
NEPLauncher_API bool NEP_Ioctl(LPCSTR buffer, uint64_t len, int serviceType);

/// <summary>
/// 反外挂状态（NEPStatusCallback
/// </summary>
enum NEPSTATUS {
    eNEP_Status_Normal = 0,                // everything OK
    eNEP_Status_NotLoaded = 1,             // NEP2.dll 未加载
    eNEP_Status_FileNotFount = 2,          // NEP2.dll 文件未找到
    eNEP_Status_FileModified = 4,          // NEP2.dll 被修改
    eNEP_Status_Suspended = 8,             // 反外挂线程被暂停
    eNEP_Status_TiggerEvent = 16,          // 反外挂功能异常
    eNEP_Status_InternalWardenError = 32,  // 内部校验错误
    eNEP_Status_NetworkError = 64,         // 网络请求失败
};

/// <summary>
/// NEP_InstallStatusChecker 安装状态
/// </summary>
enum INSTALLRESULT { SUCCESS_INSTALLED = 0, FAIL_CALLBACK_INVALID = 1, FAIL_INTERVAL_INVALID = 2, FAIL_UNEXPECTED = 4 };

typedef bool(_stdcall* NEPStatusCallback)(NEPSTATUS statusCode);

/// <summary>
/// 安装异常（异步）状态检查
/// </summary>
/// <param name="callback">状态校验回调函数，用于接收检测状态码并做后续处理</param>
/// <param name="intervalSeconds">校验间隔，单位为秒，范围为(20, 3600)，间隔时间后开始第一次校验</param>
/// <param name="isCallbackOnlyAbnormal">true: 仅在检测到异常时回调  false: 完成一轮检测即调用</param>
/// <returns></returns>
NEPLauncher_API INSTALLRESULT NEP_InstallStatusChecker(NEPStatusCallback callback, ULONG intervalSeconds = 60, bool isCallbackOnlyAbnormal = true);

/// <summary>
/// 停止状态检查
/// </summary>
NEPLauncher_API void NEP_UninstallStatusChecker();

/// <summary>
/// 立即获取反外挂状态
/// </summary>
/// <returns>0-status ok, others means status abnormal</returns>
NEPLauncher_API NEPSTATUS NEP_GetSecurityStatus();

#ifdef __cplusplus
}
#endif
