#include "meeting_event_manager.h"
#include <QJsonArray>
#include <QMap>
#include <QNetworkReply>
#include <QSysInfo>
#include <QVector>
#include "manager/config_manager.h"
#include "manager/global_manager.h"
#include "stable.h"
#include "utils/invoker.h"
#include "version.h"

MeetingEventReporter::~MeetingEventReporter() {}

void MeetingEventReporter::OnAddEvent(const std::shared_ptr<IStatEvent>& event) {
    Invoker::getInstance()->execute([=]() {
        auto* roomkit = GlobalManager::getInstance()->getRoomKitService();
        if (roomkit) {
            event->FinalEvent();
            QJsonDocument content = QJsonDocument::fromJson(event->GetEventContent().c_str());
            QJsonObject eventContent = content.object();
            QJsonObject values;
            values.insert(event->GetEventName().c_str(), eventContent);
            QJsonDocument doc(values);
            QString valuesString = doc.toJson(QJsonDocument::Compact);
            roomkit->invokeMethod("event", valuesString.toStdString(), [](int result_code, const std::string& message) {
                if (result_code != 0)
                    YXLOG(Info) << "[MeetingEventReporter] Failed to invoke method, error code: " << result_code << ", message: " << message
                                << YXLOGEnd;
            });
        }
    });
}

void MeetingEventReporter::OnRemoveEvent(const std::string& event_uuid) {}
