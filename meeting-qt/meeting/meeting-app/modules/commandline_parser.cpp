// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "commandline_parser.h"

CommandLineParser::CommandLineParser(QObject* parent)
    : QObject(parent)
    , m_schemeArgument(QStringList() << "u"
                                     << "url",
                       "Login with SSO or invite",
                       "url") {
    m_argumentsParser.addOption(m_schemeArgument);
}

RunType CommandLineParser::parseCommandLine(const QGuiApplication& app) {
    m_argumentsParser.process(app);
    qInfo() << __FUNCTION__ << "Arguments list: " << m_argumentsParser.optionNames();
    YXLOG(Info) << "url: " << m_argumentsParser.value("url").toStdString() << YXLOGEnd;
    for (auto optionName : m_argumentsParser.optionNames()) {
        YXLOG(Info) << "optionName: " << optionName.toStdString() << YXLOGEnd;
    }

    if (m_argumentsParser.isSet(m_schemeArgument)) {
        m_arguments = m_argumentsParser.value(m_schemeArgument);
        YXLOG(Info) << "m_arguments: " << m_arguments.toStdString() << YXLOGEnd;

        if (m_arguments.contains("invitation")) {
            return kRunTypeInvite;
        } else {
            return kRunTypeSSO;
        }
    }

    YXLOG(Info) << "return kRunTypeKnown" << YXLOGEnd;
    return kRunTypeKnown;
}

QString CommandLineParser::getArguments() const {
    return m_arguments;
}
