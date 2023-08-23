// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef VIRTUALBACKGROUNDMODEL_H
#define VIRTUALBACKGROUNDMODEL_H

#include <QAbstractListModel>
#include <vector>

class VirtualBackgroundModel : public QAbstractListModel {
    Q_OBJECT
public:
    struct VBProperty {
        QString strPath;
        QString strThumbnailPath;
        bool bAllowedDelete = false;
        bool bCurrentSelected = false;
    };

public:
    explicit VirtualBackgroundModel(QObject* parent = nullptr);
    ~VirtualBackgroundModel();

    enum {
        kVBPath = Qt::UserRole,
        kVBThumbnailPath,
        kVBAllowedDelete,
        kVBCurrentSelected,
    };

    // Basic functionality:
    virtual int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    virtual QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    const std::vector<VBProperty>& virtualBackgroundList() const;

    Q_INVOKABLE void addVB(const QString& filePathUrl);
    Q_INVOKABLE void removeVB(const QString& filePath);
    Q_INVOKABLE void setSelectedVB(const QString& filePath);
};

#endif  // VIRTUALBACKGROUNDMODEL_H
