/**
 * @file screen_capture_source_model.h
 * @author Dylan (dengjiajia@corp.netease.com)
 * @brief 提供从 NERoom 中获取的屏幕共享源列表
 * @date 2023/9/7
 */

#ifndef XKIT_DESKTOP_SCREEN_CAPTURE_SOURCE_MODEL_H
#define XKIT_DESKTOP_SCREEN_CAPTURE_SOURCE_MODEL_H

#include <QAbstractListModel>
#include <QVector>
#include "base_type_defines.h"

class ScreenCaptureSourceModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum { kSourceName = Qt::UserRole, kSourceTitle, kSourceType, kSourceID, kSourceProcessPath, kSourceThumbnail, kSourceIcon };
    struct ScreenCaptureInfo {
        /// @brief 数据源类型 @see NERoomScreenCaptureSourceType
        neroom::NERoomScreenCaptureSourceType type;
        /// @brief 数据源 ID @see NERoomSourceID
        neroom::NERoomSourceID sourceID;
        /// @brief 数据源标题
        QString title;
        /// @brief 数据源名称
        QString sourceName;
        /// @brief 数据源所属进程路径，macOS 下将始终为空
        QString processPath;
        /// @brief 数据源缩略图
        QString thumbImage;
        /// @brief 数据源图标
        QString icon;
        /// @brief 如果数据源类型为显示器，则表示否是为主显示器
        bool primaryMonitor;
    };

    explicit ScreenCaptureSourceModel(QObject* parent = nullptr);
    ~ScreenCaptureSourceModel();

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void startEnumCaptureSources(int thumbWidth, int thumbHeight);

signals:
    void screenCaptureSourceChanged(const QVector<ScreenCaptureInfo>& screenSources);
    void sourceTypeChanged();

private slots:
    void onScreenCaptureSourceChanged(const QVector<ScreenCaptureInfo>& screenSources);

private:
    QString base64Encode(const neroom::NERoomThumbImage& thumb) const;
    bool shouldExclude(const QString& title, const neroom::NERoomSize& size) const;

private:
    QVector<ScreenCaptureInfo> m_screenCaptureSources;
};

#endif  // XKIT_DESKTOP_SCREEN_CAPTURE_SOURCE_MODEL_H
