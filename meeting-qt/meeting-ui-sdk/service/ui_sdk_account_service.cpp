/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "service/ui_sdk_account_service.h"

#include "manager/auth_manager.h"

NEAccountServiceIMP::NEAccountServiceIMP()
{
}
NEAccountServiceIMP::~NEAccountServiceIMP()
{

}

void NEAccountServiceIMP::getPersonalMeetingId(const NEGetPersonalMeetingIdCallback& cb)
{
    if(cb != nullptr)
    {
        NEErrorCode error_code = NEErrorCode::ERROR_CODE_SUCCESS;
        std::string error_msg = NE_ERROR_MSG_SUCCESS;
        std::string personal_meeting_id("");
     auto auth_info =  AuthManager::getInstance()->getAuthInfo();
      if(auth_info != nullptr)
      {
          personal_meeting_id = auth_info->getPersonalMeetingId();
      }
      else
      {
          error_code = ERROR_CODE_FAILED;
          error_msg = "Not logged in";
      }
      cb(error_code,error_msg,personal_meeting_id);
    }
}
