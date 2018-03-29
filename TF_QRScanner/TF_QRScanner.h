/** The MIT License (MIT)
 Copyright (c) 2016-2018 TF_QRScanner (https://github.com/teanfoo/TF_QRScanner)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

/** 版本信息
 Version:   2.0
 Date:      2018.03.29
 Target:    iOS 8.0 Later
 Changes:   (【A】新增，【D】删除，【M】修改，【F】修复Bug)
 1.【A】新增“创建二维码”的功能，支持二维码嵌入Logo；
 2.【A】新增“识别图片中二维码”的功能，可用作识别相册中的二维码图片和识别当前屏幕上的二维码图片等；
 3.【A】新增“扫描时保持屏幕常亮”的功能；
 4.【A】新增“支持调整扫描窗口位置”的功能；
 5.【M】修改“请求相机访问权限”的处理逻辑；
 6.【M】更换扫描界面“开灯”和“关灯”按钮的图标；
 7.【M】更换App图标。
 */

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
 @discussion 1. 当设备访问相机受限时会调用。
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
 @discussion 3. 宽高比（20:1）。
 */
@property (strong, nonatomic) UIImage *scanLineImage;// 扫描线图片

/*!
 @abstract 扫描框图片
 @discussion 1. 设置一张图片作为扫描框，如不设置则为默认扫描框；
 @discussion 2. 扫描框的图片中间应该是透明的；
 @discussion 3. 宽高比（1:1）。
 */
@property (strong, nonatomic) UIImage *scanFrameImage;// 扫描框图片

/*!
 @abstract 提示信息
 */
@property (strong, nonatomic) NSString *tipMessage;// 提示信息

/*!
 @abstract 隐藏照明按钮
 @discussion 1. 在有闪光灯硬件的基础上，该属性决定是否需要显示照明按钮，默认是会显示的；
 @discussion 2. 在有闪光灯硬件，该属性无效。
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
 @abstract 扫描窗口中心位置
 @discussion 1. 用于调整扫描窗口在扫描器图层上的相对位置；
 @discussion 2. 如超出显示范围将自动更正位置，确保扫描窗口完整显示在扫描器中。
 */
@property (assign, nonatomic) CGPoint windowCenter;// 扫描窗口中心位置

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

#pragma mark - 解析图片中的二维码

/** 解析图片中的二维码
 @param image 二维码图片
 @param completion 解析完成后的回调
 @discussion 1.result为解析到的结果，msg为解析出错的提示信息。
 */
+ (void)parsingQRCodeImage:(UIImage *)image completion:(void(^)(NSString *result, NSString *msg))completion;

#pragma mark - 生成二维码

/** 生成二维码
 @param string 二维码内容
 @param size 二维码尺寸（宽度）
 @param logo logo图片（宽度为size的25%）
 @return 生成的二维码
 */
+ (UIImage *)createQRImageWithString:(NSString *)string size:(CGFloat)size logo:(UIImage *)logo;

@end
