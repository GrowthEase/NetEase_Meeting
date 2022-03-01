import optparse
import sys
import shutil
import os
import git
import re

root_directory = os.path.split(os.path.realpath(__file__))[0].replace('\\', '/') + "/"

def update_version(tag, target, encoding='utf-8'):
    repo = git.Repo(root_directory)
    f = open(target, 'r', encoding=encoding)
    results = f.readlines()
    lines = []
    #last_tag = str(repo.tags[-1])
    last_tag = tag
    env_dist = os.environ
    commits_count = "2190"
    # if env_dist["CI_COMMIT_BRANCH"] == "master":
        # commits_count = str(int(repo.git.rev_list('--all', '--count')) + 1550)
    version = last_tag + '.' + commits_count
    base_version = version.replace('.', ',')
    show_version = base_version.replace(',', '.')
    print("Update file " + target + " to " + version)
    for line in results:
        if line.startswith('    VERSION = '):
            line = '    VERSION = ' + show_version + '\n'
        elif line.startswith(' FILEVERSION '):
            line = ' FILEVERSION ' + base_version + '\n'
        elif line.startswith(' PRODUCTVERSION '):
            line = ' PRODUCTVERSION ' + base_version + '\n'
        elif line.startswith('#define APPLICATION_VERSION '):
            line = '#define APPLICATION_VERSION "' + show_version + '"\n'
        elif line.startswith('#define COMMIT_COUNT '):
            line = '#define COMMIT_COUNT ' + commits_count + '\n'
        elif line.startswith("#define COMMIT_HASH "):
            line = '#define COMMIT_HASH "' + repo.head.object.hexsha + '"\n'
        elif line.startswith("#define MEETING_SDK_VERSION "):
            line = '#define MEETING_SDK_VERSION "' + show_version + '"\n'
        else:
            line = re.sub(r'(\s+VALUE\s"FileVersion",\s+)"(.*)"', r'\1"%s"' % show_version, line)
            line = re.sub(r'(\s+VALUE\s"ProductVersion",\s+)"(.*)"', r'\1"%s"' % show_version, line)
        lines.append(line)
    f.close()
    f = open(target, 'w', encoding=encoding)
    f.writelines(lines)
    f.close()


def main(argv):
    option_parser = optparse.OptionParser()
    option_parser.add_option('--version', help='Version Name')
    options, args = option_parser.parse_args(argv)
    tag = "1.0.0"
    if options.version:
         tag = options.version

    update_version(tag, root_directory + 'meeting-app/meeting-app.pro')
    update_version(tag, root_directory + 'meeting-app/version.h')
    update_version(tag, root_directory + 'meeting-ui-sdk/meeting-ui-sdk.pro')
    update_version(tag, root_directory + 'meeting-ui-sdk/version.h')
    update_version(tag, root_directory + 'setup/src/setup/setup.rc', encoding='gbk')


if __name__ == "__main__":
    main(sys.argv)
