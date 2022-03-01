/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEMEETINGINSTANCE_H
#define NEMEETINGINSTANCE_H

USING_NS_NNEM_SDK_INTERFACE

class NEMeetingInstance: public NEMeetingSDK,public std::enable_shared_from_this<NEMeetingInstance>
{
    friend NEMeetingSDK* NEMeetingSDK::getInstance();
public:
    NEMeetingInstance();
public:
    virtual void initialize(const NEMeetingSDKConfig& config, const NEInitializeCallback& cb) override;
    virtual void initializeWithQt(const NEMeetingSDKConfig& config, const NEInitializeCallback& cb, void* app) override;
    virtual void unInitialize(const NEUnInitializeCallback& cb) override;
    virtual void querySDKVersion(const NEQuerySDKVersionCallback& cb) override;

    virtual NEAuthService* getAuthService() override;;
    virtual NEMeetingService* getMeetingService() override;
    virtual NESettingsService* getSettingsService() override;
    virtual NEAccountService* getAccountService() override;
private:
    bool doInitialize(const NEMeetingSDKConfig& config);
    bool doUnInitialize();
    void qmlRegisterTypeStep1();

private:
    static std::shared_ptr<NEMeetingInstance> meeting_instance_;
    static std::recursive_mutex         meeting_instance_mutex_;
    std::unique_ptr<NEAuthService>      auth_service_;
    std::unique_ptr<NEMeetingService>   meeting_service_;
    std::unique_ptr<NESettingsService>  settings_service_;
    std::unique_ptr<NEAccountService>   account_service_;
    std::thread*                        main_thread_;
    QGuiApplication*                    app_;
    bool                                init_with_qt_;
};

#endif // NEMEETINGINSTANCE_H
