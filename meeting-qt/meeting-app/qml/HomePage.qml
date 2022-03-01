import QtQuick 2.15
import QtQuick.Window 2.14

import "utils/dialogManager.js" as DialogManager

HomePageForm {
    Component.onCompleted: {
        if (updateEnable) {
            updateEnable = false
            clientUpdater.checkUpdate()
        }
        if (globalSettings.value('sharedMeetingId', '') !== '')
            pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/AnonJoinPage.qml'))

        if(!hasReadSafeTip) {
            if(configManager.needSafeTip) {
                initSaveTip()
            } else {
                configManager.requestServerAppConfigs()
            }
        }

    }

    privacyCheck.onToggled: {
        isAgreePrivacyPolicy = privacyCheck.checked
        console.log("isAgreePrivacyPolicy", isAgreePrivacyPolicy)
    }

    buttonJoin.onClicked: {
        if(!privacyCheck.checked) {
            toast.show(qsTr('Please check to agree to the privacy policy and user service agreement'))
            return
        }

        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/AnonJoinPage.qml"))
    }

    buttonLogin.onClicked: {
        if(!privacyCheck.checked) {
            toast.show(qsTr('Please check to agree to the privacy policy and user service agreement'))
            return
        }

        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/LoginWithCode.qml"))
    }

    buttonRegister.onClicked: {
        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/RegisterPage.qml"))
    }

    buttonSSO.onClicked: {
        pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoginWithSSO.qml'))
    }

    privacyPolicy.onClicked: {
        Qt.openUrlExternally("https://reg.163.com/agreement_mobile_ysbh_wap.shtml?v=20171127")
    }

    userServiceAgreement.onClicked: {
        Qt.openUrlExternally("https://netease.im/meeting/clauses?serviceType=0")
    }

    appTipArea.onSigContentClicked: {
        function confirm() {
            //hasReadSafeTip = true
        }

        function cancel() {
            //do nonthing
        }

        var obj = configManager.getSafeTipContent()
        DialogManager.dynamicDialog(obj.title, obj.content, confirm, cancel, mainWindow, obj.okBtnLabel, "", false)
    }

    appTipArea.onSigCloseClicked: {
        hasReadSafeTip = true
    }

    Connections {
        target: clientUpdater
        onCheckUpdateSignal: {
            console.info(updateIgnore, resultCode, resultType, JSON.stringify(response))
            if (0 !== updateIgnore && updateIgnore <= clientUpdater.getLatestVersion()) return
            if (resultCode !== 200) return
            if (resultType === 4 || resultType === 5) {
                const popup = Qt.createComponent("qrc:/qml/components/CheckUpdate.qml").createObject(mainWindow, {
                                                                                     updateType: resultType,
                                                                                     clientUpdateInfo: response
                                                                                 })
                popup.open()
            }
        }
    }

    Connections {
        target: configManager
        onNeedSafeTipChanged: {
            initSaveTip()
        }
    }

    function initSaveTip() {
        appTipArea.visible = configManager.needSafeTip && !hasReadSafeTip
        if(appTipArea.visible) {
            var obj = configManager.getSafeTipContent()
            appTipArea.description = obj.content
        }
    }
}
