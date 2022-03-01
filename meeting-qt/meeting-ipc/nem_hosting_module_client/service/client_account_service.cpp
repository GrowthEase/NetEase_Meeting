/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_client/service/client_account_service.h"
#include "nem_hosting_module_protocol/protocol/account_protocol.h"

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

NEAccountServiceIMP::NEAccountServiceIMP() : IService(ServiceID::SID_Account)
{
}
NEAccountServiceIMP::~NEAccountServiceIMP()
{

}

void NEAccountServiceIMP::getPersonalMeetingId(const NEGetPersonalMeetingIdCallback& cb)
{
	if (_ProcHandler() != nullptr)
		_ProcHandler()->onGetPersonalMeetingId(cb);
}

void NEAccountServiceIMP::OnLoad()
{

}

void NEAccountServiceIMP::OnRelease()
{

}

void NEAccountServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn)
{
    switch (cid)
    {
	case AccountCID::AccountCID_QueryPersonalMeetingId:
	{
		QueryPersonalMeetingIdRequest request;
		if (request.Parse(data))
		{
			getPersonalMeetingId(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const std::string& meeting_id) {
				QueryPersonalMeetingIdResponse response;
				response.error_code_ = error_code;
				response.error_msg_ = error_msg;
				response.personal_meeting_id_ = meeting_id;
				SendData(AccountCID::AccountCID_QueryPersonalMeetingId_CB, response, sn);
			}));
		}
	}
	break;
    }
}
NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS