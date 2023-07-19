// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "clipboard.h"
#include <QMimeData>
#include <QTemporaryFile>

Clipboard::Clipboard(QObject* parent)
    : QObject(parent) {
    clipboard = QGuiApplication::clipboard();
}

void Clipboard::setText(QString text) {
    clipboard->setText(text, QClipboard::Clipboard);
}

QString Clipboard::getText() {
    return clipboard->text(QClipboard::Clipboard);
}

QString Clipboard::getImage() const {
    const QMimeData* mime = clipboard->mimeData();
    if (mime->hasUrls()) {
        // YXLOG(Info) << "clipboard, hasUrls: " << mime->urls().at(0).toString().toStdString() << YXLOGEnd;
        return mime->urls().at(0).toString();
    }
    auto pixmap = clipboard->pixmap(QClipboard::Clipboard);
    if (!pixmap.isNull()) {
        QTemporaryFile file;
        QString fileName;
        if (file.open()) {
            fileName = file.fileName();
            file.close();
        };
        // YXLOG(Info) << "clipboard, fileName: " << fileName.toStdString() << YXLOGEnd;
        fileName.append(".jpg");
        if (pixmap.save(fileName)) {
            return fileName;
        } else {
            YXLOG(Warn) << "clipboard, save pixmap failed." << YXLOGEnd;
        }
    }

    return "";
}
