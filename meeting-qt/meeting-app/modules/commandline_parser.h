/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef COMMANDLINEPARSER_H
#define COMMANDLINEPARSER_H

#include <QObject>

enum RunType
{
    kRunTypeKnown,
    kRunTypeSSO
};

class CommandLineParser : public QObject
{
    Q_OBJECT
public:
    explicit CommandLineParser(QObject *parent = nullptr);
    RunType parseCommandLine(const QGuiApplication& app);

    QString getSSOArguments() const;

signals:

private:
    QCommandLineOption m_schemeArgument;
    QCommandLineParser m_argumentsParser;

    QString m_ssoArguments;
};

#endif // COMMANDLINEPARSER_H
