/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "command_parser.h"

CommandParser::CommandParser(QObject *parent)
    : QObject(parent)
    , m_organizationName(QStringList()      << "o" << "organization",   "Set your organization name.",          "organization")
    , m_applicationName(QStringList()       << "n" << "applicationName","Set your application name.",           "applicationName")
    , m_applicationDomain(QStringList()     << "d" << "domain",         "Set your organization domain.",        "domain")
    , m_applicationDisplayName(QStringList()<< "s" << "displayName",    "Set your application display name.",   "displayName")
    , m_createMeeting(QStringList()         << "c" << "create",         "Create a meeting with this ID.",       "create")
    , m_joinMeeting(QStringList()           << "j" << "join",           "Join a meeting with this ID.",         "join")
    , m_accountId(QStringList()             << "i" << "accountId",      "Set your account ID.",                 "accountId")
    , m_accountToken(QStringList()          << "t" << "accountToken",   "Set your account token.",              "accountToken")
    , m_nickname(QStringList()              << "m" << "nickname",       "Set your nickname of meeting.",        "nickname")
    , m_appKey(QStringList()                << "k" << "appKey",         "Set your application key.",            "appKey")
    , m_enableAudio(QStringList()           << "a" << "enableAudio",    "Set your application key.",            "enableAudio")
    , m_enableVideo(QStringList()           << "v" << "enableVideo",    "Set your application key.",            "enableVideo")
    , m_hideInvitButton(QStringList()       << "h" << "hideInvitation", "Hidden invitation button in meeting.", "hideInvitation")
    , m_logoFile(QStringList()              << "l" << "logoFile",       "Specify the logo path.",               "logoFile")
    , m_ipcPort(QStringList()               << "p" << "port",           "Application will run as this port.",   "port")
    , m_multClient(QStringList()            << "e" << "multClient",     "Application supports multiple open.",  "multClient")
    , m_ipcClientPort(0)
{
    m_argumentsParser.addOptions({m_organizationName,
                                  m_applicationName,
                                  m_applicationDomain,
                                  m_applicationDisplayName,
                                  m_createMeeting,
                                  m_joinMeeting,
                                  m_accountId,
                                  m_accountToken,
                                  m_nickname,
                                  m_appKey,
                                  m_enableAudio,
                                  m_enableVideo,
                                  m_hideInvitButton,
                                  m_logoFile,
                                  m_ipcPort,
                                  m_multClient});
}

RunType CommandParser::parseCommandLine(const QGuiApplication& app)
{
    m_argumentsParser.process(app);
    qInfo() << __FUNCTION__ << "Arguments list: " << m_argumentsParser.optionNames();

    if (m_argumentsParser.isSet(m_ipcPort))
    {
        m_ipcClientPort = m_argumentsParser.value(m_ipcPort).toUInt();
        return m_runType = kRunTypeIPCMode;
    }
    else if (m_argumentsParser.isSet(m_accountId) &&
             m_argumentsParser.isSet(m_accountToken) &&
             m_argumentsParser.isSet(m_appKey))
    {
        bool isSetMeetingId = false;
        if (m_argumentsParser.isSet(m_createMeeting))
        {
            m_commandLineInfo.create = true;
            m_commandLineInfo.meetingId = m_argumentsParser.value(m_createMeeting);
            isSetMeetingId = true;
            qInfo() << __FUNCTION__ << "Create meeting with meeting ID:" << m_argumentsParser.value(m_createMeeting);
        }

        if (m_argumentsParser.isSet(m_joinMeeting))
        {
            m_commandLineInfo.create = false;
            m_commandLineInfo.meetingId = m_argumentsParser.value(m_joinMeeting);
            isSetMeetingId = true;
            qInfo() << __FUNCTION__ << "Join meeting with meeting ID:" << m_argumentsParser.value(m_joinMeeting);
        }

        if (!isSetMeetingId)
        {
            return m_runType = kRunTypeDefault;
            qWarning() << __FUNCTION__ << "Did not set meeting ID in command line.";
        }

        if (!m_argumentsParser.isSet(m_accountId))
        {
            qWarning() << __FUNCTION__ << "Did not set account ID.";
            return m_runType = kRunTypeDefault;
        }
        m_commandLineInfo.accountId = m_argumentsParser.value(m_accountId);

        if (!m_argumentsParser.isSet(m_accountToken))
        {
            qWarning() << __FUNCTION__ << "Did not set account token.";
            return m_runType = kRunTypeDefault;
        }
        m_commandLineInfo.accountToken = m_argumentsParser.value(m_accountToken);

        if (!m_argumentsParser.isSet(m_nickname))
        {
            qWarning() << __FUNCTION__ << "Did not set nickname.";
            return m_runType = kRunTypeDefault;
        }
        m_commandLineInfo.nickname = m_argumentsParser.value(m_nickname);

        if (!m_argumentsParser.isSet(m_appKey))
        {
            qWarning() << __FUNCTION__ << "Did not set application key.";
            return m_runType = kRunTypeDefault;
        }
        m_commandLineInfo.appKey = m_argumentsParser.value(m_appKey);

        if (!m_argumentsParser.isSet(m_enableAudio))
            m_commandLineInfo.audio = false;
        else
            m_commandLineInfo.audio = m_argumentsParser.value(m_enableAudio).toInt() > 0;

        if (!m_argumentsParser.isSet(m_enableVideo))
            m_commandLineInfo.video = false;
        else
            m_commandLineInfo.video = m_argumentsParser.value(m_enableVideo).toInt() > 0;

        if (!m_argumentsParser.isSet(m_hideInvitButton))
            m_commandLineInfo.hideInvite = false;
        else
            m_commandLineInfo.hideInvite =  m_argumentsParser.value(m_hideInvitButton).toInt() > 0;


        if (m_argumentsParser.isSet(m_multClient))
            m_commandLineInfo.multClient = m_argumentsParser.value(m_multClient).toInt() > 0;
        else
            m_commandLineInfo.multClient = false;

        if (m_argumentsParser.isSet(m_applicationName))
            m_applicationInfo.appliactionName = m_argumentsParser.value(m_applicationName);
        else
            m_applicationInfo.appliactionName = "Meeting";

        if (m_argumentsParser.isSet(m_applicationDomain))
            m_applicationInfo.applicationDomain = m_argumentsParser.value(m_applicationDomain);
        else
            m_applicationInfo.applicationDomain = "yunxin.163.com";

        if (m_argumentsParser.isSet(m_applicationDisplayName))
            m_applicationInfo.applicationDisplayName = m_argumentsParser.value(m_applicationDisplayName);
        else
            m_applicationInfo.applicationDisplayName = tr("NetEase Meeting");

        if (m_argumentsParser.isSet(m_organizationName))
            m_applicationInfo.organizationName = m_argumentsParser.value(m_organizationName);
        else
            m_applicationInfo.organizationName = "NetEase";

        return m_runType = kRunTypeCommandlineMode;
    }

    return kRunTypeDefault;
}

unsigned short CommandParser::getIPCClientPort() const
{
    return m_ipcClientPort;
}

RunType CommandParser::getRunType() const
{
    return m_runType;
}

ApplicationInfo CommandParser::getApplicationInfo() const
{
    return m_applicationInfo;
}

CommandlineInfo CommandParser::getCommandLineInfo() const
{
    return m_commandLineInfo;
}
