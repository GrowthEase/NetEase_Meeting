/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef CLIENTUPDATOR_H
#define CLIENTUPDATOR_H
#include <QString>
#include <functional>
#include "base/http_manager.h"
class ClientUpdateInfo
{
public:
    int m_latestVersionCode;        // 最新版本号
    QString m_m_latestVersionName;  // 网易会议客户端最新版本名称
    int m_currentVersionCode;       // 当前版本号
    QString m_url;                  // 跳转外部下载地址, 此地址不能作为应用内更新下载使用
    QString m_download_url;         // 应用内更新链接
    QString m_description;          // 更新内容详细描述
    QString m_title;                // 更新内容提示
    int m_notify;                   // 本次更新是否提示用户，0：不提示，1：提示
    int m_forceVersionCode;         // 强制更新的版本码，小于等于此版本号应用需要强制更新
    QString m_checkCode;            // 安装包校验码
};
enum class UpdateType
{
    kBegin = 0,
    unknown,
    theLatestVersion,   // 已是最新版本不需要更新
    hasNewButNotifiless,// 存在新的版本但不必通知更新
    hasNewAndNotify,    // 存在新的版本但需要通知更新，但是不会强制
    hasNewAndForce,     // 存在新的版本但需要强制更新
    kEnd
};

class ClientUpdateInfoSerializer
{
public:
    static bool read(const QString& path,ClientUpdateInfo& info);
    static bool write(const QString& path,const ClientUpdateInfo& info);
};

class NEMeetingSDKManager;
//using CheckUpdateCallback = std::function<void(int code,const QString& msg,UpdateType type,const ClientUpdateInfo& updateInfo)>;
class ClientUpdater : public QObject
{
    Q_OBJECT
public:
    ClientUpdater(NEMeetingSDKManager* sdk, QObject* parent = nullptr);
    ~ClientUpdater() = default;

    Q_INVOKABLE void checkUpdate();
    Q_INVOKABLE int getCurrentVersion() const;
    Q_INVOKABLE int getLatestVersion() const;
    Q_INVOKABLE bool update();
    Q_INVOKABLE void stopUpdate();

    void lanchApp();

signals:
	/**
	* @brief checkUpdateSignal
	* 检查更新完成的信号
	* @param resultCode    返回结果代码
	* @param resultType    更新类型（无更新、有更新提示、有更新不提示、强制更新）
	* @param response      返回的内容
	*/
	void checkUpdateSignal(int resultCode, int resultType, const QJsonObject& response);

    // 下载进度，单位位MB
    void downloadProgressSignal(float fReceived, float fTotal);

    // 下载结果，失败的话，看response中的详细原因
    void downloadResultSignal(bool bSucc, const QJsonObject& response);

private:
    UpdateType doCheck(const ClientUpdateInfo& update_info) const;

private:
    QString m_updateInfoCatchFilePath;
	HttpManager*        m_httpManager;
    QFile* m_pFile = nullptr;
    NEMeetingSDKManager* m_pSDK = nullptr;
    int m_latestVersionCode = 0;
};

#endif // CLIENTUPDATOR_H
