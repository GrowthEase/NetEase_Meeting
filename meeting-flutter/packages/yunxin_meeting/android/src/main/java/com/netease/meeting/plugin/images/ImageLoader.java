// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.images;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;

import com.netease.meeting.plugin.base.Handler;

import java.io.ByteArrayOutputStream;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ImageLoader extends Handler {

    private static final String TAG = "MeetingPlugin/IL";

    private static final String[] DRAWABLE_TYPE = new String[]{"drawable", "mipmap"};

    public ImageLoader(MethodChannel channel, Context context) {
        super(channel, context);
    }

    @Override
    public void unInit() {}

    @Override
    public void postInit() { }

    @Override
    public void registerObserver() {}

    @Override
    public String moduleName() {
        return "ImageLoader";
    }

    @Override
    public String observerModuleName() {
        return null;
    }

    @Override
    public void handle(String method, MethodCall call, MethodChannel.Result result) {
        if ("loadImage".equals(method)) {
            final String key = call.argument("key");
            if (!TextUtils.isEmpty(key)) {
                int resId = 0;
                try {
                    resId = Integer.parseInt(key);
                } catch (NumberFormatException ignored) {
                    outer: for (String type : DRAWABLE_TYPE) {
                        for (String pkg: new String[]{context.getPackageName(), "android"}) {
                            resId = context.getResources().getIdentifier(key, type, pkg);
                            if (resId != 0) break outer;
                        }
                    }
                }
                if (resId == 0) {
                    Log.e(TAG, "loadImage failed named '" + key + "'!");
                    result.success(null);
                } else {
                    loadDrawable(key, resId,
                            (Double)call.argument("maxWidth"),
                            (Double)call.argument("maxHeight"),
                            (Integer)call.argument("imageQuality"),
                            result);
                }
            }
        }
    }

    @SuppressLint("StaticFieldLeak")
    private void loadDrawable(final String key, final int resId, final Double maxWidth, final Double maxHeight, final Integer imageQualityObj, final MethodChannel.Result result) {
        Log.d(TAG, "loadDrawable with: key=" + key + ", maxWidth=" + maxWidth + ", maxHeight=" + maxHeight + ", imageQuality=" + imageQualityObj);
        new AsyncTask<Void,Void,byte[]>() {

            float scale = 1.0f;

            @Override
            protected byte[] doInBackground(Void... voids) {
                try {
                    Bitmap bmp = BitmapFactory.decodeResource(context.getResources(), resId);

                    if (bmp == null) {
                        return null;
                    }

                    if (bmp.getDensity() != Bitmap.DENSITY_NONE) {
                        scale = bmp.getDensity() * 1.0f / DisplayMetrics.DENSITY_DEFAULT;
                    }

                    Log.d(TAG, "initial bitmap: " + bmp.getWidth() + 'x' + bmp.getHeight() + '@' + bmp.getDensity() + '@' + scale);

                    int imageQuality = isImageQualityValid(imageQualityObj) ? imageQualityObj : 100;
//                    boolean shouldScale = maxWidth != null || maxHeight != null;
//
//                    if (!shouldScale) {
//                        return bitmapToBytes(bmp, imageQuality);
//                    }
//
//                    double originalWidth = bmp.getWidth() * 1.0;
//                    double originalHeight = bmp.getHeight() * 1.0;
//
//                    boolean hasMaxWidth = maxWidth != null;
//                    boolean hasMaxHeight = maxHeight != null;
//
//                    double width = hasMaxWidth ? Math.min(originalWidth, maxWidth) : originalWidth;
//                    double height = hasMaxHeight ? Math.min(originalHeight, maxHeight) : originalHeight;
//
//                    boolean shouldDownscale = (hasMaxWidth && maxWidth < originalWidth) || (hasMaxHeight && maxHeight < originalHeight);
//
//                    if (shouldDownscale) {
//                        double downscaledWidth = (height / originalHeight) * originalWidth;
//                        double downscaledHeight = (width / originalWidth) * originalHeight;
//
//                        if (width < height) {
//                            if (!hasMaxWidth) {
//                                width = downscaledWidth;
//                            } else {
//                                height = downscaledHeight;
//                            }
//                        } else if (height < width) {
//                            if (!hasMaxHeight) {
//                                height = downscaledHeight;
//                            } else {
//                                width = downscaledWidth;
//                            }
//                        } else {
//                            if (originalWidth < originalHeight) {
//                                width = downscaledWidth;
//                            } else if (originalHeight < originalWidth) {
//                                height = downscaledHeight;
//                            }
//                        }
//
//                        Bitmap scaledBmp = Bitmap.createScaledBitmap(bmp, (int)width, (int)height, false);
//                        Log.d(TAG, "scaled bitmap: " + scaledBmp.getWidth() + 'x' + scaledBmp.getHeight());
//                        return bitmapToBytes(scaledBmp, imageQuality);
//                    }

                    return bitmapToBytes(bmp, imageQuality);
                }catch (Throwable throwable) {
                    Log.e(TAG, "loadImage failed ", throwable);
                }
                return null;
            }

            @Override
            protected void onPostExecute(byte[] bytes) {
                if (bytes != null) {
                    result.success(new MapBuilder().put("scale", scale).put("data", bytes).build());
                } else {
                    result.success(null);
                }
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    private byte[] bitmapToBytes(Bitmap bitmap, int quality) {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, quality, bos);
        return bos.toByteArray();
    }

    private static boolean isImageQualityValid(Integer imageQuality) {
        return imageQuality != null && imageQuality > 0 && imageQuality <= 100;
    }

}
