#ifndef LAUNCH_WIN32_H_
#define LAUNCH_WIN32_H_

#include <windows.h>
#include <string>

class ProcessLauncher {
public:
    struct LaunchParams {
        std::string process_path;
        std::string command_line;
        std::string working_dir;
    };
    static bool LaunchProcess(const LaunchParams& launch_info);
    static bool IsProcessRunAsAdmin();
};

#endif  // LAUNCH_WIN32_H_
