/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "windows_helpers.h"
#include <Psapi.h>
#include <TlHelp32.h>
#include <WinUser.h>
#include <dwmapi.h>
#include <processthreadsapi.h>
#include <shlobj.h>  // SHGetFolderPathW
#include <shlwapi.h>
#include <wingdi.h>
#include <QtWin>
#include "glog/logging.h"

#pragma comment(lib, "Version.lib")
#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "User32.lib")
#pragma comment(lib, "Gdi32.lib")
#pragma comment(lib, "Advapi32.lib")
#pragma comment(lib, "Dwmapi.lib")

std::wstring WindowsHelpers::m_strCurrentExe = L"";

//不要忘记使用完char*后delete[]释放内存
char* wideCharToMultiByte(wchar_t* pWStrSrc) {
    //第一次调用确认转换后单字节字符串的长度，用于开辟空间
    int size = WideCharToMultiByte(CP_OEMCP, 0, pWStrSrc, wcslen(pWStrSrc), NULL, 0, NULL, NULL);
    char* pStrDest = new char[size + 1];
    //第二次调用将双字节字符串转换成单字节字符串
    WideCharToMultiByte(CP_OEMCP, 0, pWStrSrc, wcslen(pWStrSrc), pStrDest, size, NULL, NULL);
    pStrDest[size] = '\0';
    return pStrDest;

    //如果想要转换成string，直接赋值即可
    // string pKey = pCStrKey;
}

std::string wideCharToString(wchar_t* pWStrSrc) {
    if (nullptr == pWStrSrc) {
        return "";
    }

    char* pStr = wideCharToMultiByte(pWStrSrc);
    std::string strTmp = pStr;

    delete[] pStr;
    return strTmp;
}

//不要忘记在使用完wchar_t*后delete[]释放内存
wchar_t* multiByteToWideChar(const std::string& strSrc) {
    char* pStrDest = const_cast<char*>(strSrc.c_str());
    //第一次调用返回转换后的字符串长度，用于确认为wchar_t*开辟多大的内存空间
    int size = MultiByteToWideChar(CP_OEMCP, 0, pStrDest, strlen(pStrDest) + 1, NULL, 0);
    wchar_t* pWStrDest = new wchar_t[size];
    //第二次调用将单字节字符串转换成双字节字符串
    MultiByteToWideChar(CP_OEMCP, 0, pStrDest, strlen(pStrDest) + 1, pWStrDest, size);
    return pWStrDest;
}

WindowsHelpers::WindowsHelpers() {
    m_pPrintCaptureHelper = new PrintCaptureHelper();

    static bool bInit = false;
    if (!bInit) {
        bInit = true;

        HANDLE hToken;
        BOOL fOk = FALSE;
        DWORD dwRet = 0;
        if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &hToken)) {
            TOKEN_PRIVILEGES tp;
            tp.PrivilegeCount = 1;
            LookupPrivilegeValue(NULL, SE_DEBUG_NAME, &tp.Privileges[0].Luid);

            tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
            AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(tp), NULL, NULL);
            dwRet = GetLastError();
            fOk = (dwRet == ERROR_SUCCESS);
            CloseHandle(hToken);
        }
        if (!fOk) {
            YXLOG(Info) << "OpenProcessToken failed: GetLastError = " << dwRet;
        }
    }
}

WindowsHelpers::~WindowsHelpers() {
    if (m_pPrintCaptureHelper) {
        delete m_pPrintCaptureHelper;
        m_pPrintCaptureHelper = nullptr;
    }
}

bool WindowsHelpers::getFileVersion(const wchar_t* file_path, WORD* major_version, WORD* minor_version, WORD* build_number, WORD* revision_number) {
    DWORD handle = 0, len = 0;
    UINT buf_len = 0;
    LPTSTR buf_data = nullptr;
    VS_FIXEDFILEINFO* file_info;
    len = GetFileVersionInfoSize(file_path, &handle);
    if (0 == len)
        return false;

    buf_data = (LPTSTR)malloc(len);
    if (!buf_data)
        return false;

    if (!GetFileVersionInfo(file_path, handle, len, buf_data)) {
        free(buf_data);
        return false;
    }
    if (VerQueryValue(buf_data, L"\\", (LPVOID*)&file_info, (PUINT)&buf_len)) {
        *major_version = HIWORD(file_info->dwFileVersionMS);
        *minor_version = LOWORD(file_info->dwFileVersionMS);
        *build_number = HIWORD(file_info->dwFileVersionLS);
        *revision_number = LOWORD(file_info->dwFileVersionLS);
        free(buf_data);
        return true;
    }
    free(buf_data);
    return false;
}

int WindowsHelpers::getNTDLLVersion() {
    static int ret = 0;
    if (ret == 0) {
        wchar_t buf_dll_name[MAX_PATH] = {0};
        HRESULT hr = ::SHGetFolderPathW(NULL, CSIDL_SYSTEM, NULL, SHGFP_TYPE_CURRENT, buf_dll_name);
        if (SUCCEEDED(hr) && ::PathAppendW(buf_dll_name, L"ntdll.dll")) {
            WORD major_version, minor_version, build_number, revision_number;
            getFileVersion(buf_dll_name, &major_version, &minor_version, &build_number, &revision_number);
            ret = major_version * 100 + minor_version;
        }
    }
    return ret;
}

BOOL CALLBACK WindowsEnumerationHandler(HWND hwnd, LPARAM param) {
    WindowsHelpers::CaptureTargetInfoList* list = reinterpret_cast<WindowsHelpers::CaptureTargetInfoList*>(param);
    if (nullptr == list) {
        YXLOG(Info) << "list is nullptr" << YXLOGEnd;;
        return TRUE;
    }

    // Skip windows that are invisible, minimized, have no title, or are owned,
    // unless they have the app window style set.
    //    HWND owner = GetWindow(hwnd, GW_OWNER);
    //    LONG exstyle = GetWindowLong(hwnd, GWL_EXSTYLE);
    //    if (IsIconic(hwnd) || !IsWindowVisible(hwnd) ||
    //        (owner && !(exstyle & WS_EX_APPWINDOW))
    //        || (exstyle & WS_EX_LAYERED)) {
    //        return TRUE;
    //    }

     // YXLOG(Info) << "hwnd: " << hwnd << "IsWindow: " << ::IsWindow(hwnd) << ", IsWindowVisible: " << ::IsWindowVisible(hwnd) << ", GetWindowLong: " << ::GetWindowLong(hwnd, GWL_HWNDPARENT) << ", GetLastError: " << GetLastError() << YXLOGEnd;
     const size_t kTitleLength = 500;
     WCHAR window_title[kTitleLength] = {0};

     const size_t kClassLength = 256;
     WCHAR class_name[kClassLength] = {0};

     if (::IsWindow(hwnd) && ::IsWindowVisible(hwnd) && (::GetWindowLong(hwnd, GWL_EXSTYLE) & WS_EX_TOOLWINDOW) != WS_EX_TOOLWINDOW) {
         int class_name_length = GetClassName(hwnd, class_name, kClassLength);
         if (0 == class_name_length) {
             // YXLOG(Info) << "class_name_length: 0" << YXLOGEnd;
             return TRUE;
         }

         // std::string strClassName = wideCharToString(class_name);
         // YXLOG(Info) << "class_name: " << strClassName << YXLOGEnd;

         GetWindowText(hwnd, window_title, kTitleLength);
         // std::string strWindowTitle = wideCharToString(window_title);
         // YXLOG(Info) << "window_title: " << strWindowTitle << YXLOGEnd;
         QString strText = QString::fromStdWString(window_title);

         if (wcscmp(class_name, L"TXGuiFoundation") == 0 && strText == QStringLiteral("腾讯视频")){
         } else if (::GetWindowLong(hwnd, GWL_HWNDPARENT) != 0) {
             return TRUE;
         }
    } else {
        return TRUE;
    }

    // int len = GetWindowTextLength(hwnd);
    //    if (len == 0)
    //    {
    //        return TRUE;
    //    }

    // Skip Program Manager window and the Start button. This is the same logic
    // that's used in Win32WindowPicker in libjingle. Consider filtering other
    // windows as well (e.g. toolbars).
    if (wcscmp(class_name, L"Progman") == 0 || wcscmp(class_name, L"Button") == 0)
        return TRUE;

    if (WindowsHelpers::getNTDLLVersion() >= 602 &&
        (wcscmp(class_name, L"ApplicationFrameWindow") == 0 || wcscmp(class_name, L"Windows.UI.Core.CoreWindow") == 0)) {
        // YXLOG(Info) << "WindowsHelpers::getNTDLLVersion()" << YXLOGEnd;
        return TRUE;
    }

    DWORD dwPID;  //保存进程标识符
    GetWindowThreadProcessId(hwnd,
                             &dwPID);  //接受一个窗口句柄。dwPID保存窗口的创建者的进程标识符，GetWindowThreadProcessId返回值是该创建者的线程标识符
    HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwPID);  //打开一个已存在的进程对象,并返回进程的句柄，这就是我们要的进程句柄了
    // YXLOG(Info) << "hProcess: " << hProcess << YXLOGEnd;
    WCHAR exePath[256] = {0};
    if (NULL != hProcess) {
        //获取程序的path，并保存到exePath
        DWORD dwPathNameSize = sizeof(exePath);
        if (TRUE != QueryFullProcessImageName(hProcess, 0, exePath, &dwPathNameSize)) {
            CloseHandle(hProcess);
            YXLOG(Info) << "QueryFullProcessImageName GetLastError: " << GetLastError() << YXLOGEnd;
            return TRUE;
        }

        CloseHandle(hProcess);
        std::wstring strTemp = exePath;
        // YXLOG(Info) << "exePath: " << wideCharToString(exePath) << YXLOGEnd;
        // 过滤当前的exe
        if (0 == _wcsicmp(strTemp.c_str(), WindowsHelpers::getCurrentExe().c_str())) {
            return TRUE;
        }
    } else {
        YXLOG(Info) << "OpenProcess GetLastError: " << GetLastError() << YXLOGEnd;
    }

    WindowsHelpers::CaptureTargetInfo window;
    window.id = hwnd;
    window.title = window_title;

    if (!(wcscmp(exePath, L"") == 0)) {
        std::string strExePath = wideCharToString(exePath);
        window.app = strrchr(strExePath.c_str(), '\\') + 1;
    }

    // YXLOG(Info) << "exe: " << window.app << ", window_title: " << wideCharToString(window_title) << YXLOGEnd;
    // Skip windows when we failed to convert the title or it is empty.
    if (window.title.empty()) {
        // LOG(INFO) << "window.title.empty";
        return TRUE;
    }

    list->push_back(window);

    return TRUE;
}

std::wstring WindowsHelpers::getCurrentExe() {
    if (m_strCurrentExe == L"") {
        WCHAR szBuffer[MAX_PATH] = {0};
        GetModuleFileName(NULL, szBuffer, MAX_PATH);
        m_strCurrentExe = szBuffer;
    }

    return m_strCurrentExe;
}

bool WindowsHelpers::isWindow(HWND hWnd) const {
    return TRUE == IsWindow(hWnd);
}

bool WindowsHelpers::isMinimized(HWND hWnd) const {
    return TRUE == IsIconic(hWnd);
}

bool WindowsHelpers::isZoomed(HWND hWnd) const {
    return TRUE == IsZoomed(hWnd);
}

bool WindowsHelpers::isHide(HWND hWnd) const {
    return FALSE == IsWindowVisible(hWnd);
}

QRectF WindowsHelpers::getWindowRect(HWND hWnd) const {
    RECT rect = {0, 0, 0, 0};
    BOOL bRet = GetWindowRect(hWnd, &rect);
    if (TRUE != bRet) {
        YXLOG(Info) << "getWindowRect failed. GetLastError: " << GetLastError();
    }
    QRectF rectTmp(QPointF(rect.left, rect.top), QSizeF(rect.right - rect.left, rect.bottom - rect.top));
    return rectTmp;
}

QPixmap WindowsHelpers::getWindowImage(HWND hWnd) const {
    if (!m_pPrintCaptureHelper) {
        m_pPrintCaptureHelper->Cleanup();
        m_pPrintCaptureHelper->Init(hWnd);
        HBITMAP hBitmap = m_pPrintCaptureHelper->GetBitmap();
        return QtWin::fromHBITMAP(hBitmap);
    }

    return QPixmap();
}

QPixmap WindowsHelpers::getWindowIcon(HWND hWnd) const {
    QPixmap pixmap;
    if (TRUE != IsWindow(hWnd)) {
        return pixmap;
    }
    //获取程序的path，并保存到exePath
    DWORD dwPID;  //保存进程标识符
    GetWindowThreadProcessId(hWnd,
                             &dwPID);  //接受一个窗口句柄。dwPID保存窗口的创建者的进程标识符，GetWindowThreadProcessId返回值是该创建者的线程标识符
    HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwPID);  //打开一个已存在的进程对象,并返回进程的句柄，这就是我们要的进程句柄了
    if (NULL == hProcess) {
        return pixmap;
    }
    WCHAR exePath[256];
    memset(exePath, 0, 256);
    DWORD dwPathNameSize = sizeof(exePath);
    if (TRUE != QueryFullProcessImageName(hProcess, 0, exePath, &dwPathNameSize)) {
        CloseHandle(hProcess);
        YXLOG(Info) << "GetLastError: " << GetLastError();
        return pixmap;
    }
    CloseHandle(hProcess);
    std::wstring strTemp = exePath;

    SHFILEINFO sfiTemp;
    ZeroMemory(&sfiTemp, sizeof(sfiTemp));
    SHGetFileInfo(strTemp.c_str(), FILE_ATTRIBUTE_NORMAL, &sfiTemp, sizeof(SHFILEINFO), SHGFI_USEFILEATTRIBUTES | SHGFI_ICON | SHGFI_LARGEICON);
    if (NULL != sfiTemp.hIcon) {
        pixmap = QtWin::fromHICON(sfiTemp.hIcon);
        DestroyIcon(sfiTemp.hIcon);
    }

    return pixmap;
}

bool WindowsHelpers::getCaptureWindowList(CaptureTargetInfoList* windows) {
    if (nullptr == windows) {
        return false;
    }
    CaptureTargetInfoList result;
    LPARAM param = reinterpret_cast<LPARAM>(&result);
    if (EnumWindows(WindowsEnumerationHandler, param)) {
        std::copy(result.begin(), result.end(), std::back_inserter(*windows));
        return true;
    }
    return false;
}

void WindowsHelpers::setForegroundWindow(HWND hWnd) const {
    if (GetForegroundWindow() == hWnd) {
         YXLOG(Info) << "GetForegroundWindow() == hWnd.";
        //return;
    }

    if (::IsIconic(hWnd)) {
        BOOL bRet = ::ShowWindow(hWnd, SW_RESTORE);
        if (TRUE != bRet) {
            YXLOG(Info) << "ShowWindow failed(SW_RESTORE). GetLastError: " << GetLastError();
        }
    } else {
        if (!::IsWindowVisible(hWnd)) {
            BOOL bRet = ::ShowWindow(hWnd, SW_SHOW);
            if (TRUE != bRet) {
                YXLOG(Info) << "ShowWindow failed(SW_SHOW). GetLastError: " << GetLastError();
            }
        }
    }

    BOOL bRet = SetForegroundWindow(hWnd);
    if (TRUE != bRet) {
        YXLOG(Info) << "SetForegroundWindow failed. GetLastError: " << GetLastError();
    }
}

void WindowsHelpers::sharedOutsideWindow(WId wid, HWND hWnd, bool bFullScreen) {
    if (bFullScreen) {
        BOOL bRet = SetWindowPos((HWND)wid, hWnd, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE);
        if (TRUE != bRet) {
            YXLOG(Info) << "SetWindowPos failed. GetLastError: " << GetLastError();
        }
        bRet = SetWindowPos(hWnd, (HWND)wid, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE);
        if (TRUE != bRet) {
            YXLOG(Info) << "SetWindowPos failed. GetLastError: " << GetLastError();
        }
    } else {
        BOOL bRet = SetWindowPos((HWND)wid, hWnd, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE);
        if (TRUE != bRet) {
            YXLOG(Info) << "SetWindowPos failed. GetLastError: " << GetLastError();
        }
    }
}

void WindowsHelpers::setWindowTop(WId wid) {
    BOOL bRet = SetWindowPos((HWND)wid, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE);
    if (TRUE != bRet) {
        YXLOG(Info) << "SetWindowPos failed. GetLastError: " << GetLastError();
    }
}

QRectF WindowsHelpers::getWindowFrameRect(HWND hWnd) const {
    RECT rect;
    DwmGetWindowAttribute(hWnd, DWMWA_EXTENDED_FRAME_BOUNDS, &rect, sizeof(RECT));
    return QRectF(rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top);
}

void WindowsHelpers::getTaskbarInfo(int& width,
                                    int& height,
                                    int& pos) {  //获取系统任务栏状态位置有四种情况：左、上、右、下，此外要考虑任务栏自动隐藏的情况
    int wx = GetSystemMetrics(SM_CXSCREEN);
    int wy = GetSystemMetrics(SM_CYSCREEN);
    RECT rtWorkArea;
    SystemParametersInfo(SPI_GETWORKAREA, 0, &rtWorkArea, 0);

    int cx = rtWorkArea.right - rtWorkArea.left;
    int cy = rtWorkArea.bottom - rtWorkArea.top;

    // 1.任务栏停靠在左边情况
    if (0 != rtWorkArea.left) {
        width = wx - cx;
        height = wy;
        pos = 0;
        return;
    }
    // 2.任务栏停靠在上边情况
    if (0 != rtWorkArea.top) {
        width = wx;
        height = wy - cy;
        pos = 1;
        return;
    }
    // 3.任务栏停靠在右边情况
    if (0 == rtWorkArea.left && wx != cx) {
        width = wx - cx;
        height = wy;
        pos = 2;
        return;
    }
    // 4.任务栏停靠在下边情况
    if (0 == rtWorkArea.top && wy != cy) {
        width = wx;
        height = wy - cy;
        pos = 3;
        return;
    }
    // 5.任务栏自动隐藏的情况，这样其宽高都是0
    if (0 == rtWorkArea.left && 0 == rtWorkArea.top && wx == cx && wy == cy) {
        width = 0;
        height = 0;
        pos = 4;
        return;
    }
}

BOOL CALLBACK MonitorEnumProc(HMONITOR hMonitor, HDC hdcMonitor, LPRECT lprcMonitor, LPARAM dwData) {
    (void)hdcMonitor;
    (void)lprcMonitor;
    static BOOL first = TRUE;  //标志
    std::vector<RECT>* pRect = (std::vector<RECT>*)dwData;
    //保存显示器信息
    MONITORINFO monitorinfo;
    monitorinfo.cbSize = sizeof(MONITORINFO);

    //获得显示器信息，将信息保存到monitorinfo中
    GetMonitorInfo(hMonitor, &monitorinfo);
    //若检测到主屏
    if (monitorinfo.dwFlags == MONITORINFOF_PRIMARY) {
        if (first)  //第一次检测到主屏
        {
            first = FALSE;
            pRect->push_back(monitorinfo.rcMonitor);
        } else  //第二次检测到主屏,说明所有的监视器都已经检测了一遍，故可以停止检测了
        {
            first = TRUE;  //标志复位
            return FALSE;  //结束检测
        }
    } else {
        pRect->push_back(monitorinfo.rcMonitor);
    }
    first = TRUE;  // 恢复主屏标记为初始状态
    return TRUE;
}

//根据屏幕上指定的坐标点，获取坐标点窗口对应的pid
DWORD WindowsHelpers::getPidByPoint(int nX, int nY) {
    POINT lpt = {nX, nY};
    HWND hwnd = (HWND)WindowFromPoint(lpt);
    HWND lHdesktop = (HWND)GetDesktopWindow();

    while (1) {
        // 查找窗口的主窗口
        HWND lHparent = ::GetParent(hwnd);
        if (lHparent == lHdesktop || lHparent == 0)
            break;
        hwnd = lHparent;
    }

    DWORD dwPid = 0;
    GetWindowThreadProcessId(hwnd, &dwPid);
    return dwPid;
}

//根据屏幕上指定的坐标点，获取坐标点窗口对应的HWND
HWND WindowsHelpers::getHwndByPoint(int nX, int nY) {
    POINT lpt = {nX, nY};
    HWND hwnd = (HWND)WindowFromPoint(lpt);
    HWND lHdesktop = (HWND)GetDesktopWindow();

    while (1) {
        // 查找窗口的主窗口
        HWND lHparent = ::GetParent(hwnd);
        if (lHparent == lHdesktop || lHparent == 0)
            break;
        hwnd = lHparent;
    }

    return hwnd;
}

//查找全屏的应用窗口
BOOL WindowsHelpers::findFullScreenWindow(DWORD& dwProcessID, std::string& strProcessName, HWND& hWnd, bool& bPowerpnt) {
    bPowerpnt = false;
    // 检测显示器数量
    std::vector<RECT> vRect;
    EnumDisplayMonitors(NULL, NULL, MonitorEnumProc, (LPARAM)&vRect);  // 枚举所有显示器的Rect

    /*
   这个函数获取屏幕4角的窗口的进程句柄，判断与激活句柄是否相等的方式来判断是否全屏程序。
   特别的，对 IE 之类的多标签多进程程序，子窗口的进程会和主窗口不同。需要获取窗口的主窗口来对比才可以
   */
    // bool lbRet = false;
    // HWND lHforewnd = (HWND)0x430a4a;// ::GetForegroundWindow();
    // DWORD lWDProcessID;
    // GetWindowThreadProcessId(lHforewnd, &lWDProcessID);

    std::vector<RECT>::iterator itor = vRect.begin();
    for (; itor != vRect.end(); ++itor) {
        int nLeftPoint = itor->left;
        int nTopPoint = itor->top;
        int nRightPoint = itor->right;
        int nBottomPoint = itor->bottom;

        // 左上
        HWND hLTPid = getHwndByPoint(nLeftPoint, nTopPoint);
        // 右下
        HWND hRBPid = getHwndByPoint(nRightPoint - 70, nBottomPoint - 70);
        // YXLOG(Info) << "hLTPid, hRBPid: " << hLTPid << ", " << hRBPid << YXLOGEnd;
        // 找到全屏应用
        if (hLTPid == hRBPid) {
            hWnd = hRBPid;
            GetWindowThreadProcessId(hWnd, &dwProcessID);
            strProcessName = getModuleNameByPid(dwProcessID);

            std::string strDst;
            //转换成小写
            std::transform(strProcessName.begin(), strProcessName.end(), std::back_inserter(strDst), ::tolower);
            if (strDst == "wpp.exe" || strDst == "powerpnt.exe") {
                // YXLOG(Info) << strDst.c_str() << "%s is playing ..." << YXLOGEnd;
                if(strDst == "powerpnt.exe") {
                    bPowerpnt = true;
                }
                return true;
            }
        }

        /*
        // 左上
        DWORD dwLTPid = getPidByPoint(nLeftPoint, nTopPoint);
        // 右下
        DWORD dwRBPid = getPidByPoint(nRightPoint - 70, nBottomPoint - 70);
        // YXLOG(Info) << "dwLTPid, dwRBPid: " << dwLTPid << ", " << dwRBPid << YXLOGEnd;
        //找到全屏应用
        if (dwLTPid == dwRBPid)
        {
            dwProcessID = dwLTPid;
            strProcessName = getModuleNameByPid(dwProcessID);
            POINT lpt = { nLeftPoint, nTopPoint };
            hWnd = (HWND)WindowFromPoint(lpt);
            return true;
        }
        */
    }

    return false;
}

std::string WindowsHelpers::getModuleName(HWND hWnd) {
    DWORD dwPid = 0;
    GetWindowThreadProcessId(hWnd, &dwPid);
    return getModuleNameByPid(dwPid);
}

bool WindowsHelpers::getForegroundWindow(HWND hWnd) const {
    return GetForegroundWindow() == hWnd;
}

bool WindowsHelpers::getActiveWindow(HWND hWnd) const {
    return GetActiveWindow() == hWnd;
}

bool WindowsHelpers::getFocusWindow(HWND hWnd) const {
    return GetFocus() == hWnd;
}

bool WindowsHelpers::getDisplayRect(HWND hWnd, QRectF& rect, QRectF& availableRect, bool bPpt) const {
    QPointF point = getWindowRect(hWnd).center();
    QList<QScreen*> screens = QGuiApplication::screens();
    if (bPpt && screens.size() > 1) {
        rect = screens.at(1)->geometry();
        availableRect = screens.at(1)->availableGeometry();
        return true;
    }

    for (int i = 0; i < screens.size(); i++) {
        auto it = screens.at(i);
        if (it->geometry().contains(point.toPoint())) {
            rect = it->geometry();
            availableRect = it->availableGeometry();
            return true;
        }
    }

    return false;

    //    HMONITOR hMonitor = MonitorFromWindow(hWnd, MONITOR_DEFAULTTONEAREST);
    //    MONITORINFO monitorInfo;
    //    monitorInfo.cbSize = sizeof(MONITORINFO);
    //    BOOL bRet = GetMonitorInfo(hMonitor, &monitorInfo);
    //    if (TRUE != bRet)
    //    {
    //        YXLOG(Info) << "GetMonitorInfo failed. GetLastError: " << GetLastError() << YXLOGEnd;
    //    }
    //    auto rectTmp = monitorInfo.rcMonitor;
    //    rect = QRectF((qreal)rectTmp.left,  (qreal)rectTmp.right, (qreal)(rectTmp.right - rectTmp.left), (qreal)(rectTmp.bottom - rectTmp.top));
    //    rectTmp = monitorInfo.rcWork;
    //    availableRect = QRectF((qreal)rectTmp.left,  (qreal)rectTmp.right, (qreal)(rectTmp.right - rectTmp.left), (qreal)(rectTmp.bottom -
    //    rectTmp.top)); return true;
}

bool WindowsHelpers::isPptPlaying(HWND& hWnd, bool& bPowerpnt) {
    DWORD dwProcessID = 0;
    std::string strProcessName;
    hWnd = NULL;
    return TRUE == findFullScreenWindow(dwProcessID, strProcessName, hWnd, bPowerpnt);
}

//根据进程id获得进程名
std::string WindowsHelpers::getModuleNameByPid(DWORD dwPid) {
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, dwPid);
    if (INVALID_HANDLE_VALUE == hSnapshot) {
        return "";
    }
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(PROCESSENTRY32);         //存放进程快照信息的结构体
    BOOL ret = Process32First(hSnapshot, &pe);  //获得第一个进程的信息
    //遍历
    while (ret) {
        if (dwPid == pe.th32ProcessID) {
            CloseHandle(hSnapshot);
            return wideCharToString(pe.szExeFile);
        }
        ret = Process32Next(hSnapshot, &pe);  //接着往下遍历
    }

    CloseHandle(hSnapshot);
    return "";
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// \brief PrintCaptureHelper::PrintCaptureHelper
///
PrintCaptureHelper::PrintCaptureHelper()
    : hwnd_(nullptr)
    , scrDc_(nullptr)
    , memDc_(nullptr)
    , bitmap_(nullptr)
    , oldBitmap_(nullptr)
    , bitsPtr_(nullptr)
    , windowRect_{0, 0, 0, 0}
    , clientRect_{0, 0, 0, 0}
    , bmpDataSize_(0) {}

PrintCaptureHelper::~PrintCaptureHelper() {
    Cleanup();
}

bool PrintCaptureHelper::Init(const std::string& windowName) {
    const auto handle = ::FindWindowA(nullptr, windowName.c_str());
    if (handle == nullptr) {
        return false;
    }

    return Init(handle);
}

bool PrintCaptureHelper::Init(HWND hwnd) {
    if (hwnd != hwnd_) {
        Cleanup();
    }
    hwnd_ = hwnd;

    //获取窗口大小
    if (!::GetWindowRect(hwnd_, &windowRect_) || !::GetClientRect(hwnd_, &clientRect_)) {
        return false;
    }

    const auto clientRectWidth = clientRect_.right - clientRect_.left;
    const auto clientRectHeight = clientRect_.bottom - clientRect_.top;
    bmpDataSize_ = clientRectWidth * clientRectHeight * 4;

    //位图信息
    BITMAPINFO bitmapInfo;
    bitmapInfo.bmiHeader.biSize = sizeof(bitmapInfo);
    bitmapInfo.bmiHeader.biWidth = clientRectWidth;
    bitmapInfo.bmiHeader.biHeight = clientRectHeight;
    bitmapInfo.bmiHeader.biPlanes = 1;
    bitmapInfo.bmiHeader.biBitCount = 32;
    bitmapInfo.bmiHeader.biSizeImage = clientRectWidth * clientRectHeight;
    bitmapInfo.bmiHeader.biCompression = BI_RGB;

    scrDc_ = ::GetWindowDC(hwnd_);
    memDc_ = ::CreateCompatibleDC(scrDc_);
    bitmap_ = ::CreateDIBSection(scrDc_, &bitmapInfo, DIB_RGB_COLORS, &bitsPtr_, nullptr, 0);
    if (bitmap_ == nullptr) {
        ::DeleteDC(memDc_);
        ::ReleaseDC(hwnd_, scrDc_);
        return false;
    }

    oldBitmap_ = static_cast<HBITMAP>(::SelectObject(memDc_, bitmap_));
    return true;
}

void PrintCaptureHelper::Cleanup() {
    if (bitmap_ == nullptr) {
        return;
    }

    //删除用过的对象
    ::SelectObject(memDc_, oldBitmap_);
    ::DeleteObject(bitmap_);
    ::DeleteDC(memDc_);
    ::ReleaseDC(hwnd_, scrDc_);

    hwnd_ = nullptr;
    scrDc_ = nullptr;
    memDc_ = nullptr;
    bitmap_ = nullptr;
    oldBitmap_ = nullptr;
}

bool PrintCaptureHelper::RefreshWindow() {
    const auto hwnd = hwnd_;
    Cleanup();
    return Init(hwnd);
}

bool PrintCaptureHelper::ChangeWindowHandle(const std::string& windowName) {
    Cleanup();
    return Init(windowName);
}

bool PrintCaptureHelper::ChangeWindowHandle(HWND hwnd) {
    Cleanup();
    return Init(hwnd);
}

bool PrintCaptureHelper::Capture() const {
    if (bitmap_ == nullptr || memDc_ == nullptr || scrDc_ == nullptr) {
        return false;
    }

    auto ret = ::PrintWindow(hwnd_, memDc_, PW_CLIENTONLY | PW_RENDERFULLCONTENT);
    if (TRUE != ret) {
        ret =
            BitBlt(memDc_, 0, 0, clientRect_.right - clientRect_.left, clientRect_.bottom - clientRect_.top, scrDc_, 0, 0, SRCCOPY /*| CAPTUREBLT*/);
    }

    return TRUE == ret;
}
