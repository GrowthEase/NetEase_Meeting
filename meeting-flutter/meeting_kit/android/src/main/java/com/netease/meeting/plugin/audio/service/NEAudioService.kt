/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.meeting.plugin.audio.service

import android.content.Context
import android.content.res.Configuration
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.NERtcParameters
import com.netease.meeting.plugin.base.BaseEventChannel
import com.netease.meeting.plugin.base.Handler
import com.netease.nertc.audiomanagerkit.AudioDevice
import com.netease.nertc.audiomanagerkit.AudioManagerEvents
import com.netease.nertc.audiomanagerkit.impl.AudioManagerImpl
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NEAudioService(
    channel: MethodChannel,
    flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    context: Context
) {
    var audioHandler: NEAudioHandler? = null
    init {
        val isPad = (
            context.resources.configuration.screenLayout
                and Configuration.SCREENLAYOUT_SIZE_MASK
            ) >= Configuration.SCREENLAYOUT_SIZE_LARGE
        val audioBroadcastReceiver = NEAudioBroadcastReceiver(context, flutterPluginBinding, isPad)
        audioHandler = NEAudioHandler(channel, context, audioBroadcastReceiver, isPad)
    }
}
class NEAudioHandler(
    channel: MethodChannel,
    context: Context,
    private val audioBroadcastReceiver: NEAudioBroadcastReceiver,
    private val isPad: Boolean
) : Handler(channel, context) {

    var listener: AudioManagerEvents =
        AudioManagerEvents { selectedAudioDevice, availableAudioDevices, hasExternalMic -> audioBroadcastReceiver.notifyAudioDeviceChanged(selectedAudioDevice, availableAudioDevices, hasExternalMic) }
    var audioManager: AudioManagerImpl? = null

    override fun unInit() {}

    override fun postInit() {}

    override fun registerObserver() {}

    override fun moduleName(): String {
        return "NEAudioService"
    }

    override fun observerModuleName(): String? {
        return null
    }

    override fun handle(method: String, call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "enumAudioDevices" -> {
                initAudioManager()
                val devices = audioManager?.enumAudioDevices()

                // 蓝牙耳机和有线耳机同时连接或者为pad设备时，忽略听筒
                if (devices?.contains(AudioDevice.WIRED_HEADSET) == true && devices.contains(AudioDevice.BLUETOOTH) ||
                    isPad
                ) {
                    devices?.remove(AudioDevice.EARPIECE)
                }
                result.success(devices?.toIntArray())
            }
            "getSelectedAudioDevice" -> {
                initAudioManager()
                val device = audioManager?.getSelectedAudioDevice()
                result.success(device)
            }
            "selectAudioDevice" -> {
                initAudioManager()
                audioManager?.selectAudioDevice(call.argument<Int>("device") ?: return)
            }
            "setAudioProfile" -> {
                initAudioManager()
                val profile = call.argument<Int>("profile") ?: return
                val scenario = call.argument<Int>("scenario") ?: return
                audioManager?.setAudioProfile(profile, scenario)
            }
            "stop" -> {
                audioManager?.stop()
                audioManager = null
            }
            "restartBluetooth" -> {
                audioManager?.restartBluetooth()
            }
            else -> result.notImplemented()
        }
    }

    fun initAudioManager() {
        if (audioManager == null) {
            // 设置关闭rtc内置路由
            val parameters = NERtcParameters()
            val disableAudioRoutekey = NERtcParameters.Key.createSpecializedKey("key_disable_sdk_audio_route") as NERtcParameters.Key<Boolean>
            parameters.set(disableAudioRoutekey, true)
            NERtcEx.getInstance().setParameters(parameters)
            audioManager = AudioManagerImpl(
                context,
                listener
            )
        }
    }
}

class NEAudioBroadcastReceiver(
    context: Context,
    flutterPluginBinding: FlutterPlugin.FlutterPluginBinding?,
    private val isPad: Boolean
) :
    BaseEventChannel(context, flutterPluginBinding, AUDIO_MANAGER_EVENT_CHANNEL_NAME) {

    fun notifyAudioDeviceChanged(selectedAudioDevice: Int, availableAudioDevices: Set<Int>, hasExternalMic: Boolean) {
        val data: MutableMap<String, Any> = HashMap()
        // 蓝牙耳机和有线耳机同时连接或者为pad设备时，忽略听筒
        val mutableAvailableAudioDevices = availableAudioDevices.toMutableSet()
        if (mutableAvailableAudioDevices.contains(AudioDevice.WIRED_HEADSET) && mutableAvailableAudioDevices.contains(AudioDevice.BLUETOOTH) ||
            isPad
        ) {
            mutableAvailableAudioDevices.remove(AudioDevice.EARPIECE)
        }
        data["selectedAudioDevice"] = selectedAudioDevice
        data["availableAudioDevices"] = mutableAvailableAudioDevices.toIntArray()
        data["hasExternalMic"] = hasExternalMic
        notifyEvent(data)
    }

    companion object {
        private const val AUDIO_MANAGER_EVENT_CHANNEL_NAME = "meeting_plugin.audio_service.manager"
    }
}
