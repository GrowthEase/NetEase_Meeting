// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#pragma once

#include <DbgHelp.h>
#include <Windows.h>
#include <QDateTime>
#include <QDir>
#include <QGuiApplication>
#include <QProcess>
#include <QStandardPaths>
#include <QString>

#pragma comment(lib, "Dbghelp.lib")

BOOL CALLBACK MyMiniDumpCallback(PVOID, const PMINIDUMP_CALLBACK_INPUT input, PMINIDUMP_CALLBACK_OUTPUT output) {
    if (input == NULL || output == NULL)
        return FALSE;

    BOOL ret = FALSE;
    switch (input->CallbackType) {
        case IncludeModuleCallback:
        case IncludeThreadCallback:
        case ThreadCallback:
        case ThreadExCallback:
            ret = TRUE;
            break;
        case ModuleCallback: {
            if (!(output->ModuleWriteFlags & ModuleReferencedByMemory)) {
                output->ModuleWriteFlags &= ~ModuleWriteModule;
            }
            ret = TRUE;
        } break;
        default:
            break;
    }

    return ret;
}

void WriteDump(EXCEPTION_POINTERS* exp, const std::wstring& path) {
    HANDLE h = ::CreateFile(path.c_str(), GENERIC_WRITE | GENERIC_READ, FILE_SHARE_WRITE | FILE_SHARE_READ, NULL, CREATE_ALWAYS,
                            FILE_ATTRIBUTE_NORMAL, NULL);

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

LONG WINAPI MyUnhandledExceptionFilter(EXCEPTION_POINTERS* exp) {
    auto app_dir = qApp ? qApp->property("logPath").toString() : "";
    if (app_dir.isEmpty()) {
        app_dir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    }
    app_dir.append("/app");
    QDateTime current_date_time = QDateTime::currentDateTime();
    QString dump_dir = app_dir + "/ui_" + current_date_time.toString("yyyyMMdd_hhmmss") + ".dmp";
    QDir dumpDir;
    if (!dumpDir.exists(app_dir))
        dumpDir.mkpath(app_dir);
    WriteDump(exp, dump_dir.toStdWString());
    QStringList arguments;
    // arguments << "-crashed=" + dump_dir;
    // QProcess::startDetached(qApp->applicationFilePath(), arguments);
    return EXCEPTION_EXECUTE_HANDLER;
}
