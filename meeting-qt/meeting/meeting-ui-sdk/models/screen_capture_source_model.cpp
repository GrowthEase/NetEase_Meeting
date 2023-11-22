/**
 * @file screen_capture_source_model.cpp
 * @author Dylan (dengjiajia@corp.netease.com)
 * @brief
 * @date 2023/9/7
 */

#include "screen_capture_source_model.h"
#include <QBuffer>
#include <QImage>
#include <cmath>
#include "manager/meeting_manager.h"

constexpr int kMinThumbImageHeight = 100;
constexpr int kMinIconSize = 32;
constexpr int kGridColumnCount = 4;

ScreenCaptureSourceModel::ScreenCaptureSourceModel(QObject* parent)
    : QAbstractListModel(parent) {
    connect(this, &ScreenCaptureSourceModel::screenCaptureSourceChanged, this, &ScreenCaptureSourceModel::onScreenCaptureSourceChanged);
}

ScreenCaptureSourceModel::~ScreenCaptureSourceModel() {}

int ScreenCaptureSourceModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid())
        return 0;
    return m_screenCaptureSources.size();
}

QVariant ScreenCaptureSourceModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid())
        return QVariant();

    switch (role) {
        case kSourceName:
            return QVariant(m_screenCaptureSources.at(index.row()).sourceName);
        case kSourceTitle:
            return QVariant(m_screenCaptureSources.at(index.row()).title);
        case kSourceType:
            return QVariant(m_screenCaptureSources.at(index.row()).type);
        case kSourceID:
            return QVariant(reinterpret_cast<quint64>(m_screenCaptureSources.at(index.row()).sourceID));
        case kSourceProcessPath:
            return QVariant(m_screenCaptureSources.at(index.row()).processPath);
        case kSourceThumbnail:
            return QVariant(m_screenCaptureSources.at(index.row()).thumbImage);
        case kSourceIcon:
            return QVariant(m_screenCaptureSources.at(index.row()).icon);
        default:
            break;
    }

    return QVariant();
}

QHash<int, QByteArray> ScreenCaptureSourceModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kSourceName] = "name";
    names[kSourceTitle] = "title";
    names[kSourceType] = "type";
    names[kSourceID] = "id";
    names[kSourceProcessPath] = "processPath";
    names[kSourceThumbnail] = "thumbnail";
    names[kSourceIcon] = "icon";
    return names;
}

void ScreenCaptureSourceModel::onScreenCaptureSourceChanged(const QVector<ScreenCaptureInfo>& screenSources) {
    beginResetModel();
    m_screenCaptureSources.clear();
    m_screenCaptureSources = std::move(screenSources);
    endResetModel();
}

QString ScreenCaptureSourceModel::base64Encode(const neroom::NERoomThumbImage& thumb) const {
    if (thumb.length <= 0)
        return {};
    QImage image(reinterpret_cast<const uchar*>(thumb.data), thumb.size.width, thumb.size.height, QImage::Format_ARGB32);
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    buffer.open(QIODevice::WriteOnly);
    image.save(&buffer, "PNG");
    return byteArray.toBase64();
}

bool ScreenCaptureSourceModel::shouldExclude(const QString& title, const neroom::NERoomSize& size) const {
    if (size.width <= kMinThumbImageHeight || size.height <= kMinThumbImageHeight) {
        YXLOG(Info) << "[ScreenCaptureSourceModel] Exclude window with title: " << title.toStdString() << " because of its size: " << size.width
                    << "x" << size.height << YXLOGEnd;
        return true;
    }

    if (title == "StatusIndicator" || title == qApp->applicationDisplayName()) {
        YXLOG(Info) << "[ScreenCaptureSourceModel] Exclude window with title: " << title.toStdString() << YXLOGEnd;
        return true;
    }

    return false;
}

void ScreenCaptureSourceModel::startEnumCaptureSources(int thumbWidth, int thumbHeight) {
    m_screenCaptureSources.clear();

    auto* rtcController = MeetingManager::getInstance()->getInRoomRtcController();
    if (!rtcController)
        return;

    neroom::NERoomSize thumbSize{thumbWidth, thumbHeight};
    neroom::NERoomSize iconSize{kMinIconSize, kMinIconSize};
    rtcController->getScreenCaptureSourceList(
        thumbSize, iconSize, true, [this](int code, const std::string& message, const std::list<neroom::NERoomScreenCaptureInfo>& sources) {
            int screenCount = 0;
            QVector<ScreenCaptureInfo> screenSources;
            QVector<ScreenCaptureInfo> displaySources;
            for (auto source = sources.crbegin(); source != sources.crend(); source++) {
                YXLOG(Info) << "Capture source item: source name: " << (*source).sourceName << ", title: " << (*source).title
                            << ", type: " << (*source).type << ", source ID: " << (*source).sourceID << ", process path: " << (*source).processPath
                            << ", thumb image width x height: " << (*source).thumbImage.size.width << "x" << (*source).thumbImage.size.height
                            << ", icon width x height: " << (*source).icon.size.width << "x" << (*source).icon.size.height
                            << ", primary monitor: " << static_cast<int>((*source).primaryMonitor) << YXLOGEnd;
                if (shouldExclude((*source).title.c_str(), (*source).thumbImage.size))
                    continue;
                ScreenCaptureInfo info;
                info.thumbImage = base64Encode((*source).thumbImage);
                info.icon = base64Encode((*source).icon);
                info.primaryMonitor = (*source).primaryMonitor;
                info.processPath = (*source).processPath.c_str();
                info.sourceID = (*source).sourceID;
                info.sourceName = (*source).sourceName.c_str();
                info.type = (*source).type;

                if ((*source).type == neroom::kNERoomScreenCaptureSourceTypeScreen) {
                    displaySources.push_back(info);
                    screenCount++;
                } else {
                    info.title = (*source).title.c_str();
                    screenSources.push_back(info);
                }
            }
            int index = screenCount;
            for (const auto& display : displaySources) {
                auto copied = display;
                copied.title = tr("Screen ") + QString::number(index--);
                screenSources.push_front(copied);
            }
            for (int i = 0; i < kGridColumnCount - screenCount % kGridColumnCount; i++) {
                // clang-format off
                screenSources.insert(screenCount,{
                    neroom::kNERoomScreenCaptureSourceTypeUnknown,
                    0,
                    "PlaceHolder",
                    "PlaceHolder",
                    "",
                    "",
                    "",
                    false
                });
                // clang-format on
            }
            emit screenCaptureSourceChanged(screenSources);
        });
}
