# Build the ephemeral app in a module project.
# Prevents: Warning: library class <plugin-package> depends on program class io.flutter.plugin.**
# This is due to plugins (libraries) depending on the embedding (the program jar)

-keep class com.netease.lava.** { *; }

### NIM SDK
-dontwarn com.netease.**
-keep class com.netease.** {*;}
-dontwarn org.apache.lucene.**
-keep class org.apache.lucene.** {*;}
-keep class net.sqlcipher.** {*;}

### 美颜 SDK
-keep class com.faceunity.wrapper.faceunity {*;}
-keep class com.faceunity.wrapper.faceunity$RotatedImage {*;}


### Android 6兼容 androidx
-dontwarn org.xmlpull.v1.XmlPullParser
-dontwarn org.xmlpull.v1.XmlSerializer
-keep class org.xmlpull.v1.* {*;}

### 华为推送
-ignorewarnings
-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keep class com.huawei.hianalytics.**{*;}
-keep class com.huawei.updatesdk.**{*;}
-keep class com.huawei.hms.**{*;}

### 小米推送
-keep class com.xiaomi.** {*;}

### vivo推送
-dontwarn com.vivo.push.**
-keep class com.vivo.push.**{*; }
-keep class com.vivo.vms.**{*; }