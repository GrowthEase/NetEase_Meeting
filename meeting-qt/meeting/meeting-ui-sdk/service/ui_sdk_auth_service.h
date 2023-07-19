// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_UI_SDK_SERVICE_AUTH_SERVICE_H_
#define MEETING_UI_SDK_SERVICE_AUTH_SERVICE_H_

USING_NS_NNEM_SDK_INTERFACE

class NEM_SDK_INTERFACE_EXPORT NEAuthServiceIMP : public NEAuthService {
public:
    NEAuthServiceIMP();
    ~NEAuthServiceIMP();

public:
    virtual void login(const std::string& account, const std::string& token, const NEAuthLoginCallback& cb) override;
    virtual void logout(const NEAuthLoginCallback& cb) override;
};
#endif  // MEETING_UI_SDK_SERVICE_MEETING_SERVICE_H_
