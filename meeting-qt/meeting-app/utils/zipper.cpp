/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "zipper.h"
#include <assert.h>
#include "miniz/zip.h"
#include <QtGlobal>

namespace nim_tool {

Zipper::Entry::Entry(Zipper* zipper, const std::string& entry_name)
    :zipper_(zipper), entry_name_(entry_name)
{
    assert(!!zipper);
}

Zipper::Entry::~Entry()
{
    Close();
}

bool Zipper::Entry::Open()
{
    if (!Valid() || entry_name_.empty()) {
        assert(false);
        return false;
    }

    int result = zip_entry_open(zipper_->zip_object_, entry_name_.c_str());
    if (result < 0)
    {
        assert(false);
        zipper_ = nullptr;
    }
    return result == 0;
}

bool Zipper::Entry::Close()
{
    if (!Valid()) {
        zipper_ = nullptr;
        return false;
    }

    int result = zip_entry_close(zipper_->zip_object_);
    assert(result == 0);
    zipper_ = nullptr;
    return result == 0;
}

bool Zipper::Entry::WriteBuffer(const void *buf, size_t bufsize)
{
    if (!Valid()) {
        return false;
    }

    int result = zip_entry_write(zipper_->zip_object_, buf, bufsize);
    assert(result == 0);
    return result == 0;
}

bool Zipper::Entry::WriteFile(const std::string& filename)
{
    if (!Valid()) {
        assert(false);
        return false;
    }
    int result = zip_entry_fwrite(zipper_->zip_object_, filename.c_str());
    assert(result == 0);
    return result == 0;
}

bool Zipper::Entry::Valid()
{
    return zipper_ != nullptr && zipper_->zip_object_ != nullptr;
}

Zipper::Zipper()
{
}

Zipper::~Zipper()
{
    Close();
}

bool Zipper::Zip(const std::string& zipname, std::vector<std::string> file_paths, int level, int append)
{
    Zipper zipper;
    bool succeed = zipper.Open(zipname, level, append);
    if (succeed) {
        for (auto path : file_paths)
        {
            auto pos1 = path.find_last_of('\\');
            if (pos1 == std::string::npos)
                pos1 = path.find_last_of('/');
            if (pos1 == std::string::npos)
                pos1 = 0;

            auto pos2 = path.find_last_of('\\', pos1 - 1);
            if (pos2 == std::string::npos)
                pos2 = path.find_last_of('/', pos1 - 1);
            if (pos2 == std::string::npos)
                pos2 = 0;

            std::string entryName(path.substr(pos2+1));

            auto entry = zipper.CreateEntry(entryName);
            if (entry->Open()) {
                if (!entry->WriteFile(path)) {
                    assert(false);
                }
            }
            else
            {
                assert(false);
            }
            zipper.DestroyEntry(&entry);
        }

        zipper.Close();
    }

    return succeed;
}

bool Zipper::Open(const std::string& zipname, int level, int append)
{
    if (zip_object_ != nullptr)
    {
        return false;
    }
    zip_object_ = zip_open(zipname.c_str(), level, append);
    return zip_object_ != nullptr;
}

Zipper::Entry* Zipper::CreateEntry(const std::string& entry_name)
{
    if (zip_object_ == nullptr)
    {
        return nullptr;
    }
    Zipper::Entry* entry = new Zipper::Entry(this, entry_name);
    return entry;
}

void Zipper::DestroyEntry(Zipper::Entry** entry)
{
    delete *entry;
    *entry = nullptr;
}

void Zipper::Close()
{
    if (zip_object_ != nullptr)
    {
        zip_close(zip_object_);
        zip_object_ = nullptr;
    }
}

}
