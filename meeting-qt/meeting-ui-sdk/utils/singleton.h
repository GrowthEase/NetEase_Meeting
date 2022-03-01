/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef SINGLETON_H
#define SINGLETON_H

#include <memory>
#include <mutex>
#include <QMutex>
#include <QScopedPointer>

namespace utils
{

template <typename T>
class Singleton {
public:
    static T* getInstance();

    Singleton(const Singleton &other) = delete;
    Singleton<T>& operator=(const Singleton &other) = delete;

private:
    static std::mutex mutex;
    static T* instance;
};

template <typename T> std::mutex Singleton<T>::mutex;
template <typename T> T* Singleton<T>::instance;
template <typename T>
T* Singleton<T>::getInstance() {
    if (instance == nullptr) {
        std::lock_guard<std::mutex> locker(mutex);
        if (instance == nullptr) {
            instance = new T();
        }
    }
    return instance;
}

#define SINGLETONG(Class)                               \
private:                                                \
    friend class  utils::Singleton<Class>;              \
    friend struct QScopedPointerDeleter<Class>;         \
public:                                                 \
    static Class* getInstance() {                       \
        return utils::Singleton<Class>::getInstance();  \
    }

#define HIDE_CONSTRUCTOR(Class)                         \
private:                                                \
    Class() = default;                                  \
    Class(const Class &other) = delete;                 \
    Class& operator=(const Class &other) = delete;      \

}

#endif // SINGLETON_H
