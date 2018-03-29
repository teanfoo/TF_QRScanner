---------- [ ![logo](https://camo.githubusercontent.com/f4c4911a30139530bdc1711a57f099afda0505c8/687474703a2f2f682e686970686f746f732e62616964752e636f6d2f696d6167652f772533443331302f7369676e3d62643935633438383762386461393737346532663830326138303530663837322f393038666130656330386661353133646431393236623635333536643535666262326662643935352e6a7067) ] ----------
# TF_QRScanner
* A fast integrated solution for QR scanner.
* 一种快速集成“二维码扫描器”的解决方案。
------------
# Demo screenshot
![screenshot1](https://camo.githubusercontent.com/a962cdb52445d57e5a4792c85d41a9f69b412da5/687474703a2f2f612e686970686f746f732e62616964752e636f6d2f696d6167652f772533443331302f7369676e3d36313061346234343333633739663364386665316532333138616130636462632f343361376439333363383935643134333035376365613938376266303832303235616166303730362e6a7067) ![screenshot2](https://camo.githubusercontent.com/a962cdb52445d57e5a4792c85d41a9f69b412da5/687474703a2f2f612e686970686f746f732e62616964752e636f6d2f696d6167652f772533443331302f7369676e3d36313061346234343333633739663364386665316532333138616130636462632f343361376439333363383935643134333035376365613938376266303832303235616166303730362e6a7067)

---
# 使用方法
### 一、扫描二维码
##### 1. 引用头文件：
`#import "TF_QRScanner.h"`
##### 2. 遵守代理协议：
`@interface ViewController () <TF_QRScannerDelegate>`
##### 3. 创建并设置扫描器：
```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // 1. 创建扫描器
    TF_QRScanner *QRScanner = [[TF_QRScanner alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];

    // 2. 配置扫描器（可选；不配置则为默认的参数。）
    // 设置扫描框（scanFrame.png）
    // QRScanner.scanFrameImage = [UIImage imageNamed:@"scanFrameCopy.png"];
    // 设置扫描线（scanLine.png）
    // QRScanner.scanLineImage = [UIImage imageNamed:@"scanLineCopy.png"];
    // 设置提示信息（如果不设置或设置为nil，则消息内容默认为：“请将扫描框对准二维码”。）
    // QRScanner.tipMessage = @"请将扫描框对准二维码";
    // 设置是否隐藏照明灯按钮（默认为NO，即不隐藏。）
    // QRScanner.hiddenLightingButton = YES;
    // 设置提扫描成功的提示方式（可选：仅声音、仅振动、声音和振动、无声音和振动，默认是：仅声音。）
    // QRScanner.playAudioMode = PlayAudioModeOnlyAudio;
    // 设置扫描线扫描一次所需要的时间（范围：0.5s ~ 5.0s，默认时间为：1.5s。）
    // QRScanner.scanTime = 1.5;
    // 设置扫描窗口中心位置（默认在扫描器图层中心）
    QRScanner.windowCenter = CGPointMake(CGRectGetMidX(QRScanner.bounds), CGRectGetMidY(QRScanner.bounds) - 50);

    // 3. 设置代理
    QRScanner.delegate = self;
    // 4. 添加到主视图
    [self.view addSubview:QRScanner];
    // 5. 开始扫描
    [QRScanner startScanning];
}
```
##### 4. 实现代理方法：
```objective-c
#pragma mark - 扫描器代理方法
// 扫描成功的回调
- (void)finishedScanningAndGotTheResult:(NSString *)result {
    NSLog(@"result: %@", result);
}
// 相机访问受限回调
- (void)accessDeviceIsRestrictedByStatus:(AVAuthorizationStatus)status {
    if (status == AVAuthorizationStatusRestricted) {
        // 受限制（没有发现相机或者相机被其它程序占用了）
        [[[UIAlertView alloc] initWithTitle:@"相机不可用" message:@"没有发现相机或者相机被其它程序占用了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    } else if (status == AVAuthorizationStatusDenied) {
        // 用户拒绝程序使用相机
        [[[UIAlertView alloc] initWithTitle:@"你已拒绝程序使用相机" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
    // 回到上一个界面
    [self.navigationController popViewControllerAnimated:YES];
}
```
------------
### 二、生成二维码图片
##### 1. API：
```objective-c
/** 生成二维码
 @param string 二维码内容
 @param size 二维码尺寸（宽度）
 @param logo logo图片（宽度为size的25%）
 @return 生成的二维码
 */
+ (UIImage *)createQRImageWithString:(NSString *)string size:(CGFloat)size logo:(UIImage *)logo;
```
##### 2. 调用示例：
```objective-c
NSString *content = @"Test content!";
UIImage *logo = [UIImage imageNamed:@"appIcon.png"];
UIImage *image = [TF_QRScanner createQRImageWithString:content size:150 logo:logo];
if (image) {
    NSLog(@"创建成功，image:%@", image);
} else {
    if (content.length == 0) {
        NSLog(@"传入的内容是空的！");
    } else {
        NSLog(@"传入的尺寸设置太小！");
    }
}
```
------------
### 二、解析图片中的二维码
##### 1. API：
```objective-c
/** 解析图片中的二维码
 @param image 二维码图片
 @param completion 解析完成后的回调
 @discussion 1.result为解析到的结果，msg为解析出错的提示信息。
 */
+ (void)parsingQRCodeImage:(UIImage *)image completion:(void(^)(NSString *result, NSString *msg))completion;
```
##### 2. 调用示例：
```objective-c
UIImage *image = [UIImage imageNamed:@"QRCodeImage.png"];
[TF_QRScanner parsingQRCodeImage:image completion:^(NSString *result, NSString *msg) {
    if (result.length == 0) {
        NSLog(@"未解析到内容：%@", msg);
    } else {
        NSLog(@"解析到内容：%@", result);
    }
}];
```
------------
# 版本信息
```objective-c
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
```
------------
# 结语
* 如本开源代码对你有帮助，请点击右上角的★Star，你的鼓励是我前进的动力；
* 如你对本代码有疑问或建议，欢迎issue，也可以将问题或建议发送至:teanfoo@outlook.com，我们互相帮助、共同进步。