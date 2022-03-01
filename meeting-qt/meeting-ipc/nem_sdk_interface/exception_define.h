/**
 * @file exception_define.h
 * @brief 异常头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_DEFINE_EXCEPTION_DEFINE_H_
#define NEM_SDK_INTERFACE_DEFINE_EXCEPTION_DEFINE_H_

#include "nemeeting_sdk_interface_export.h"
#include "build_config.h"

#include "exception.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 异常信息
 */
class NEM_SDK_INTERFACE_EXPORT NEException : public NEObject
{
public:
    /**
     * @brief 构造函数
     */
    NEException() :
        exception_code_(NEExceptionCode::kUnknown), exception_message_("") {
    }

    /**
     * @brief 构造函数
     * @param error 异常码
     * @param message 异常描述
     */
    NEException(NEExceptionCode error, const std::string& message) :
        exception_code_(error), exception_message_(message) {
    }

    /**
     * @brief 获取异常码
     * @return NEExceptionCode 异常码
     */
    NEExceptionCode ExceptionCode() const {
        return exception_code_;
    }

    /**
     * @brief 设置异常码
     * @param code 异常码
     * @return void
     */
    void ExceptionCode(NEExceptionCode code) {
        exception_code_ = code;
    }

    /**
     * @brief 获取异常描述
     * @return std::strin 异常描述
     */
    std::string ExceptionMessage() const {
        return exception_message_;
    }

   /**
    * @brief 设置异常描述
    * @param msg 异常描述
    * @return void
    */
    void ExceptionMessage(const std::string& msg) {
        exception_message_ = msg;
    }
private:
    NEExceptionCode exception_code_;    /**< 异常码 */
    std::string exception_message_;     /**< 异常描述 */
};

NNEM_SDK_INTERFACE_END_DECLS

#endif //NEM_SDK_INTERFACE_DEFINE_EXCEPTION_DEFINE_H_