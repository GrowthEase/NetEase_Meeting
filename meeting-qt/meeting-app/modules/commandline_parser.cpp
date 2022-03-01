/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "commandline_parser.h"

CommandLineParser::CommandLineParser(QObject *parent)
    : QObject(parent)
    , m_schemeArgument(QStringList() << "u" << "url", "Login with SSO.", "url")
{
    m_argumentsParser.addOption(m_schemeArgument);
}

RunType CommandLineParser::parseCommandLine(const QGuiApplication &app)
{
    m_argumentsParser.process(app);
    qInfo() << __FUNCTION__ << "Arguments list: " << m_argumentsParser.optionNames();

    if (m_argumentsParser.isSet(m_schemeArgument))
    {
        m_ssoArguments = m_argumentsParser.value(m_schemeArgument);
        return kRunTypeSSO;
    }

    return kRunTypeKnown;
}

QString CommandLineParser::getSSOArguments() const
{
    return m_ssoArguments;
}
