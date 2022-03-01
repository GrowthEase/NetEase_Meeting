/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */


#ifndef NIPCLIB_BASE_ANY_H_
#define NIPCLIB_BASE_ANY_H_
#pragma warning( disable : 4503 ) // warning: decorated name length exceeded

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include <algorithm>
#include <typeinfo>

NIPCLIB_BEGIN_DECLS
class NIPCLIB_EXPORT any
{
public: // structors

    any()
        : content(0)
    {
    }

    template<typename ValueType>
    any(const ValueType & value)
        : content(new holder<ValueType>(value))
    {
    }

    any(const any & other)
        : content(other.content ? other.content->clone() : 0)
    {
    }

    ~any()
    {
        delete content;
    }

public: // modifiers

    any & swap(any & rhs)
    {
        std::swap(content, rhs.content);
        return *this;
    }

    template<typename ValueType>
    any & operator=(const ValueType & rhs)
    {
        any(rhs).swap(*this);
        return *this;
    }

    any & operator=(any rhs)
    {
        rhs.swap(*this);
        return *this;
    }

public: // queries

    bool empty() const
    {
        return !content;
    }

    const std::type_info & type() const
    {
        return content ? content->type() : typeid(void);
    }
private: // types
    class placeholder
    {
    public: // structors

        virtual ~placeholder()
        {
        }

    public: // queries

        virtual const std::type_info & type() const = 0;

        virtual placeholder * clone() const = 0;

    };

    template<typename ValueType>
    class holder : public placeholder
    {
    public: // structors

        holder(const ValueType & value)
            : held(value)
        {
        }

    public: // queries

        virtual const std::type_info & type() const
        {
            return typeid(ValueType);
        }

        virtual placeholder * clone() const
        {
            return new holder(held);
        }

    public: // representation

        ValueType held;

    private: // intentionally left unimplemented
        holder & operator=(const holder &);
    };

private: // representation

    template<typename ValueType>
    friend ValueType * any_cast(any *);

    template<typename ValueType>
    friend ValueType * unsafe_any_cast(any *);
    placeholder * content;

};

class bad_any_cast : public std::bad_cast
{
public:
    virtual const char * what() const throw()
    {
        return "boost::bad_any_cast: "
                "failed conversion using boost::any_cast";
    }
};

template<typename ValueType>
ValueType * any_cast(any * operand)
{
    return (operand && operand->type() == typeid(ValueType)) ? (&static_cast<any::holder<ValueType> *>(operand->content)->held) : (nullptr);
}

template<typename ValueType>
inline const ValueType * any_cast(const any * operand)
{
    return any_cast<ValueType>(const_cast<any *>(operand));
}

template<typename ValueType>
ValueType any_cast(any & operand)
{
    typedef typename std::remove_reference<ValueType>::type nonref;
    static_assert(!(std::is_reference<nonref>::value),"still right reference");
    nonref * result = any_cast<nonref>(&operand);
    if (!result)
    {
        throw(bad_any_cast());
    }
        
    return *result;
}

template<typename ValueType>
inline ValueType any_cast(const any & operand)
{
    typedef typename std::remove_reference<ValueType>::type nonref;
    static_assert(!std::is_reference<nonref>::value, "still right reference");
    return any_cast<const nonref &>(const_cast<any &>(operand));
}
template<typename ValueType>
inline ValueType * unsafe_any_cast(any * operand)
{
    return &static_cast<any::holder<ValueType> *>(operand->content)->held;
}

template<typename ValueType>
inline const ValueType * unsafe_any_cast(const any * operand)
{
    return unsafe_any_cast<ValueType>(const_cast<any *>(operand));
}
NIPCLIB_END_DECLS

#endif//NIPCLIB_BASE_ANY_H_
