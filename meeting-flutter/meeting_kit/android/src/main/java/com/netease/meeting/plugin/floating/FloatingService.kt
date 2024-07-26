/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.meeting.plugin.floating

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Rect
import android.os.Build
import android.util.Rational
import androidx.annotation.RequiresApi
import com.netease.meeting.plugin.base.Handler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FloatingService(
    channel: MethodChannel,
    context: Context,
    private val activity: Activity
) : Handler(channel, context) {

    override fun unInit() {}

    override fun postInit() {}

    override fun registerObserver() {}

    override fun moduleName(): String {
        return "NEFloatingService"
    }
    override fun observerModuleName(): String? {
        return null
    }

    @RequiresApi(Build.VERSION_CODES.N)
    override fun handle(method: String, call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "enablePip" -> result.success(enablePip(call, activity))
            "pipAvailable" -> {
                result.success(
                    activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
                )
            }
            "inPipAlready" -> {
                result.success(
                    activity.isInPictureInPictureMode
                )
            }
            "updatePIPParams" -> result.success(updatePIPParams(call, activity))
            "exitPIPMode" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                    !activity.isFinishing &&
                    activity.isInPictureInPictureMode
                ) {
                    val intent = Intent(activity, activity::class.java)
//                    intent.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                    activity.startActivity(intent)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        @JvmStatic
        @RequiresApi(Build.VERSION_CODES.N)
        fun enablePip(call: MethodCall?, activity: Activity): Boolean {
            if (call == null) {
                // todo 支持上滑退后台
                return false
            }
            if (activity.isInPictureInPictureMode) return true
//            // 如果参数设置成功，则无需进行重新开启画中画
//            if (updatePIPParams(call, activity)) return true

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val builder = PictureInPictureParams.Builder()
                    .setAspectRatio(
                        Rational(
                            call.argument("numerator") ?: 16,
                            call.argument("denominator") ?: 9
                        )
                    )
                val sourceRectHintLTRB = call.argument<List<Int>>("sourceRectHintLTRB")
                if (sourceRectHintLTRB?.size == 4) {
                    val bounds = Rect(
                        sourceRectHintLTRB[0],
                        sourceRectHintLTRB[1],
                        sourceRectHintLTRB[2],
                        sourceRectHintLTRB[3]
                    )
                    builder.setSourceRectHint(bounds)
                }

                return activity.enterPictureInPictureMode(
                    builder.build()
                )
            }
            return false
        }

        @JvmStatic
        @RequiresApi(Build.VERSION_CODES.N)
        fun updatePIPParams(call: MethodCall, activity: Activity): Boolean {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && activity.isInPictureInPictureMode) {
                // 1、计算出 PiP 小窗的宽高比，这里直接使用播放视频的控件宽和高计算
                val aspectRatio = Rational(
                    call.argument("numerator") ?: 16,
                    call.argument("denominator") ?: 9
                )
//                     2、将播放视频的控件binding.movie设置为 PiP 中要展示的部分
//                    val visibleRect = Rect()
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(aspectRatio)
//                        // 3、指定进入画中画的屏幕部分。系统根据这个可实现平滑动画效果。这里就把之前生成的 visibleRect 传值过去
//                        .setSourceRectHint(visibleRect)
                    .build()
                activity.setPictureInPictureParams(params)
                return true
            }
            return false
        }
    }

    fun dispose() {
//        activity.finish()
//        eventSink = null
//        eventChannel.setStreamHandler(null)
//        ProcessLifecycleOwner.get().lifecycle.removeObserver(this)
    }
}
