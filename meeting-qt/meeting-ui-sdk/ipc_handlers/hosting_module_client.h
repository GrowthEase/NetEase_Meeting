/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_APP_MANAGER_HOSTING_MODULE_CLIENT_H_
#define NEM_SDK_INTERFACE_APP_MANAGER_HOSTING_MODULE_CLIENT_H_

#include <QObject>
#include <memory>

#include "client_nemeeting_sdk_interface_include.h"

#include "account_prochandler.h"
#include "auth_prochandler.h"
#include "feedback_prochandler.h"
#include "meeting_prochandler.h"
#include "meeting_sdk_prochandler.h"
#include "premeeting_prochandler.h"
#include "setting_prochandler.h"

USING_NS_NNEM_SDK_INTERFACE

class NEAccountProcHandlerIMP;
class NEAuthServiceProcHandlerIMP;
class NEMeetingServiceProcHandlerIMP;
class NEMeetingSDKProcHandlerIMP;
class NESettingsServiceProcHandlerIMP;
class NEFeedbackServiceProcHandlerIMP;
class NEPreMeetingServiceProcHandlerIMP;

class HostingModuleClient : public QObject {
    Q_OBJECT
public:
    HostingModuleClient(QObject* parent = nullptr);
    ~HostingModuleClient();
    static void setBugList(const char* argv);

public:
    bool InitLocalEnviroment(int port);
    void OnInitLocalEnviroment(bool success);
    NEMeetingSDKConfig getSDKConfig() const;
    void Uninit();
    void WriteLog(const QString& strLog);

private:
    void onException(const NEException& exception);

private:
    std::unique_ptr<NEAccountProcHandlerIMP> account_proc_handler_;
    std::unique_ptr<NEAuthServiceProcHandlerIMP> auth_service_proc_handler_;
    std::unique_ptr<NEMeetingServiceProcHandlerIMP> meeting_service_proc_handler_;
    std::unique_ptr<NEMeetingSDKProcHandlerIMP> meeting_sdk_proc_handler_;
    std::unique_ptr<NESettingsServiceProcHandlerIMP> setting_service_proc_handler_;
    std::unique_ptr<NEFeedbackServiceProcHandlerIMP> feedback_service_proc_handler_;
    std::unique_ptr<NEPreMeetingServiceProcHandlerIMP> premeeting_service_proc_handler_;
    QString m_strLogPath;
};
#endif
