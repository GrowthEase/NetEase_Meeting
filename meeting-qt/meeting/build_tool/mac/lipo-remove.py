import argparse
import platform
import subprocess
import os
import re

def get_exec_arch(filename):
    file_info = subprocess.check_output(['file', filename])
    file_info_str = file_info.decode('utf-8')
    matches = re.findall(r'\(for architecture (.+)\)', file_info_str)
    return matches

def remove_arch(filename, arch):
    print('remove arch: %s, file: %s' % (arch, filename))
    subprocess.check_call(['lipo', filename, '-remove', arch, '-output', filename])


def list_frameworks(dir_path, pattern):
    files = os.listdir(dir_path)
    pattern = re.compile(pattern)
    file_list = []
    for file in files:
        file_path = os.path.join(dir_path, file)
        if pattern.match(file):
            file_base_name, file_ext_name = os.path.splitext(os.path.basename(file_path))
            file_list.append(os.path.join(file_path, 'Versions/Current', file_base_name))
    return file_list

def list_libraries(directory, pattern):
    dylib_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(pattern):
                dylib_files.append(os.path.join(root, file))
    return dylib_files


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='A simple program that reads a file and prints its contents.')
    parser.add_argument('file', help='app bundle path end with .app')
    parser.add_argument('arch', type=str, help='current app architecture')

    args = parser.parse_args()
    current_arch = args.arch

    framework_path = os.path.join(os.getcwd(), args.file, 'Contents/Frameworks')
    plugin_path = os.path.join(os.getcwd(), args.file, 'Contents/PlugIns')

    files = list_frameworks(framework_path, r".+\.framework$")
    files += list_libraries(plugin_path, '.dylib')
    files.append(os.path.join(os.getcwd(), args.file, 'Contents/Frameworks/QtWebEngineCore.framework/Versions/A/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess'))
    for file in files:
        archs = get_exec_arch(file)
        if len(archs) > 1:
            for arch in archs:
                if arch != current_arch:
                    remove_arch(file, arch)
