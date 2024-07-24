/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.meeting.plugin.padCheckDetector

import android.content.Context
import android.content.res.Configuration
import com.netease.meeting.plugin.base.Handler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
class PadCheckDetector(
    channel: MethodChannel,
    context: Context
) : Handler(channel, context) {

    private val applicationContext = context.applicationContext

    override fun unInit() {}

    override fun postInit() {}

    override fun registerObserver() {}

    override fun moduleName(): String {
        return "NEPadCheckDetector"
    }

    override fun observerModuleName(): String? {
        return null
    }

    override fun handle(method: String, call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isPad" -> {
                val isPad = (
                    context.resources.configuration.screenLayout
                        and Configuration.SCREENLAYOUT_SIZE_MASK
                    ) >= Configuration.SCREENLAYOUT_SIZE_LARGE
                result.success(isPad)
            }
            else -> result.notImplemented()
        }
    }
}
