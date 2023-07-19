import os
import platform
import shutil
import time
from distutils import dir_util

SCRIPT_PATH = os.path.split(os.path.realpath(__file__))[0]

os.chdir('../roomkit')
os.system('python build.py -nc -bt="Debug" -arch=x86')

roomkit = '../meeting/third_party_libs/roomkit'

sysstr = platform.system()
if sysstr == "Windows":
    if os.path.isdir(roomkit):
        roomkitTmp = "rmdir /s/q %s" % (os.path.join(SCRIPT_PATH,'third_party_libs\\roomkit\\include\\controller'))
        os.system(roomkitTmp)
        roomkitTmp = "rmdir /s/q %s" % (os.path.join(SCRIPT_PATH,'third_party_libs\\roomkit\\include'))
        os.system(roomkitTmp)
        roomkitTmp = "rmdir /s/q %s" % (os.path.join(SCRIPT_PATH,'third_party_libs\\roomkit'))
        os.system(roomkitTmp)
        time.sleep(1)
    shutil.copytree('install', roomkit)
    dir_util.copy_tree('install/libs/x86/Debug/bin', '../meeting/bin')
else:
    if os.path.isdir(roomkit):
        shutil.rmtree(roomkit)
    shutil.copytree('install', roomkit)