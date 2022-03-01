/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "service/ui_sdk_auth_service.h"
#include "utils/string_converter.h"
#include "manager/auth_manager.h"


NEAuthServiceIMP::NEAuthServiceIMP()
{
}
NEAuthServiceIMP::~NEAuthServiceIMP()
{

}

void NEAuthServiceIMP::login(const std::string& account, const std::string& token, const NEAuthLoginCallback& cb)
{
    LoginParam login_param;
    auto auth_info =  AuthManager::getInstance()->getAuthInfo();
    if(auth_info != nullptr)
        login_param.app_key_ = auth_info->getAppKey();
    login_param.accountId_ = account;
    login_param.account_token_ = token;
    if(!AuthManager::getInstance()->doLogin(login_param,[cb](LoginResult login_status, const AccountInfoPtr& login_info){
        if(cb != nullptr)
        {
            NEErrorCode err_code = NEErrorCode::ERROR_CODE_FAILED;
            std::string err_msg = "FAILED";
            if(login_status == kLoginSuccess)
            {
                err_code = NEErrorCode::ERROR_CODE_SUCCESS;
                err_msg = NE_ERROR_MSG_SUCCESS;
            }
            cb(err_code,err_msg);
        }
    }) && cb != nullptr)
    cb(NEErrorCode::ERROR_CODE_FAILED,"Logging or logged");
}
void NEAuthServiceIMP::logout(const NEAuthLoginCallback& cb)
{
    AuthManager::getInstance()->doLogout([cb](NEMErrorCode err){
        NEErrorCode err_code = NEErrorCode::ERROR_CODE_FAILED;
        std::string err_msg = "FAILED";
        if(err == kNEMNoError)
        {
            err_code = NEErrorCode::ERROR_CODE_SUCCESS;
            err_msg = NE_ERROR_MSG_SUCCESS;
        }
        cb(err_code,err_msg);
    });
}

