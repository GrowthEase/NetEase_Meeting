/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module/service/account_service.h"
#include "nem_hosting_module_protocol/protocol/account_protocol.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

NEAccountServiceIMP::NEAccountServiceIMP() : IService(ServiceID::SID_Account)
{
}

NEAccountServiceIMP::~NEAccountServiceIMP()
{

}

void NEAccountServiceIMP::getPersonalMeetingId(const NEGetPersonalMeetingIdCallback& cb)
{
	PostTaskToProcThread(ToWeakCallback([this, cb]() {
		QueryPersonalMeetingIdRequest request;
		SendData(AccountCID::AccountCID_QueryPersonalMeetingId, request, IPCAsyncResponseCallback(cb));
	}));

}

void NEAccountServiceIMP::OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb)
{
	switch (cid)
	{
	case AccountCID::AccountCID_QueryPersonalMeetingId_CB:
	{
		QueryPersonalMeetingIdResponse response;
		if (!response.Parse(data))
		{
			response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
		}
		NEGetPersonalMeetingIdCallback query_cb = cb.GetResponseCallback<NEGetPersonalMeetingIdCallback>();
		if (query_cb != nullptr)
			query_cb(response.error_code_, response.error_msg_, response.personal_meeting_id_);
	}
	break;
	default:
		break;
	}
}

NNEM_SDK_HOSTING_MODULE_END_DECLS