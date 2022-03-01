/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef LOGINSTANCE_H
#define LOGINSTANCE_H

#include <mutex>

class LogInstance
{
public:
    LogInstance(char* argv[]);
    static LogInstance* getInstance() {
        static std::mutex mutex;
        if (!m_instance) {
            std::lock_guard<std::mutex> locker(mutex);
            if (!m_instance) {
                m_instance = new LogInstance();
            }
        }
        return m_instance;
    }
    ~LogInstance();

private:
    LogInstance();
    void configureGoogleLog();
    static void messageHandler(QtMsgType, const QMessageLogContext &, const QString &);

private:
    static LogInstance* m_instance;
};

#endif // LOGINSTANCE_H
