//
//  TF_QRScanner.h
//  TF_QRCode
//
//  Created by apple on 16/7/27.
//  Copyright © 2016年 legentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, PlayAudioMode) {
    PlayAudioModeOnlyAudio = 0,         // 仅音频
    PlayAudioModeOnlyVibrate,           // 仅振动
    PlayAudioModeAudioAndVibrate,       // 音频和振动
    PlayAudioModeNoneAudioAndVibrate    // 无音频和振动
};

@class TF_QRScanner;

@protocol TF_QRScannerDelegate <NSObject>

/*!
 @method 设备访问受限回调
 @discussion 1. 当设备访问相机或照明灯受限时会调用。
 */
- (void)accessDeviceIsRestrictedByStatus:(AVAuthorizationStatus)status;

/*!
 @method 扫描成功
 @discussion 1. 必须在代理中实现该方法，否则将无法扫描成功。因为扫描器扫描成功后不知道将结果告诉谁。
 @discussion 2. 扫描器完成后会自动将扫描器从父视图移除，然后再执行该方法。
 */
- (void)finishedScanningAndGotTheResult:(NSString *)result;

@end


@interface TF_QRScanner : UIView
/*!
 @abstract 代理
 @discussion 1. 扫描器的代理对象，扫描成功后会调用代理对象的- scanner: hasFinishedScanningAndGotTheResult: 方法；
 */
@property (nonatomic, weak) id <TF_QRScannerDelegate> delegate;// 代理对象

/*!
 @abstract 扫描线图片
 @discussion 1. 设置一张图片作为扫描线，如不设置则为默认扫描线；
 @discussion 2. 扫描线暂时只支持从上往下扫描；
 @discussion 3. 200*10 像素。
 */
@property (strong, nonatomic) UIImage *scanLineImage;// 扫描线图片

/*!
 @abstract 扫描框图片
 @discussion 1. 设置一张图片作为扫描框，如不设置则为默认扫描框；
 @discussion 2. 扫描框的图片中间应该是透明的；
 @discussion 3. 200*200 像素。
 */
@property (strong, nonatomic) UIImage *scanFrameImage;// 扫描框图片

/*!
 @abstract 提示信息
 */
@property (strong, nonatomic) NSString *tipMessage;// 提示信息

/*!
 @abstract 隐藏照明按钮
 @discussion 1. 该属性决定是否需要显示照明按钮，默认是会显示的。
 */
@property (assign, nonatomic) BOOL hiddenLightingButton;// 隐藏照明按钮，默认值为NO。

/*!
 @abstract 扫描时间
 @discussion 1. 扫描线单个周期扫描所需要的时间。
 */
@property (assign, nonatomic) NSTimeInterval scanTime;// 扫描时间

/*!
 @abstract 播放音效的模式
 @discussion 1. 当扫描成功时候播放音频的模式；
 @discussion 2. PlayAudioModeOnlyAudio （仅音频）
 @discussion 3. PlayAudioModeOnlyVibrate （仅振动）
 @discussion 4. PlayAudioModeAudioAndVibrate （音频和振动）
 @discussion 5. PlayAudioModeNoneAudioAndVibrate （无音频和振动）
 */
@property (assign, nonatomic) PlayAudioMode playAudioMode;// 播放音效的模式

/*!
 @method 开始扫描
 @discussion 1. 必须调用该方法才能开始扫描器运行。
 */
- (void)startScanning;

/*!
 @method 停止扫描
 @abstract 调用该方法来停止扫描器运行，- removeFromSuperview 会间接调用该方法。
 @discussion 1. 建议在扫描成功的回调方法中，直接回间接调用该方法来停止扫描器运行；
 @discussion 2. 如若没有扫描成功，那么退出或移除当前视图前，应该调用一次该方法来停止扫描器运行。
 */
- (void)stopScanning;
@end
