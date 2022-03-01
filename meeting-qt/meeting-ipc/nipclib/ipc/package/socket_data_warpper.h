/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_IPC_PACKAGE_SOCKET_DATA_WARPPER__
#define NIPCLIB_IPC_PACKAGE_SOCKET_DATA_WARPPER__

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include <list>
#include "nipclib/base/packet.h"
NIPCLIB_BEGIN_DECLS

class NIPCLIB_EXPORT SocketDataWarpper
{
	class NIPCLIB_EXPORT ReceiveDataItem
	{
	public:
		ReceiveDataItem() : pack_length_(-1), buffer_(""){}
		inline bool IsCompleted() const {	return pack_length_ == buffer_.size(); }
		inline bool ReceiveData(char *sdata, size_t ssize, char* & offset)
		{
			int varint_length = 0;
			offset = sdata;
			if (pack_length_ == -1)//新包
			{
				Unpack unpack(sdata, ssize);
				try
				{
					pack_length_ = unpack.pop_varint();
				}
				catch (NException e)
				{
					return false;
				}				
				varint_length = unpack.data() - sdata;
			}
			offset += varint_length;//偏移到真实数据
			uint32_t need_append_length = pack_length_ - buffer_.size();
			if (need_append_length <= (ssize - varint_length))//传入的数据可以拆分成最少一个包
			{				
				buffer_.append(offset, need_append_length);
				offset += need_append_length;
			}
			else//传入的数据不足以填充一个包,还要等着下次的数据
			{
				buffer_.append(offset, ssize - varint_length);
				offset += ssize - varint_length;
			}
			return IsCompleted();
		}
		inline void GetData(std::string& data)
		{
			data.append(buffer_.data(), buffer_.length());
		}
	public:
		int pack_length_;
		std::string buffer_;
	};
public:
	SocketDataWarpper() { data_item_list_.emplace_back(ReceiveDataItem()); };
	~SocketDataWarpper() = default;
	virtual bool OnReceiveData(const char *sdata, size_t ssize);
	virtual bool GetReceivedPack(std::string& data);
	virtual size_t PackSendData(const std::string& raw_data, std::string& data);
private:
	std::list< ReceiveDataItem> data_item_list_;
};
NIPCLIB_END_DECLS
#endif //NIPCLIB_IPC_PACKAGE_SOCKET_DATA_WARPPER__
