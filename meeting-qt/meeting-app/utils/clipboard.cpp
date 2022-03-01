/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "clipboard.h"

Clipboard::Clipboard(QObject *parent)
    : QObject(parent)
{
    clipboard = QGuiApplication::clipboard();
}

void Clipboard::setText(QString text)
{
    clipboard->setText(text, QClipboard::Clipboard);
}

QString Clipboard::getText()
{
    return clipboard->text(QClipboard::Clipboard);
}
