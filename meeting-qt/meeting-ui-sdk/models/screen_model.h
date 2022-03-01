/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef SCREENLISTMODEL_H
#define SCREENLISTMODEL_H

#include <QAbstractListModel>
#include <QQuickImageProvider>
#include <vector>

class ScreenModel : public QAbstractListModel {
    Q_OBJECT
    struct AppProperty {
        QString strTitle;
        uint32_t winId = 0;
    };

public:
    explicit ScreenModel(QObject* parent = nullptr);
    ~ScreenModel();

    enum ScreenType {
        kScreenType_Invaild = -1,
        kScreenType_Screen = 0,
        kScreenType_App = 1,
    };

    enum {
        kScreenName = Qt::UserRole,
        kScreenPointX,
        kScreenPointY,
        kScreenWidth,
        kScreenHeight,
        kScreenSerialNumber,
        kScreenType,
        kScreenAppWinId,
        kScreenAppWinMinimized,
    };

    // Basic functionality:
    virtual int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    virtual QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void startEnumTopWindow();
    Q_INVOKABLE bool windowExist(quint32 id);

private:
    std::vector<AppProperty> m_vectApp;
};

class ShareImageProvider : public QQuickImageProvider {
public:
    ShareImageProvider(ScreenModel::ScreenType screenType);
    virtual QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize) override;

private:
    ScreenModel::ScreenType m_screenType;
};

#endif  // SCREENLISTMODEL_H
