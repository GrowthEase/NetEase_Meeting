/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "service/ui_sdk_setting_service.h"
#include "manager/global_manager.h"

class NEVideoControllerIMP : public NEVideoController
{

};
class NEAudioControllerIMP : public NEAudioController
{

};

NESettingsServiceIMP::NESettingsServiceIMP() :
	video_controller_(new NEVideoControllerIMP()),
	audio_controller_(new NEAudioControllerIMP())
{
}
NESettingsServiceIMP::~NESettingsServiceIMP()
{

}
NEVideoController* NESettingsServiceIMP::GetVideoController() const
{
	return video_controller_.get();
}
NEAudioController* NESettingsServiceIMP::GetAudioController() const
{
	return audio_controller_.get();
}
void NESettingsServiceIMP::showSettingUIWnd(const NESettingsUIWndConfig& config, const NEShowSettingUIWndCallback& cb)
{
    GlobalManager::getInstance()->showSettingsWnd();
    if(cb != nullptr)
    {
        NEErrorCode err_code = NEErrorCode::ERROR_CODE_SUCCESS;
        std::string err_msg = NE_ERROR_MSG_SUCCESS;
          cb(err_code,err_msg);
    }
}

