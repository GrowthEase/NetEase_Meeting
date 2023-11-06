import QtQuick
import QtQuick.Window 2.14

import "utils/dialogManager.js" as DialogManager

HomePageForm {
    Component.onCompleted: {
        if (updateEnable) {
            updateEnable = false
            clientUpdater.checkUpdate()
        }
    }

    privacyCheck.onToggled: {
        isAgreePrivacyPolicy = privacyCheck.checked
        console.log("isAgreePrivacyPolicy", isAgreePrivacyPolicy)
    }

    buttonLogin.onClicked: {
        if(!privacyCheck.checked) {
            toast.show(qsTr('Please check to agree to the privacy policy and user service agreement'))
            return
        }

        //ursPage.visible = true
        configManager.setSSOLogin(false)
        pageLoader.setSource(Qt.resolvedUrl("qrc:/qml/LoginWithCode.qml"))
    }

    buttonSSO.onClicked: {
        if(!privacyCheck.checked) {
            toast.show(qsTr('Please check to agree to the privacy policy and user service agreement'))
            return
        }

        pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/LoginWithSSO.qml'))
    }

    privacyPolicy.onClicked: {
        Qt.openUrlExternally("https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml")
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
        target: meetingManager
        onInviteFailed: {
            Qt.callLater(function () {
                mainWindow.raiseOnTop()
                toast.show(qsTr("please first log in meeting"))
            })
        }
    }
}
