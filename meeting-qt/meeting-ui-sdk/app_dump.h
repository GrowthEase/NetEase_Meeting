/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#pragma once

#include <Windows.h>
#include <DbgHelp.h>
#include <QString>
#include <QProcess>
#include <QDateTime>
#include <QDir>
#include <QGuiApplication>
#include <QStandardPaths>

#pragma comment(lib, "Dbghelp.lib")

BOOL CALLBACK MyMiniDumpCallback(PVOID, const PMINIDUMP_CALLBACK_INPUT input, PMINIDUMP_CALLBACK_OUTPUT output)
{
    if(input == NULL || output == NULL)
        return FALSE;

    BOOL ret = FALSE;
    switch(input->CallbackType)
    {
    case IncludeModuleCallback:
    case IncludeThreadCallback:
    case ThreadCallback:
    case ThreadExCallback:
        ret = TRUE;
        break;
    case ModuleCallback:
    {
        if( !(output->ModuleWriteFlags & ModuleReferencedByMemory) )
        {
            output->ModuleWriteFlags &= ~ModuleWriteModule;
        }
        ret = TRUE;
    }
        break;
    default:
        break;
    }

    return ret;
}

void WriteDump(EXCEPTION_POINTERS* exp, const std::wstring &path)
{
    HANDLE h = ::CreateFile(path.c_str(), GENERIC_WRITE | GENERIC_READ, FILE_SHARE_WRITE | FILE_SHARE_READ,
                            NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);

    MINIDUMP_EXCEPTION_INFORMATION info;
    info.ThreadId = ::GetCurrentThreadId();
    info.ExceptionPointers = exp;
    info.ClientPointers = NULL;

    MINIDUMP_CALLBACK_INFORMATION mci;
    mci.CallbackRoutine = (MINIDUMP_CALLBACK_ROUTINE)MyMiniDumpCallback;
    mci.CallbackParam = 0;

    MINIDUMP_TYPE mdt = (MINIDUMP_TYPE)(MiniDumpWithIndirectlyReferencedMemory | MiniDumpScanMemory);

    MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(), h, mdt, &info, NULL, &mci);
    ::CloseHandle(h);
}

LONG WINAPI MyUnhandledExceptionFilter(EXCEPTION_POINTERS* exp)
{
    auto app_dir = qApp->property("logPath").toString();
    if (app_dir.isEmpty())
        app_dir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);

    QDateTime current_date_time = QDateTime::currentDateTime();
    QString dump_dir = app_dir + "/" + current_date_time.toString("yyyyMMdd_hhmmss") + ".dmp";
    WriteDump(exp, dump_dir.toStdWString());
    QStringList arguments;
    // arguments << "-crashed=" + dump_dir;
    // QProcess::startDetached(qApp->applicationFilePath(), arguments);
    return EXCEPTION_EXECUTE_HANDLER;
}
