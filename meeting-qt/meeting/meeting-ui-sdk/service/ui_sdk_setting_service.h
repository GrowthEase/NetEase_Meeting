// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_UI_SDK_SERVICE_SETTING_SERVICE_H_
#define MEETING_UI_SDK_SERVICE_SETTING_SERVICE_H_

USING_NS_NNEM_SDK_INTERFACE

class NEM_SDK_INTERFACE_EXPORT NESettingsServiceIMP : public NESettingsService {
public:
    NESettingsServiceIMP();
    ~NESettingsServiceIMP();

public:
    virtual NEVideoController* GetVideoController() const override;

    virtual NEAudioController* GetAudioController() const override;

    virtual void showSettingUIWnd(const NESettingsUIWndConfig& config, const NEShowSettingUIWndCallback& cb) override;

private:
    std::unique_ptr<NEVideoController> video_controller_;
    std::unique_ptr<NEAudioController> audio_controller_;
};

#endif  // MEETING_UI_SDK_SERVICE_SETTING_SERVICE_H_
