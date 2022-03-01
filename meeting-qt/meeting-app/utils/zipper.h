/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef __BASE_EXTENSION_ZIPPER_H__
#define __BASE_EXTENSION_ZIPPER_H__

#include <string>
#include <vector>

struct zip_t;

namespace nim_tool {

class Zipper
{
    class Entry
    {
    public:

        /*
              Opens a new entry for writing in a zip archive.
            */
        bool Open();

        /*
              Closes zip entry, flushes buffer and releases resources.
            */
        bool Close();

        /*
              Compresses an input buffer for the current zip entry.
            */
        bool WriteBuffer(const void *buf, size_t bufsize);

        /*
              Compresses a file for the current zip entry.
            */
        bool WriteFile(const std::string& filename);

    private:
        friend class Zipper;
        explicit Entry(Zipper* zipper, const std::string& entry_name);
        ~Entry();
        bool Valid();
    private:
        Zipper* zipper_;
        std::string entry_name_;
    };

public:
    Zipper();
    ~Zipper();

    /*
      Create zip archive with compression level for file paths.
      If append is 0 then new archive will be created, otherwise function will try to append to the specified zip archive,
      instead of creating a new one.
      Compression levels: 0-9 are the standard zlib-style levels.
      Returns true on success or false on error.
     */
    static bool Zip(const std::string& zipname, std::vector<std::string> file_paths, int level = 6, int append = 0);

    /*
      Opens zip archive with compression level.
      If append is 0 then new archive will be created, otherwise function will try to append to the specified zip archive,
      instead of creating a new one.
      Compression levels: 0-9 are the standard zlib-style levels.
      Returns pointer to zip_t structure or NULL on error.
     */
    bool Open(const std::string& zipname, int level = 6, int append = 0);

    /*
      Create a entry object.If you want to create a new entry,must release pre one.
      Returns pointer to ZipEntry class or NULL on error.
     */
    Zipper::Entry* CreateEntry(const std::string& entry_name);

    /*
      Destroy a entry object.
     */
    void DestroyEntry(Zipper::Entry** entry);

    /* Closes zip archive, releases resources - always finalize. */
    void Close();

private:
    friend class Entry;
    zip_t* zip_object_ = nullptr;
};

}

#endif // __BASE_EXTENSION_ZIPPER_H__
