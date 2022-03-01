/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef FeedbackManager_H
#define FeedbackManager_H

#include "utils/singleton.h"

class FeedbackManager : public QObject
{
    Q_OBJECT
private:
    FeedbackManager(QObject *parent = nullptr);

public:
    SINGLETONG(FeedbackManager)

public:
    bool initialize();
    void release();

    void Uploadsources(const int& type, const std::string& path, const NS_I_NEM_SDK::NEFeedbackService::NEFeedbackCallback& cb);


};

#endif // FeedbackManager_H
