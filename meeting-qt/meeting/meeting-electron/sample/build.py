#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import os
import sys
import glob
import time
import shutil
import platform
import argparse
import shutil
import contextlib

SCRIPT_PATH = os.path.split(os.path.realpath(__file__))[0]


def connect_share_auth(share, username=None, password=None):
    backup_storage_available = os.path.isdir(share)
    if backup_storage_available:
        # print("Backup storage already connected.")
        return True

    mount_command = "net use /user:" + username + " " + share + " " + password
    os.system(mount_command)

    backup_storage_available = os.path.isdir(share)
    if backup_storage_available:
        print("Connection success.")
        return True
    else:
        print("Connection failed.")
        return False


def upload_windows():
    # 获取当前时间
    time_now = int(time.time())
    # 转换成localtime
    time_local = time.localtime(time_now)
    # 转换成新的时间格式(2016-05-09_18:59:20)
    dt = time.strftime("%Y%m%d%H%M%S", time_local)
    tmp_dirs = glob.glob(os.path.join(
        SCRIPT_PATH, 'release/NEMeetingSDKDemo*.exe'))
    file_name = ''
    for tmp_dir in tmp_dirs:
        file_name = os.path.split(tmp_dir)[-1]
        file_name_new = file_name.replace('.exe', '-' + dt + '.exe')
        os.rename('release/' + file_name, 'release/' + file_name_new)
        file_name = 'release/' + file_name_new

    if os.path.exists(file_name) == True:
        print("uploading..." + '(' + file_name + ')')
        shard_path = r'\\10.219.25.127\mmc\PC\NIM_MEETING\DEV_BINARIES\Demo-Meeting-Electron'
        if file_name_new != '':
            if connect_share_auth(shard_path, 'wb.luolihua18', 'Luolihua02'):
                shutil.copyfile(file_name, shard_path + r'\\' + file_name_new)
    else:
        print("uploading..." + '(' + file_name + ')' + ', but it not exists.')


@contextlib.contextmanager
def network_share_auth(share, drive_letter, username=None, password=None):
    server = '//%s:%s@%s' % (username, password, share)
    cmd_parts = "mount -t smbfs %s %s" % (server, drive_letter)
    os.system(cmd_parts)
    try:
        yield
    finally:
        os.system("umount %s" % drive_letter)


def upload_macos():
    # 获取当前时间
    time_now = int(time.time())
    # 转换成localtime
    time_local = time.localtime(time_now)
    # 转换成新的时间格式(2016-05-09_18:59:20)
    dt = time.strftime("%Y%m%d%H%M%S", time_local)
    mapDir = os.path.join(os.path.join(os.path.expanduser(
        "~"), 'Desktop'), 'Demo-Meeting-Electron')
    if not os.path.isdir(mapDir):
        os.makedirs(mapDir)
    tmp_dirs = glob.glob(os.path.join(
        SCRIPT_PATH, 'release/NEMeetingSDKDemo*.dmg'))
    file_name = ''
    for tmp_dir in tmp_dirs:
        file_name = os.path.split(tmp_dir)[-1]
        file_name_new = file_name.replace('.dmg', '-' + dt + '.dmg')
        os.rename('release/' + file_name, 'release/' + file_name_new)
        file_name = 'release/' + file_name_new

    if os.path.exists(file_name) == True:
        print("uploading..." + '(' + file_name + ')')
        if file_name_new != '':
            with network_share_auth(r'10.219.25.127/MMC/PC/NIM_MEETING/DEV_BINARIES/Demo-Meeting-Electron/', mapDir, 'wb.luolihua18', 'Luolihua02'):
                shutil.copyfile(file_name, os.path.join(mapDir, file_name_new))
    else:
        print("uploading..." + '(' + file_name + ')' + ', but it not exists.')

    time.sleep(1)
    os.rmdir(mapDir)


def clear_tmp():
    tmp_dirs = os.path.join(SCRIPT_PATH, 'release')
    if os.path.isdir(tmp_dirs):
        shutil.rmtree(tmp_dirs)


def main():
    parser = argparse.ArgumentParser(description='Build param.')
    parser.add_argument("-up", "--upArchive", action="store", dest="upFile",
                        default=False, help="Upload the archive to FTP(true/false)")
    # if len(sys.argv) == 1:
    # parser.print_help()
    # return False

    args = parser.parse_args()
    sysstr = platform.system()
    print("os: " + sysstr)
    print("node version: ")
    os.system("node -v")

    os.chdir(SCRIPT_PATH)
    clear_tmp()

    if sysstr == "Darwin":
        print("current path: ")
        os.system("pwd")
        os.system("echo yunxin163 | sudo -S npm install && npm run package")
    else:
        print("current path: " + SCRIPT_PATH)
        os.system("npm install && npm run package")

    if args.upFile == 'True' or args.upFile == 'true':
        if sysstr == "Windows":
            upload_windows()
        elif sysstr == "Darwin":
            upload_macos()


if __name__ == '__main__':
    main()
