![(logo)](http://h.hiphotos.baidu.com/image/w%3D310/sign=bd95c4887b8da9774e2f802a8050f872/908fa0ec08fa513dd1926b65356d55fbb2fbd955.jpg)
## TF_QRScanner
* A fast integrated solution for QR scanner.
* 一种快速集成“二维码扫描器”的解决方案。

## Demo
![(scanView)](http://a.hiphotos.baidu.com/image/w%3D310/sign=610a4b4433c79f3d8fe1e2318aa0cdbc/43a7d933c895d143057cea987bf082025aaf0706.jpg)

* 一、导入并包含头文件
```objc
#import "TF_QRScanner.h"
```

* 二、遵守协议
```objc
@interface ScanViewController () <UIWebViewDelegate, TF_QRScannerDelegate>
```

* 三、创建并设置扫描器
```objc
    // 1. 创建扫描器（如果没有自带NavigationController，则需要考虑self.view可能会将导航条遮挡。）
    TF_QRScanner *QRScanner = [[TF_QRScanner alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    
//    // 2. 配置扫描器（可选；不配置则为默认的参数。）
//    // 设置扫描框（200*200像素。）
//    QRScanner.scanFrameImage = [UIImage imageNamed:@"scanFrameCopy.png"];
//    // 设置扫描线（200*10像素。）
//    QRScanner.scanLineImage = [UIImage imageNamed:@"scanLineCopy.png"];
//    // 设置提示信息（如果不设置或设置为nil，则消息内容默认为：“请将扫描框对准二维码”。）
//    QRScanner.tipMessage = @"请将扫描框对准二维码";
//    // 设置是否隐藏照明灯按钮（默认为NO，即不隐藏。）
//    QRScanner.hiddenLightingButton = YES;
//    // 设置提扫描成功的提示方式（可选：仅声音、仅振动、声音和振动、无声音和振动，默认是：仅声音。）
//    QRScanner.playAudioMode = PlayAudioModeOnlyAudio;
//    // 设置扫描线扫描一次所需要的时间（范围：0.5s ~ 5.0s，默认时间为：1.5s。）
//    QRScanner.scanTime = 1.5;
    
    // 3. 设置代理
    QRScanner.delegate = self;
    // 4. 添加到主视图
    [self.view addSubview:QRScanner];
    // 5. 开始扫描
    [QRScanner startScanning];
}
```

* 四、实现代理方法
```objc
#pragma mark - 扫描器代理方法
// 扫描成功的回调
- (void)finishedScanningAndGotTheResult:(NSString *)result {
    self.navigationItem.title = @"扫描结果";// 设置标题
    self.resultInfo.text = result;
    if ([result hasPrefix:@"http://"] ||
        [result hasPrefix:@"HTTP://"] ||
        [result hasPrefix:@"https://"] ||
        [result hasPrefix:@"HTTPS://"]) {// 是网址
        self.loadWebPageButton.hidden = NO;
    }
}
// 相机访问受限回调
- (void)accessDeviceIsRestrictedByStatus:(AVAuthorizationStatus)status {
    switch (status) {
        case AVAuthorizationStatusRestricted: {// 受限制（可能是相机不可用）
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"相机使用受限或不可用"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"确定")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];// 退出界面
            }]];
            
            [self presentViewController:alert animated:true completion:nil];
        }
            break;
        case AVAuthorizationStatusDenied: {// 被用户明确拒绝显示
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"确定")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                [self.navigationController popViewControllerAnimated:YES];// 退出界面
            }]];
            [self presentViewController:alert animated:true completion:nil];
        }
            break;
        case AVAuthorizationStatusNotDetermined: // 用户未作出选择(权限未知)
            break;
        default:
            break;
    }
}
```

* 五、完成了？对的，就是这么简单。



##TF_QRScanner.h
```objc
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
```

##Hope
* 如本开源代码对你有帮助，恳请给个小星星；
* 如你对本代码有疑问或建议，欢迎issue，也可以将问题或建议发送至:515939539@qq.com，我们互相帮助、共同进步。
