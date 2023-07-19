import os
import shutil
import subprocess
import re
import dmglib
import argparse

def copy_file_from_dmg(dmg_file, file, target):
    dmg = dmglib.DiskImage(dmg_file)
    if dmg.has_license_agreement():
        print("Cannot attach disk image.")
    for mount_point in dmg.attach():
        source = os.path.join(mount_point, file)
        if os.path.exists(source):
            shutil.copytree(source, target, symlinks=True)
            dmg.detach()
            return True
    return False

def main():
    parser = argparse.ArgumentParser(description='merge files architecture')
    parser.add_argument('--files', nargs='+', help='files to merge')
    parser.add_argument('--output', help='output file name')
    # 添加一个 bool 类型参数，确认输入是否是 dmg 格式的文件
    parser.add_argument('--dmg', action='store_true', help='input file is dmg format')
    # 添加一个 bool 类型参数，确认输入是否是压缩包格式的文件
    parser.add_argument('--zip', action='store_true', help='input file is zip format')
    args = parser.parse_args()

    copied_files = []
    if args.dmg:
        for dmg in args.files:
            unmount_file = os.path.splitext(dmg)[0]
            if os.path.exists(unmount_file):
                shutil.rmtree(unmount_file)
            copy_file_from_dmg(dmg, args.output, unmount_file)
            copied_files.append(unmount_file)

    if args.zip:
        for zip in args.files:
            uncompress_file = os.path.splitext(zip)[0]
            if os.path.exists(uncompress_file):
                shutil.rmtree(uncompress_file)
            else:
                os.mkdir(uncompress_file)
            os.system('tar -zxvf {} -C {}'.format(zip, uncompress_file))
            copied_files.append(uncompress_file)

    if (len(copied_files) < 2):
        print('no files copied')
        exit()

    shutil.copytree(copied_files[0], args.output, symlinks=True)

    for root, dirs, files in os.walk(args.output):
        for name in files:
            file = os.path.join(root, name)
            if os.path.islink(file):
                continue
            if os.path.splitext(file)[1] == '.h':
                continue
            if not os.access(file, os.X_OK):
                continue
            first_arch = os.path.join(copied_files[0], file[len(args.output) + 1:])
            second_arch = os.path.join(copied_files[1], file[len(args.output) + 1:])
            if os.path.exists(first_arch) and os.path.exists(second_arch):
                os.remove(file)
                os.system('lipo -create {} {} -output {}'.format(first_arch, second_arch, file))

if __name__ == '__main__':
    main()
