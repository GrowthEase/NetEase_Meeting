/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef COMMANDPARSER_H
#define COMMANDPARSER_H

#include <QObject>

typedef struct tagApplicationInfo {
    QString organizationName;
    QString appliactionName;
    QString applicationDomain;
    QString applicationDisplayName;
} ApplicationInfo;

typedef struct tagCommandlineInfo {
    QString meetingId;
    QString accountId;
    QString accountToken;
    QString nickname;
    QString appKey;
    QString logoFile;
    bool create = false;
    bool audio = false;
    bool video = false;
    bool hideInvite = false;
    bool multClient = false;
} CommandlineInfo;

enum RunType { kRunTypeDefault, kRunTypeIPCMode, kRunTypeCommandlineMode };

class CommandParser : public QObject {
    Q_OBJECT
public:
    explicit CommandParser(QObject* parent = nullptr);

    RunType parseCommandLine(const QGuiApplication& app);
    unsigned short getIPCClientPort() const;
    RunType getRunType() const;
    ApplicationInfo getApplicationInfo() const;
    CommandlineInfo getCommandLineInfo() const;

private:
    QCommandLineOption m_organizationName;
    QCommandLineOption m_applicationName;
    QCommandLineOption m_applicationDomain;
    QCommandLineOption m_applicationDisplayName;
    QCommandLineOption m_createMeeting;
    QCommandLineOption m_joinMeeting;
    QCommandLineOption m_accountId;
    QCommandLineOption m_accountToken;
    QCommandLineOption m_nickname;
    QCommandLineOption m_appKey;
    QCommandLineOption m_enableAudio;
    QCommandLineOption m_enableVideo;
    QCommandLineOption m_hideInvitButton;
    QCommandLineOption m_logoFile;
    QCommandLineOption m_ipcPort;
    QCommandLineOption m_multClient;

    QCommandLineParser m_argumentsParser;

    RunType m_runType = kRunTypeDefault;

    unsigned short m_ipcClientPort;
    CommandlineInfo m_commandLineInfo;
    ApplicationInfo m_applicationInfo;
};

#endif  // COMMANDPARSER_H
