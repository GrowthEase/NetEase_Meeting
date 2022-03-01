/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "sys_info.h"
#include <QDebug>
#ifdef Q_OS_WIN32
#include <Windows.h>
#pragma comment(lib, "Advapi32.lib")
#endif

SysInfo::SysInfo(QObject *parent) : QObject(parent)
{

}

QString SysInfo::GetSystemManufacturer()
{
#ifdef Q_OS_WIN32
    return ReadBisoValueFromReg("SystemManufacturer");
#else
    return "";
#endif
}

QString SysInfo::GetSystemProductName()
{
#ifdef Q_OS_WIN32
    return ReadBisoValueFromReg("SystemProductName");
#else
    return "";
#endif
}

QString SysInfo::ReadBisoValueFromReg(const QString &key)
{
    QString strValueData;
#ifdef Q_OS_WIN32
    static const wchar_t kBios[] = L"HARDWARE\\DESCRIPTION\\System\\BIOS";
    HKEY hKey = nullptr;
    LSTATUS lStatus = ERROR_SUCCESS;

    do {
        ::RegOpenKey(HKEY_LOCAL_MACHINE, kBios, &hKey);
        if (ERROR_SUCCESS != lStatus)
            break;
        wchar_t wchValue[MAX_PATH] = {0};
        DWORD dwType = REG_SZ;
        DWORD dwSize = sizeof(wchValue);
        lStatus = RegQueryValueEx(hKey, key.toStdWString().c_str(), NULL, &dwType, reinterpret_cast<LPBYTE>(wchValue), &dwSize);
        if (ERROR_SUCCESS != lStatus)
            break;
        strValueData = QString::fromWCharArray(wchValue);
    } while (false);

    if (hKey != nullptr)
        RegCloseKey(hKey);
#endif
    return strValueData;
}
