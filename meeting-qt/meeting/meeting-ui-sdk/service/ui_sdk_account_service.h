// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_UI_SDK_SERVICE_ACCOUNT_SERVICE_H_
#define MEETING_UI_SDK_SERVICE_ACCOUNT_SERVICE_H_

USING_NS_NNEM_SDK_INTERFACE

class NEM_SDK_INTERFACE_EXPORT NEAccountServiceIMP : public NEAccountService {
public:
    NEAccountServiceIMP();
    ~NEAccountServiceIMP();

public:
    void getPersonalMeetingId(const NEGetPersonalMeetingIdCallback& cb) override;
    void getPersonalMeetingNumber(const NEGetPersonalMeetingIdCallback& cb) override;
};

#endif  // MEETING_UI_SDK_SERVICE_ACCOUNT_SERVICE_H_
