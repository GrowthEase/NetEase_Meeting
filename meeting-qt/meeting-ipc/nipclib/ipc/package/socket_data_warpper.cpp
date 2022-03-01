/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nipclib/ipc/package/socket_data_warpper.h"

NIPCLIB_BEGIN_DECLS

bool SocketDataWarpper::OnReceiveData(const char *sdata, size_t ssize)
{
    auto data_it = data_item_list_.rbegin();
    if (data_it->IsCompleted())
    {
        data_item_list_.emplace_back(ReceiveDataItem());
        data_it = data_item_list_.rbegin();
    }
    char* data = (char*)sdata;
    char* offset = nullptr;
    while (data_it->ReceiveData(data, ssize, offset))
    {
        if ((offset - (char*)data) < ssize)//数据还没有解完
        {
            ssize -= (offset - (char*)data);
            data = offset;
            data_item_list_.emplace_back(ReceiveDataItem());
            data_it = data_item_list_.rbegin();
            continue;
        }
        break;
    }
    return data_item_list_.begin()->IsCompleted();
}
bool SocketDataWarpper::GetReceivedPack(std::string& data)
{
    bool ret = false;
    data.clear();
    if (!data_item_list_.empty())
    {
        auto it = data_item_list_.begin();
        if (it->IsCompleted())
        {
            it->GetData(data);
            it = data_item_list_.erase(it);
            if (it != data_item_list_.end())
                ret = it->IsCompleted();
        }
    }
    if (data_item_list_.empty())
        data_item_list_.emplace_back(ReceiveDataItem());
    return ret;
}
size_t SocketDataWarpper::PackSendData(const std::string& raw_data, std::string& data)
{
    PackBuffer pack_buffer;
    Pack pack(pack_buffer);
    pack.push_varint(raw_data.size());
    data.clear();
    data.append(pack.data(), pack.size());
    data.append(raw_data.data(), raw_data.size());
    return data.size();
}
NIPCLIB_END_DECLS