#include "launch_win32.h"
#include <processthreadsapi.h>
#include <sddl.h>
#include <shellapi.h>
#include <tlhelp32.h>
#include <userenv.h>

bool ProcessLauncher::LaunchProcess(const LaunchParams& launch_info) {
    if (IsProcessRunAsAdmin())
        _wputenv_s(L"QTWEBENGINE_DISABLE_SANDBOX", L"1");
    SHELLEXECUTEINFOA ShExecInfo = {0};
    ShExecInfo.cbSize = sizeof(SHELLEXECUTEINFOA);
    ShExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
    ShExecInfo.hwnd = NULL;
    ShExecInfo.lpVerb = "open";
    ShExecInfo.lpFile = launch_info.process_path.c_str();
    ShExecInfo.lpParameters = launch_info.command_line.c_str();
    ShExecInfo.lpDirectory = launch_info.working_dir.c_str();
    ShExecInfo.nShow = SW_SHOW;
    ShExecInfo.hInstApp = NULL;
    return ShellExecuteExA(&ShExecInfo);
}

bool ProcessLauncher::IsProcessRunAsAdmin() {
    SID_IDENTIFIER_AUTHORITY NtAuthority = SECURITY_NT_AUTHORITY;
    PSID AdministratorsGroup;

    BOOL b =
        AllocateAndInitializeSid(&NtAuthority, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, &AdministratorsGroup);

    if (b) {
        CheckTokenMembership(NULL, AdministratorsGroup, &b);
        FreeSid(AdministratorsGroup);
    }

    return b == TRUE;
}
