/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/8
//
// This file defined Pack and Unpack class

#ifndef BASE_MEMORY_PACKET_H_
#define BASE_MEMORY_PACKET_H_

#include <string>
#include <iostream>
#include <stdexcept>
#include <map> // CARE
#include "base/base_export.h"
#include "base/base_types.h"
#include "base/error.h"
#include "base/macros.h"
#include "blockbuffer.h"

namespace nbase
{

// Varstr --------------------------------------------------------------------
struct Varstr
{
    const char *data_;
    size_t      size_;

    Varstr(const char *data = "", size_t size = 0) { set(data, size); }
    void set(const char *data, size_t size) { data_ = data; size_ = size; }
    bool empty() const { return size_ == 0; }

    const char * data() const { return data_; }
    size_t size() const       { return size_; }

    template <class T> // std::string cstr blockbuffer
    explicit Varstr(T & s)    { *this = s; }

    template <class T>
    Varstr& operator = (T & s)
	{
		data_ = s.data();
		size_ = s.size();
		return*this;
	}
};

inline std::ostream & operator << (std::ostream &os, const Varstr &vs)
{
	return os.write(vs.data(), std::streamsize(vs.size()));
}

// PackBuffer -----------------------------------------------------
class BASE_EXPORT PackBuffer
{
public:
      char * data()        { return bb.data(); }
      size_t size()  const { return bb.size(); }

      void resize(size_t n)
      {
		  if (bb.resize(n))
			  return;
		  throw NException("resize buffer overflow", kResultMemoryError);
	  }
      void append(const char *data, size_t size)
      {
		  if (bb.append(data, size))
			  return;
		  throw NException("append buffer overflow", kResultMemoryError);
      }
      void append(const char *data) { append(data, ::strlen(data)); }
      void replace(size_t pos, const char *rep, size_t n)
      {
          if (bb.replace(pos, rep, n))
              return;
          throw NException("replace buffer overflow", kResultMemoryError);
      }
      void reserve(size_t n)
      {
		  if (bb.reserve(n))
			  return;
		  throw NException("reserve buffer overflow", kResultMemoryError);
      }

private:
      // use big-block. more BIG? MAX 64K*16k = 1G
      typedef BlockBuffer<def_block_alloc_16k, 65536> BB;
      BB bb;
};


// to reverse byte order
inline uint16_t XREVS(uint16_t i16)
{
    return ((i16 << 8) | (i16 >> 8));
}
inline uint32_t XREVL(uint32_t i32)
{
    return ((uint32_t(XREVS(i32)) << 16) | XREVS(i32>>16));
}
inline uint64_t XREVLL(uint64_t i64)
{
    return ((uint64_t(XREVL((uint32_t)i64)) << 32) | XREVL((uint32_t(i64>>32))));
}

// defualt : to little endian
#if defined(NETEASE_LITTLE_ENDIAN)

// to little endian
#define     HTOLES
#define     HTOLEL
#define     HTOLELL

// to big endian
#define     HTOBES      XREVS
#define     HTOBEL      XREVL
#define     HTOBELL     XREVLL

#else /* big end */

inline uint16_t XHTONS(uint16_t i16)
{     
    return ((i16 << 8) | (i16 >> 8));
}
inline uint32_t XHTONL(uint32_t i32)
{
    return ((uint32_t(XHTONS(i32)) << 16) | XHTONS(i32>>16));
}
inline uint64_t XHTONLL(uint64_t i64)
{
    return ((uint64_t(XHTONL((uint32_t)i64)) << 32) | XHTONL((uint32_t(i64>>32))));
}

// to little endian
#define     HTOLES      XREVS
#define     HTOLEL      XREVL
#define     HTOLELL     XREVLL

// to big endian
#define     HTOBES
#define     HTOBEL
#define     HTOBELL

#endif /* BIG_ENDIAN */

#define     XNTOHS      XHTONS
#define     XNTOHL      XHTONL
#define     XNTOHLL     XHTONLL

#define     LETOHS      HTOLES
#define     LETOHL      HTOLEL
#define     LETOHLL     HTOLELL

#define     BETOHS      HTOBES
#define     BETOHL      HTOBEL
#define     BETOHLL     HTOBELL


// Pack ---------------------------------------------------------
class BASE_EXPORT Pack
{
public:
      uint16_t xhtons(uint16_t i16)  { return byte_order_ ? HTOBES(i16)  : HTOLES(i16);  }
      uint32_t xhtonl(uint32_t i32)  { return byte_order_ ? HTOBEL(i32)  : HTOLEL(i32);  }
      uint64_t xhtonll(uint64_t i64) { return byte_order_ ? HTOBELL(i64) : HTOLELL(i64); }

      // IMPORTANT remember the buffer-size before pack. see data(), size()
      // reserve a space to replace packet header after pack parameter
      // sample below: OffPack. see data(), size()
      Pack(PackBuffer &pb, size_t off = 0, int bo = 0) : buffer_(pb), byte_order_(bo)
      {
		  offset_ = pb.size() + off;
		  buffer_.resize(offset_);
      }

      // access this packet.
      char * data()       { return buffer_.data() + offset_; }
      size_t size() const { return buffer_.size() - offset_; }

      Pack & push(const void *s, size_t n) { buffer_.append((const char *)s, n); return *this; }
      Pack & push(const void *s)           { buffer_.append((const char *)s); return *this; }
	  
	  Pack & push_bool(bool b)         { uint8_t u8 = (b?1:0); return push(&u8, 1); }
      Pack & push_uint8(uint8_t u8)    { return push(&u8, 1); }
      Pack & push_uint16(uint16_t u16) { u16 = xhtons(u16); return push(&u16, 2); }
      Pack & push_uint32(uint32_t u32) { u32 = xhtonl(u32); return push(&u32, 4); }
      Pack & push_uint64(uint64_t u64) { u64 = xhtonll(u64); return push(&u64, 8); }
      Pack & push_varstr_as_uint64(const std::string &s) 
	  {
#if defined(COMPILER_MSVC)
		  return s.empty() ? push_uint64(0) : push_uint64(_atoi64(s.c_str())); 
#else
		  return s.empty() ? push_uint64(0) : push_uint64(atoll(s.c_str())); 
#endif  
	  }

      Pack & push_varstr(const Varstr &vs)      { return push_varstr(vs.data(), vs.size()); }
      Pack & push_varstr(const void *s)         { return push_varstr(s, strlen((const char *)s)); }
      Pack & push_varstr(const std::string &s)  { return push_varstr(s.data(), s.size()); }
      Pack & push_varstr(const void *s, size_t len)
      {
		  if (len > 0xFFFF)
			  throw NException("push_varstr: varstr too big", kResultMemoryError);
		  return push_uint16(uint16_t(len)).push(s, len);
	  }
      Pack & push_varstr32(const void *s, size_t len)
      {
		  if (len > 0xFFFFFFFF)
			  throw NException("push_varstr32: varstr too big", kResultMemoryError);
		  return push_uint32(uint32_t(len)).push(s, len);
      }

      virtual ~Pack() {}

protected:
      // replace. pos is the buffer offset, not this Pack m_offset
      size_t replace(size_t pos, const void *data, size_t rplen)
	  {
		  buffer_.replace(pos, (const char*)data, rplen);
		  return pos + rplen;
	  }
      size_t replace_uint8(size_t pos, uint8_t u8)    { return replace(pos, &u8, 1); }
      size_t replace_uint16(size_t pos, uint16_t u16)
	  {
		  u16 = xhtons(u16);
		  return replace(pos, &u16, 2);
	  }
      size_t replace_uint32(size_t pos, uint32_t u32)
	  {
		  u32 = xhtonl(u32);
		  return replace(pos, &u32, 4);
	  }

      PackBuffer &buffer_;
      size_t      offset_;

private:
	Pack (const Pack &o);
	Pack & operator = (const Pack &o);

	int           byte_order_;      //    net byte order:
	                                //    0 : le; 1 : be;
};

/* sample
struct OffPack : public Pack
{
      enum { BYTES = 12 };
      OffPack(PackBuffer &pb) : Pack(pb, BYTES)
      {
      }
      void endpack()
      {
        //assert(m_offset >= BYTES);
        m_offset -= BYTES;

        // use relace method to fill the reserve space
        size_t rppos = m_offset; // beginning of the reserve-space
        rppos = replace_uint32(rppos, 1); // 4 bytes
        rppos = replace(rppos, "123456", 6); // 6 bytes
        rppos = relpace_uint16(rppos, 2); // 2 bytes
    }
};
*/

class BASE_EXPORT Unpack
{
public:
      uint16_t xntohs(uint16_t i16) const  { return byte_order_ ? BETOHS(i16)  : LETOHS(i16);  }
      uint32_t xntohl(uint32_t i32) const  { return byte_order_ ? BETOHL(i32)  : LETOHL(i32);  }
      uint64_t xntohll(uint64_t i64) const { return byte_order_ ? BETOHLL(i64) : LETOHLL(i64); }

      Unpack(const void *data, size_t size, int bo = 0) 
		  : byte_order_(bo)
      {
          reset(data, size);
      }
      void reset(const void *data, size_t size) const
      {
		  data_ = (const char *)data;
		  size_ = size;
      }

      virtual ~Unpack() { data_ = NULL;  }

      operator const void *() const { return data_; }
      bool operator!() const  { return (NULL == data_); }

      std::string pop_varstr() const
      {
            Varstr vs = pop_varstr_ptr();
            return std::string(vs.data(), vs.size());
      }

      std::string pop_varstr32() const
      {
            Varstr vs = pop_varstr32_ptr();
            return std::string(vs.data(), vs.size());
      }

      std::string pop_fetch(size_t k) const
      {
            return std::string(pop_fetch_ptr(k), k);
      }

      void finish() const
      {
          if (!empty())
			  throw NException("finish: too much data", kResultMemoryError);
      }

	  bool pop_bool() const
	  {
		  if (size_ < 1u)
			  throw NException("pop_uint8: not enough data", kResultMemoryError);

		  uint8_t i8 = *((uint8_t *)data_);
		  data_ += 1u;
		  size_ -= 1u;
		  if (i8 > 0)
			  return true;
		  else
		      return false;
	  }

      uint8_t pop_uint8() const
      {
		  if (size_ < 1u)
			  throw NException("pop_uint8: not enough data", kResultMemoryError);

		  uint8_t i8 = *((uint8_t *)data_);
		  data_ += 1u;
		  size_ -= 1u;
		  return i8;
	  }

      uint16_t pop_uint16() const
      {
		  if (size_ < 2u)
			  throw NException("pop_uint16: not enough data", kResultMemoryError);

		  uint16_t i16 = *((uint16_t *)data_);
		  i16 = xntohs(i16);

		  data_ += 2u;
		  size_ -= 2u;
		  return i16;
      }

      uint32_t pop_uint32() const
      {
		  if (size_ < 4u)
			  throw NException("pop_uint32: not enough data", kResultMemoryError);
		  uint32_t i32 = *((uint32_t *)data_);
		  i32 = xntohl(i32);
		  data_ += 4u;
		  size_ -= 4u;
		  return i32;
      }

      uint64_t pop_uint64() const
      {
		  if (size_ < 8u)
			  throw NException("pop_uint64: not enough data", kResultMemoryError);
		  uint64_t i64 = 0;
          memcpy(&i64,data_,sizeof(i64));
		  i64 = xntohll(i64);
		  data_ += 8u;
		  size_ -= 8u;
		  return i64;
      }
    
      std::string pop_uint64_as_str() const
      {
          uint64_t value = pop_uint64();
          char buffer[64] = {0};
#if defined(COMPILER_MSVC)
		  _snprintf(buffer, COUNT_OF(buffer), UINT64_FORMAT, value);
#else
		  snprintf(buffer, COUNT_OF(buffer), UINT64_FORMAT, value);
#endif
          return buffer;
      }

      Varstr pop_varstr_ptr() const
      {
		  // Varstr { uint16_t size; const char * data; }
		  Varstr vs;
		  vs.size_ = pop_uint16();
		  vs.data_ = pop_fetch_ptr(vs.size_);
		  return vs;
      }

      Varstr pop_varstr32_ptr() const
      {
		  Varstr vs;
		  vs.size_ = pop_uint32();
		  vs.data_ = pop_fetch_ptr(vs.size_);
		  return vs;
      }

      const char * pop_fetch_ptr(size_t k) const
      {
          if (size_ < k)
          {
              //abort();
              throw NException("pop_fetch_ptr: not enough data", kResultMemoryError);
          }

          const char *p = data_;
          data_ += k;
          size_ -= k;
          return p;
      }

      bool empty() const        { return size_ == 0; }
      const char * data() const { return data_; }
      size_t size() const       { return size_; }

private:
      mutable const char  *data_;
      mutable size_t       size_;

	  int                  byte_order_;      //    net byte order:
		                                     //    0 : le; 1 : be;
};

struct Marshallable
{
	virtual void marshal(Pack &p) const = 0;
	virtual void unmarshal(const Unpack &up) = 0;
	virtual ~Marshallable() {}
	virtual std::ostream & trace(std::ostream &os) const
	{
		return os << "trace Marshallable [ not immplement ]";
	}
};

// Marshallable helper
inline std::ostream & operator << (std::ostream &os, const Marshallable &m)
{
    return m.trace(os);
}

inline Pack & operator << (Pack &p, const Marshallable &m)
{
	m.marshal(p);
	return p;
}

inline const Unpack & operator >> (const Unpack &up, const Marshallable &m)
{
	const_cast<Marshallable &>(m).unmarshal(up);
	return up;
}

struct BASE_EXPORT Voidmable : public nbase::Marshallable
{
	virtual void marshal(Pack &p) const {}
	virtual void unmarshal(const Unpack &up) {}
};

struct BASE_EXPORT Mulmable : public nbase::Marshallable
{
	Mulmable(const nbase::Marshallable &m1, const nbase::Marshallable &m2)
		: mm1(m1), mm2(m2) 
	{}

	virtual void marshal(Pack &p) const      { p << mm1 << mm2; }
	virtual void unmarshal(const Unpack &up) { assert(false); }
	virtual std::ostream & trace(std::ostream &os) const { return os << mm1 << mm2; }

	const nbase::Marshallable &mm1;
	const nbase::Marshallable &mm2;

private:
	Mulmable& operator=(const Mulmable &) {}
};

struct BASE_EXPORT Mulumable : public nbase::Marshallable
{
    Mulumable(nbase::Marshallable &m1, nbase::Marshallable &m2)
        : mm1(m1), mm2(m2)
	{}

    virtual void marshal(Pack &p) const     { p << mm1 << mm2; }
    virtual void unmarshal(const Unpack &up) { up >> mm1 >> mm2; }
    virtual std::ostream & trace(std::ostream &os) const { return os << mm1 << mm2; }

	nbase::Marshallable &mm1;
	nbase::Marshallable &mm2;

private:
	Mulumable& operator=(const Mulumable &) {}
};

struct BASE_EXPORT Rawmable : public nbase::Marshallable
{
	Rawmable(const char *data, size_t size)
		: data_(data), size_(size) 
	{}

	template <class T>
	explicit Rawmable(T &t) : data_(t.data()), size_(t.size()) {}

	virtual void marshal(Pack & p) const   { p.push(data_, size_); }
	virtual void unmarshal(const Unpack &up) { assert(false); }

	const char *data_;
	size_t      size_;
};

// base type helper
inline Pack & operator << (Pack & p, bool  b)
{
	p.push_bool(b);
	return p;
}

inline Pack & operator << (Pack &p, uint8_t i8)
{
	p.push_uint8(i8);
	return p;
}

inline Pack & operator << (Pack &p, uint16_t i16)
{
    p.push_uint16(i16);
    return p;
}

inline Pack & operator << (Pack &p, uint32_t i32)
{
	p.push_uint32(i32);
	return p;
}

inline Pack & operator << (Pack &p, uint64_t i64)
{
    p.push_uint64(i64);
    return p;
}

inline Pack & operator << (Pack &p, const std::string &str)
{
    p.push_varstr(str);
    return p;
}

inline Pack & operator << (Pack &p, const Varstr &pstr)
{
    p.push_varstr(pstr);
    return p;
}

inline const Unpack & operator >> (const Unpack &up, const std::string &str)
{
	const_cast<std::string &>(str) = up.pop_varstr();
	return up;
}

inline const Unpack & operator >> (const Unpack &up, Varstr &pstr)
{
    pstr = up.pop_varstr_ptr();
    return up;
}

inline const Unpack & operator >> (const Unpack &up, const bool &b)
{
	const_cast<bool &>(b) = up.pop_bool();
	return up;
}

inline const Unpack & operator >> (const Unpack &up, const uint8_t &i8)
{
	const_cast<uint8_t &>(i8) = up.pop_uint8();
	return up;
}

inline const Unpack & operator >> (const Unpack &up, const uint16_t &i16)
{
	const_cast<uint16_t &>(i16) = up.pop_uint16();
	return up;
}

inline const Unpack & operator >> (const Unpack &up, const uint32_t &i32)
{
    const_cast<uint32_t &>(i32) = up.pop_uint32();
    return up;
}

inline const Unpack & operator >> (const Unpack &up, const uint64_t &i64)
{
	const_cast<uint64_t &>(i64) = up.pop_uint32();
	return up;
}

template <class T1, class T2>
inline std::ostream& operator << (std::ostream &s, const std::pair<T1, T2> &p)
{
	s << p.first << '=' << p.second;
	return s;
}

template <class T1, class T2>
inline Pack & operator << (Pack &s, const std::pair<T1, T2> &p)
{
    s << p.first << p.second;
    return s;
}

template <class T1, class T2>
inline const Unpack & operator >> (const Unpack &s, std::pair<const T1, T2> &p)
{
    s >> p.first >> p.second;
    return s;
}

/*
// vc . only need this
template <class T1, class T2>
inline const Unpack & operator>>(const Unpack& s, std::pair<T1, T2>& p)
{
      s >> p.first;
      s >> p.second;
      return s;
}
*/

// container marshal helper
template <typename ContainerClass>
inline void marshal_container(Pack &p, const ContainerClass &c)
{
    p.push_uint32(uint32_t(c.size())); // use uint32 ...
    for (typename ContainerClass::const_iterator i = c.begin(); i != c.end(); ++i)
        p << *i;
}

template <typename OutputIterator>
inline void unmarshal_container(const Unpack &up, OutputIterator i)
{
	for (uint32_t count = up.pop_uint32(); count > 0; --count)
	{
		typename OutputIterator::container_type::value_type tmp;
		up >> tmp;
		*i = tmp;
		++i;
	}
}

// it could unmarshal list, vector etc..
template <typename OutputContainer>
inline void unmarshal_containerEx(const Unpack &up, OutputContainer &c)
{
    for(uint32_t count = up.pop_uint32(); count >0; --count)
    {
        typename OutputContainer::value_type tmp;
        tmp.unmarshal(up);
        c.push_back(tmp);
    }
}

template <typename ContainerClass>
inline std::ostream & trace_container(std::ostream &os, const ContainerClass &c, char div='\n')
{
    for (typename ContainerClass::const_iterator i = c.begin(); i != c.end(); ++i)
        os << *i << div;
    return os;
}

} // namespace nbase

#endif // BASE_MEMORY_PACKET_H_
  
