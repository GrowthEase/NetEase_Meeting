#ifndef NERTC_BEAUTY_H
#define NERTC_BEAUTY_H

#import <Foundation/Foundation.h>

@interface NERtcBeauty : NSObject

#pragma mark - Attribute

/** 
 * @if English
 * Applies bright teeth.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 美牙
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float teeth;

/** 
 * @if English
 * Applies bright eyes.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 亮眼
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float brightEye;

/** 
 * @if English
 * Whitening.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 美白
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float whiteSkin;

/** 
 * @if English
 * Smoothing.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 磨皮
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float smoothSkin;

/** 
 * @if English
 * Applies a small nose.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 小鼻
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float smallNose;

/** 
 * @if English
 * Adjusts the eye distance.
 * Value range:[0.0, 1.0]  0.5 indicates no effect. 0.0 and 1.0 indicate the maximum effect. The default value is 0.5.
 * @endif
 * @if Chinese
 * 眼距调整
 * 取值范围:[0.0, 1.0]  0.5为无效果，0.0和1.0最大效果，默认值0.5
 * @endif
 */
@property(nonatomic, assign) float eyesDistance;

/** 
 * @if English
 * Adjusts the eye angle.
 * Value range:[0.0, 1.0]  0.5 indicates no effect. 0.0 and 1.0 indicate the maximum effect. The default value is 0.5.
 * @endif
 * @if Chinese
 * 眼角调整
 * 取值范围:[0.0, 1.0]  0.5为无效果，0.0和1.0最大效果，默认值0.5
 * @endif
 */
@property(nonatomic, assign) float eyesAngle;

/** 
 * @if English
 * Adjusts the mouth shape.
 * Value range:[0.0, 1.0]  0.5 indicates no effect. 0.0 and 1.0 indicate the maximum effect. The default value is 0.5.
 * @endif
 * @if Chinese
 * 嘴型调整
 * 取值范围:[0.0, 1.0]  0.5为无效果，0.0和1.0最大效果，默认值0.5
 * @endif
 */
@property(nonatomic, assign) float mouth;

/** 
 * @if English
 * Applies big eyes.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 大眼
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float bigEye;

/** 
 * @if English
 * Applies a small face.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 小脸
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float smallFace;

/** 
 * @if English
 * Adjusts the jaw.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 下巴调整
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float jaw;

/** 
 * @if English
 * Applies a thin face.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 瘦脸
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float thinFace;

/** 
 * @if English
 * Applies a ruddy face.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 红润
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float faceRuddyStrength;

/** 
 * @if English
 * Applies a long nose.
 * Value range:[0.0, 1.0]  0.5 indicates no effect. 0.0 and 1.0 indicate the maximum effect. The default value is 0.5.
 * @endif
 * @if Chinese
 * 长鼻
 * 取值范围:[0.0, 1.0]  0.5为无效果，0.0和1.0最大效果，默认值0.5
 * @endif
 */
@property(nonatomic, assign) float longNoseStrength;

/** 
 * @if English
 * Adjusts the philtrum.
 * Value range:[0.0, 1.0]  0.5 indicates no effect. 0.0 and 1.0 indicate the maximum effect. The default value is 0.5.
 * @endif
 * @if Chinese
 * 人中
 * 取值范围:[0.0, 1.0]  0.5为无效果，0.0和1.0最大效果，默认值0.5
 * @endif
 */
@property(nonatomic, assign) float renZhongStrength;

/** 
 * @if English
 * Adjusts the mouth angle.
 * Value range:[0.0, 1.0]  0.5 indicates no effect. 0.0 and 1.0 indicate the maximum effect. The default value is 0.5.
 * @endif
 * @if Chinese
 * 嘴角
 * 取值范围:[0.0, 1.0]  0.5为无效果，0.0和1.0最大效果，默认值0.5
 * @endif
 */
@property(nonatomic, assign) float mouthAngle;

/** 
 * @if English
 * Applies round eyes.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 圆眼
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float roundEyeStrength;

/** 
 * @if English
 * Adjusts the eye corners.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 开眼角
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float openEyeAngleStrength;

/** 
 * @if English
 * Applies a V-shaped face.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * V脸
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float vFaceStrength;

/** 
 * @if English
 * Applies a thin jaw.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 瘦下颌
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float thinUnderjawStrength;

/** 
 * @if English
 * Applies a narrow face.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 窄脸
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float narrowFaceStrength;

/**
 * @if English
 * Adjusts the cheekbone.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 瘦颧骨
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float cheekBoneStrength;

/**
 * @if English
 * Sharpens the face.
 * Value range:[0.0, 1.0]  0.0 indicates no effect. 1.0 indicates the maximum effect. The default value is 0.0.
 * @endif
 * @if Chinese
 * 锐化
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float faceSharpenStrength;

/**
 * @if English
 * @endif
 * @if Chinese
 * 调整嘴巴宽度
 * 取值范围:[0.0, 1.0]  0.5为无效果，0.0和1.0最大效果，默认值0.5
 * @endif
 */
@property(nonatomic, assign) float mouthWiderStrength;

/** 
 * @if English
 * @endif
 * @if Chinese
 * 祛抬头纹
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float foreheadWrinklesStrength;

/** 
 * @if English
 * @endif
 * @if Chinese
 * 祛黑眼圈
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float darkCirclesStrength;

/** 
 * @if English
 * @endif
 * @if Chinese
 * 祛法令纹
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float smileLinesStrength;

/** 
 * @if English
 * @endif
 * @if Chinese
 * 短脸
 * 取值范围:[0.0, 1.0]  0.0为无效果，1.0为最大效果，默认值0.0
 * @endif
 */
@property(nonatomic, assign) float shortFaceStrength;

/**
 * @if English
 * Set the filter intensity
 * Value range: 0 - 1. Default value: 0.0. A larger value indicates more intensity. Developers can adjust a custom value based on business requirements.
 * The setting takes effect when it is applied. The intensity remains if a filter is changes. You can adjust the intensity by setting this property.
 * @endif
 * @if Chinese
 * 设置滤镜强度。
 * 取值范围为 [0 - 1]，默认值为 0.0。取值越大，滤镜强度越大，开发者可以根据业务需求自定义设置滤镜强度。
 * 滤镜强度设置实时生效，更换滤镜后滤镜强度不变，如需调整，可以再次通过此参数设置滤镜强度。
 * @endif
 */
@property(nonatomic, assign) float filterStrength;

/**
 * @if English
 * Enables or disables the mirror mode when beauty is enabled.
 * The default value NO indicates that the mirror mode is enabled.
 * - If beauty is enabled, this property enables or disables the mirror mode. The mirror mode is disabled by default. If beauty is paused or disabled, the property becomes invalid.
 * - After the mirror mode is enabled, the local screen will flip left and right.
 * - This param has been deprecated.
 * @endif
 * @if Chinese
 * 启用美颜时，启用或关闭镜像模式。
 * 默认为 NO，表示美颜时启用镜像模式。
 * - 美颜功能启用时，此接口用于开启或关闭镜像模式。默认为关闭状态。美颜功能暂停或结束后，此接口不再生效。
 * - 启用镜像模式之后，本端画面会呈现为左右翻转的视觉效果。
 * - 该参数已废弃。
 * @endif
 */
@property(nonatomic, assign) BOOL flipX;

/**
 * @if English
 * Pauses or resumes the beauty effect
 * <br> The beauty effect is paused, including the global beauty effect, filters, stickers, and makeups, until the effect is resumed.
 * @note
 * - The method is only supported by macOS
 * - Beauty effect is enabled by default. If you want to temporarily disable the beauty effect, call the isOpenBeauty method after invoking \ref NERtcBeauty::startBeauty "startBeauty".
 * @since V4.2.202
 * @param enable specifies whether to resume the beauty effect.
 * - YES (default): resumes the beauty effect.
 * - NO: pauses the beauty effect.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 暂停或恢复美颜效果。
 * <br> 暂停美颜效果后，包括全局美颜、滤镜、贴纸和美妆在内的所有美颜效果都会暂时关闭，直至重新恢复美颜效果。
 * @note 
 * - 该方法仅适用于 macOS 平台。
 * - 美颜效果默认开启。若您需要临时关闭美颜功能，需要在 \ref NERtcBeauty::startBeauty "startBeauty" 之后调用该方法。
 * @since V4.2.202
 * @param enable 是否恢复美颜效果。
 * - YES（默认）：恢复美颜效果。
 * - NO：暂停美颜效果。
 * @endif
 */
@property(nonatomic, assign) BOOL isOpenBeauty;

#pragma mark - Method

+ (NERtcBeauty *)shareInstance;

/**
* @if English
* Enables the beauty module.
* - The API starts the beauty engine. If beauty is not needed, you can call \ref NERtcBeauty::stopBeauty "stopBeauty" to end the beauty module, destroy the beauty engine and release resources.
* - When the beauty module is enabled, no beauty effect is applied by default. You must set beauty effects or filters by calling {@link NERtcBeauty#setBeautyEffectWithValue:atType:} or other filters and stickers methods.
* @note 
* - The method is only supported by macOS.
* @since V4.2.202
* @return
* - 0: success.
* - 30001 (kNERtcErrFatal): failure.
* - 30004 (kNERtcErrNotSupported): beauty is not supported.
* @endif
* @if Chinese
* 开启美颜功能模块。
* - 调用此接口后，开启美颜引擎。如果后续不再需要使用美颜功能，可以调用 \ref NERtcBeauty::stopBeauty "stopBeauty" 结束美颜功能模块，销毁美颜引擎并释放资源。
* - 开启美颜功能模块后，默认无美颜效果，您需要通过 {@link NERtcBeauty#setBeautyEffectWithValue:atType:} 或其他滤镜、贴纸相关接口设置美颜或滤镜效果。
* @note 
* - 该方法仅适用于 macOS 平台。
* @since V4.2.202
* @return
* - 0: 方法调用成功。
* - 30001（kNERtcErrFatal）：方法调用失败。
* - 30004（kNERtcErrNotSupported）：不支持美颜功能。
* @endif
*/
- (int)startBeauty;

/**
* @if English
* Stops the beauty module.
* <br>If the beauty module is not needed, you can call this method to stop the module. The SDK will automatically destroy the beauty engine and release the resources.
* @note The method is only supported by macOS.
* @since V4.2.202
* @return
* - 0: success
* - Others: failure
* @endif
* @if Chinese
* 结束美颜功能模块。
* <br>
* 通过此接口实现关闭美颜功能模块后，SDK 会自动销毁美颜引擎并释放资源。
* @since V4.6.10
* @par 调用时机
* 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
* @note
* 该方法仅适用于 macOS 平台。
* @par 示例代码
* @code
* rtc_engine_->stopBeauty();
* @endcode
* @return 无返回值。
* @endif
*/
- (void)stopBeauty;

/**
 * @if English
 * Sets the beauty type and intensity.
 * - The method can set various types of beauty effects, such as smoothing, whitening, and big eyes.
 * - Multiple method calls can apply multiple global effects. Filters, stickers, and makeups can be added in the same way.
 * @note The method is only supported by macOS.
 * @since V4.2.202
 * @param type beauty type. For more information, see {@link NERtcBeautyEffectType}.
 * @param value Beauty intensity. Value range: [0, 1]. The default values of effects are different.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 设置美颜类型和强度。
 * - 此方法可用于设置磨皮、美白、大眼等多种全局美颜类型。
 * - 多次调用此接口可以叠加多种全局美颜效果，也可以通过相关方法叠加滤镜、贴纸、美妆等自定义效果。
 * @note 该方法仅适用于 macOS 平台。
 * @since V4.2.202
 * @param type 美颜类型。详细信息请参考 {@link NERtcBeautyEffectType}。
 * @param value 对应美颜类型的强度。取值范围为 [0, 1]，各种美颜效果的默认值不同。
 * @return
  * - 0：方法调用成功。
  * - 其他：方法调用失败。
 * @endif
 */
- (void)setBeautyEffectWithValue:(float)value atType:(int)type;

/**
 * @if English
 * Imports beauty assets or models.
 * @note 
 * - Before you use custom beauty effects, import beauty assets or models using this method.
 * - If the asset directory or name does not change when the beauty feature is applied, you need to import the assets once. If you want to change the assets, you must import your assets again by calling this method.
 * - This method has been deprecated.
 * @since V4.2.202
 * @param path The path of the beauty assets or models. An absolute path is required.
 * @param name The name of the beauty assets or model file.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 导入美颜资源或模型。
 * @note
 * - 使用滤镜、贴纸和美妆等自定义美颜效果之前，需要先通过此方法导入美颜资源或模型。
 * - 美颜功能模块开启过程中，如果资源路径或名称没有变更，则只需导入一次。如需更换资源，需要调用此接口重新导入。
 * - 该接口已废弃，不再需要调用。
 * @since V4.2.202
 * @param path 美颜资源或模型所在的路径。应指定为绝对路径。
 * @param name 美颜资源或模型文件的名称。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)addTempleteWithPath:(NSString *)path andName:(NSString *)name;

/**
 * @if English
 * Add filters.
 * <br>The API is used to load filter assets and add related filter effects. To change a filter, call this method for a new filter.
 * @note 
 * - The method is only supported by macOS.
 * - Before applying filters, stickers, and makeups, you must call {@link NERtcBeauty#startBeauty} to enable the beauty module.
 * - A filter effect can be applied together with global beauty effects, stickers, and makeups. However, multiple filters cannot be applied at the same time.
 * @since V4.2.202
 * @param path The path of the filter assets or models. An absolute path is required.
 * @param name The name of the filter assets or model file.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 添加滤镜效果。
 * <br>此接口用于加载滤镜资源，并添加对应的滤镜效果。需要更换滤镜时，重复调用此接口使用新的滤镜资源即可。
 * @note 
 * - 该方法仅适用于 macOS 平台。
 * - 使用滤镜、贴纸和美妆等自定义美颜效果之前，需要先通过方法 {@link NERtcBeauty#startBeauty} 开启美颜模块。
 * - 滤镜效果可以和全局美颜、贴纸、美妆等效果互相叠加，但是不支持叠加多个滤镜。
 * @since V4.2.202
 * @param path 滤镜资源或模型所在的路径。应指定为绝对路径。
 * @param name 滤镜资源或模型文件的名称。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (void)addBeautyFilterWithPath:(NSString *)path andName:(NSString *)name;

/**
 * @if English
 * Removes a filter effect.
 * @since V4.2.202
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 取消滤镜效果。
 * @note 该方法仅适用于 macOS 平台。
 * @since V4.2.202
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (void)removeBeautyFilter;

/**
 * @if English
 * Adds a sticker (beta).
 * <br>The API is used to load sticker assets and add related sticker effects. To change a sticker, call this method for a new sticker.
 * @note 
 * - The method is only supported by macOS.
 * - Before applying filters, stickers, and makeups, you must call {@link NERtcBeauty#startBeauty} to enable the beauty module.
 * - A sticker effect can be applied together with global beauty effects, stickers, and makeups. However, multiple stickers cannot be applied at the same time.
 * @since V4.2.202
 * @param path The path of the sticker assets or models. An absolute path is required.
 * @param name The name of the sticker assets or model file.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * （此接口为 beta 版本）添加贴纸效果。
 * <br>此接口用于加载贴纸资源，添加对应的贴纸效果。需要更换贴纸时，重复调用此接口使用新的贴纸资源即可。
 * @note 
 * - 该方法仅适用于 macOS 平台。
 * - 使用滤镜、贴纸和美妆等自定义美颜效果之前，需要先通过方法 {@link NERtcBeauty#startBeauty} 开启美颜模块。
 * - 贴纸效果可以和全局美颜、滤镜、美妆等效果互相叠加，但是不支持叠加多个贴纸。
 * @since V4.2.202
 * @param path 贴纸资源或模型所在的路径。应指定为绝对路径。
 * @param name 贴纸资源或模型文件的名称。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (void)addBeautyStickerWithPath:(NSString *)path andName:(NSString *)name;

/**
 * @if English
 * Removes a sticker (beta).
 * @note The method is only supported by macOS.
 * @since V4.2.202
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * （此接口为 beta 版本）取消贴纸效果。
 * @note 该方法仅适用于 macOS 平台。
 * @since V4.2.202
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (void)removeBeautySticker;

/**
 * @if English
 * Adds a makeup effect (beta).
 * <br>The API is used to load makeup assets and add related sticker effects. To change a makeup effect, call this method for a new makeup effect.
 * @note
 * - The method is only supported by macOS.
 * - Before applying filters, stickers, and makeups, you must call {@link NERtcBeauty#startBeauty} to enable the beauty module.
 * - A makeup effect can be applied together with global beauty effects, stickers, and makeups. However, multiple makeup effects cannot be applied at the same time.
 * @since V4.2.202
 * @param path The path of the sticker assets or models. An absolute path is required.
 * @param name The name of the sticker assets or model file.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * （此接口为 beta 版本）添加美妆效果。
 * <br>此接口用于加载美妆模型，添加对应的贴纸效果。需要更换美妆效果时，重复调用此接口使用新的美妆模型即可。
 * @note 
 * - 该方法仅适用于 macOS 平台。
 * - 使用滤镜、贴纸和美妆等自定义美颜效果之前，需要先通过方法 {@link NERtcBeauty#startBeauty} 开启美颜模块。
 * - 美妆效果可以和全局美颜、滤镜、贴纸等效果互相叠加，但是不支持叠加多个美妆效果。
 * @since V4.2.202
 * @param path 美妆资源或模型所在的路径。应指定为绝对路径。
 * @param name 美妆资源或模型文件的名称。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (void)addBeautyMakeupWithPath:(NSString *)path andName:(NSString *)name;

/**
 * @if English
 * Removes a makeup effect (beta).
 * @note The method is only supported by macOS.
 * @since V4.2.202
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * （此接口为 beta 版本）取消美妆效果。
 * @note 该方法仅适用于 macOS 平台。
 * @since V4.2.202
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (void)removeBeautyMakeup;

/** 
 * @if English
 * Gets error messages related to beauty
 * @since V4.2.202
 * @return Error code.
 * - 0: success.
 * - 1: No permissions. Contact your account manager for billing rules and activate the beauty feature.
 * - 100: Internal engine error. Contact the technical support for help.
 * @endif
 * @if Chinese
 * 获取美颜相关的错误信息。
 * @since V4.2.202
 * @return 错误码。
 * - 0：调用成功。
 * - 1：权限不足。请联系商务经理了解计费策略，并开通美颜功能。
 * - 100：引擎内部错误。请联系技术支持排查。
 * @endif
 */
- (NSString *)getError;

@end

#endif
