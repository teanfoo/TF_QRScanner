//
//  TF_QRScanner.m
//  TF_QRCode
//
//  Created by apple on 16/7/27.
//  Copyright © 2016年 legentec. All rights reserved.
//

#import "TF_QRScanner.h"

@interface TF_QRScanner () <AVCaptureMetadataOutputObjectsDelegate>

@property (assign, nonatomic) BOOL isScanning;// 扫描器正在扫描

@property (assign, nonatomic) BOOL scanLineStopScanning;// 扫描线停止扫描

@property (assign, nonatomic) BOOL lightingIsTuenOn;// 照明灯开启

@property (strong, nonatomic) AVCaptureDevice *device;// 媒体设备

@property (strong, nonatomic) AVCaptureSession *session;// 会话

@property (strong, nonatomic) UIImageView *scanLine;// 扫描线

@property (strong, nonatomic) UIImageView *scanFrame;// 扫描框

@property (strong, nonatomic) UIView *coveringView;// 遮罩视图

@property (strong, nonatomic) UILabel *tipLabel;// 提示标签

@property (strong, nonatomic) UIButton *lightingButton;// 照明按钮

@property (strong, nonatomic) UILabel *lightingButtonLabel;// 照明按钮的标签

@end

@implementation TF_QRScanner

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void)removeFromSuperview {
    [self stopScanning];
    [super removeFromSuperview];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (id object in metadataObjects) {
        // 1. 判断扫描结果对象类型
        if (![object isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) return;// 不是机械可读码，则返回。
        
        // 2. 判断代理方法能否响应
        if (![self.delegate respondsToSelector:@selector(finishedScanningAndGotTheResult:)]) return;// 不能响应，则直接返回。
        
        // 3. 获取扫描结果
        AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)object;
        
        // 4. 播放提示音
        NSString *audioNamed = [@"TF_QRScanner.bundle" stringByAppendingPathComponent:@"di"];
        [self playAudioName:audioNamed andType:nil ByMode:self.playAudioMode];
        
        // 5. 移除扫描器
        [self removeFromSuperview];
        
        // 6. 通知代理扫描成功
        if ([self.delegate respondsToSelector:@selector(finishedScanningAndGotTheResult:)]) {
            [self.delegate finishedScanningAndGotTheResult:obj.stringValue];
        }
    }
}

#pragma mark - 自定义方法
/*!
 @method 开始扫描
 */
- (void)startScanning {
    if (self.isScanning) return;// 正在扫描则退出。
    self.isScanning = YES;
    
    // 检查媒体内容的访问权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted) {
        // 通知代理访问受限
        if ([self.delegate respondsToSelector:@selector(accessDeviceIsRestrictedByStatus:)]) {
            [self.delegate accessDeviceIsRestrictedByStatus:AVAuthorizationStatusRestricted];
        }
        return;// 受限制（可能是相机不可用）
    }
    else if(authStatus == AVAuthorizationStatusDenied) {// 被用户明确拒绝显示
        // 通知代理访问受限
        if ([self.delegate respondsToSelector:@selector(accessDeviceIsRestrictedByStatus:)]) {
            [self.delegate accessDeviceIsRestrictedByStatus:AVAuthorizationStatusDenied];
        }
        return;
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined) {// 用户未作出选择
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(!granted) {
                // 通知代理访问受限
                if ([self.delegate respondsToSelector:@selector(accessDeviceIsRestrictedByStatus:)]) {
                    [self.delegate accessDeviceIsRestrictedByStatus:AVAuthorizationStatusNotDetermined];
                }
                return ;// 用户选择了拒绝显示
            }
        }];
    }
    //    else if(authStatus == AVAuthorizationStatusAuthorized) // 允许显示媒体内容
    //        NSLog(@"允许显示媒体内容");
    
    // 1.获取输入设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2.创建输入对象
    NSError *error;
    AVCaptureDeviceInput *inPut = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    // 记录设备是否可用
    if (inPut == nil) {
        // 通知代理访问受限
        if ([self.delegate respondsToSelector:@selector(accessDeviceIsRestrictedByStatus:)]) {
            [self.delegate accessDeviceIsRestrictedByStatus:AVAuthorizationStatusRestricted];
        }
        return;
    }
    
    // 3.创建输出对象
    AVCaptureMetadataOutput *outPut = [[AVCaptureMetadataOutput alloc] init];
    
    // 4.设置代理监听输出对象的输出流
    //   使用主线程队列，相应比较同步；使用其他队列，相应不同步，影响用户体验。
    [outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 5.创建会话
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset1920x1080;// 提高画面质量，即使是很小的二维码也能快速扫描。
    
    // 6.将输入和输出对象添加到会话
    if ([self.session canAddInput:inPut]) {
        [self.session addInput:inPut];
    }
    if ([self.session canAddOutput:outPut]) {
        [self.session addOutput:outPut];
    }
    
    // 7.告诉输出对象, 需要输出什么样的数据  // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [outPut setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 8.创建预览图层
    // 注意: 预览层的frame一定是按比例（session.sessionPreset 设置的比例，这里设置的是1920x1080）显示的。
    AVCaptureVideoPreviewLayer *preViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preViewLayer.frame = CGRectMake(0,
                                    0,
                                    self.frame.size.width,// 限定宽度
                                    self.frame.size.width * (1920.0/1080.0) + 1);
    //    NSLog(@"preViewLayer.width:%f -- preViewLayer.height:%f",self.preViewLayer.frame.size.width, self.preViewLayer.frame.size.height);
    [self.layer insertSublayer:preViewLayer atIndex:0];
    
    // 9.设置扫描框、遮罩视图、提示标签、照明按钮、照明按钮的标签
    [self addSubview:self.scanFrame];// 扫描框
    [self addSubview:self.coveringView];// 遮罩视图
    [self addSubview:self.tipLabel];// 提示标签
    [self addSubview:self.lightingButton];// 照明按钮
    [self addSubview:self.lightingButtonLabel];// 照明按钮的标签
    
    // 10.设置扫面范围
    // 注意:
    // 1. rectOfInterest要求的CGRect格式为:CGRectMake(y, x, height, width);
    // 2. CGRectMake(）中参数取值范围都为比例值，即:0.0 ~ 1.0;
    // 3. CGRectMake(y, x, height, width),其中 y 表示:实际坐标y值 相对于 预览层高度 的比值; x, height, width也是照理类推。
    outPut.rectOfInterest = CGRectMake(self.scanFrame.frame.origin.y / preViewLayer.frame.size.height,
                                       self.scanFrame.frame.origin.x / preViewLayer.frame.size.width,
                                       self.scanFrame.frame.size.height / preViewLayer.frame.size.height,
                                       self.scanFrame.frame.size.width / preViewLayer.frame.size.width);
    
    
    // 开始扫描
    self.scanLineStopScanning = NO;
    [self.session startRunning];
    [self scanLineScanning];
}
/*!
 @method 停止扫描
 */
- (void)stopScanning {
    // 1. 关闭照明灯，并修改按钮的状态。
    if (self.lightingIsTuenOn) {// 如果照明是开启的，则关闭照明，并更改按钮的状态。
        NSString *imageNamed = [@"TF_QRScanner.bundle" stringByAppendingPathComponent:@"lightingOff"];
        [self.lightingButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];// 设置按钮的状态为关闭照明灯状态
        self.lightingIsTuenOn = NO;// 开灯标识置为NO
        self.lightingButtonLabel.text = @"开灯";
        
        [self.device lockForConfiguration:nil];// 锁定配置，申请控制设备。
        self.device.torchMode = AVCaptureTorchModeOff;// 关闭照明灯
        [self.device unlockForConfiguration];// 解锁配置，停止控制设备。
    }
    
    // 2. 扫描线停止扫描
    self.scanLineStopScanning = YES;
    
    // 3. 会话停止运行
    [self.session stopRunning];
    
    // 4. 扫描标识置为NO
    self.isScanning = NO;
}
/*!
 @method 扫描线循环扫描
 */
- (void)scanLineScanning {
    // 1. 过滤扫描时间
    if (self.scanTime < 0.5) {
        if (self.scanTime == 0.0)
            self.scanTime = 1.5;// 默认值为：1.5s
        else
            self.scanTime = 0.5;// 设置下限值为：0.5s
    }
    else if (self.scanTime > 5.0)
        self.scanTime = 5.0;// 设置上限值为：5.0s
    
    // 2. 执行一次扫描动作
    self.scanLine.hidden = NO;
    [UIView animateWithDuration:self.scanTime animations:^{
        self.scanLine.frame = CGRectMake(self.scanLine.frame.origin.x,
                                         self.scanFrame.frame.size.height - 5,// 移动到扫描框的最大y值处
                                         self.scanLine.frame.size.width,
                                         self.scanLine.frame.size.height);
    } completion:^(BOOL finished) {
        // 3. 完成一次扫描动作后，将扫描线放回原来的地方。
        self.scanLine.hidden = YES;
        self.scanLine.frame = CGRectMake(self.scanLine.frame.origin.x,
                                         - self.scanLine.frame.size.height,
                                         self.scanLine.frame.size.width,
                                         self.scanLine.frame.size.height);
        // 4. 检测是否需要再次扫描
        if (self.scanLineStopScanning) return;
        // 5. 延时一小段时间后再次进行扫描
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scanLineScanning];// 扫描
        });
    }];
}
/*!
 @method 这个方法用来播放提示音或（和）振动
 */
- (void)playAudioName:(nullable NSString *)audioName andType:(nullable NSString *)audioType ByMode:(PlayAudioMode)playAudioMode {
    if (playAudioMode == PlayAudioModeNoneAudioAndVibrate) return;// 不播放音频和振动
    
    // 1. 获取文件的全路径
    NSString *path;
    if (audioType == nil)
        path = [[NSBundle mainBundle] pathForResource:audioName ofType:@"wav"];
    else
        path = [[NSBundle mainBundle] pathForResource:audioName ofType:audioType];
    
    // 2. 创建 SystemSoundID 对象
    SystemSoundID soundID = 0;// 音效ID
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])// 文件存在
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);// 创建为系统音效
    else// 文件不存在
        playAudioMode = PlayAudioModeOnlyVibrate;// 仅播放振动
    
    // 3. 播放音频或（和）振动
    if (playAudioMode == PlayAudioModeOnlyAudio) {
        AudioServicesPlaySystemSound(soundID);// 仅播放音频
    }
    else if (playAudioMode == PlayAudioModeOnlyVibrate) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);// 仅播放振动
    }
    else if (playAudioMode == PlayAudioModeAudioAndVibrate) {
        AudioServicesPlayAlertSound(soundID);// 播放音频加振动
    }
}
/*!
 @method 点击了照明按钮
 */
- (void)onLightingButtonClick {
    // 1. 检测设备是否可用
    if (!self.device.hasTorch) return;// 设备没有照明灯组件
    
    // 2. 锁定配置，申请控制设备。
    [self.device lockForConfiguration:nil];
    
    // 3. 开启/关闭照明灯，并修改按钮的状态。
    if (self.lightingIsTuenOn) {// 如果照明是开启的，则关闭照明，并更改按钮的状态。
        NSString *imageNamed = [@"TF_QRScanner.bundle" stringByAppendingPathComponent:@"lightingOff"];
        [self.lightingButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];// 设置按钮的状态为关闭照明灯状态
        self.device.torchMode = AVCaptureTorchModeOff;// 关闭照明灯
        self.lightingIsTuenOn = NO;// 开灯标识置为NO
        self.lightingButtonLabel.text = @"开灯";
    }else {// 如果照明不是开启的，则开启照明，并更改按钮的状态。
        NSString *imageNamed = [@"TF_QRScanner.bundle" stringByAppendingPathComponent:@"lightingOn"];
        [self.lightingButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];// 设置按钮的状态为打开照明灯状态
        self.device.torchMode = AVCaptureTorchModeOn;// 打开照明灯
        self.lightingIsTuenOn = YES;// 开灯标识置为YES
        self.lightingButtonLabel.text = @"关灯";
    }
    
    // 4. 解锁配置，停止控制设备。
    [self.device unlockForConfiguration];
}

#pragma mark - 懒加载
- (UIImageView *)scanFrame {
    if (_scanFrame == nil) {// 用户没有设置扫描框
        _scanFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*self.frame.size.width-100, 0.5*self.frame.size.height-150, 200, 200)];
        
        if (self.scanFrameImage == nil)
            _scanFrame.image = [UIImage imageNamed:[@"TF_QRScanner.bundle" stringByAppendingPathComponent:@"scanFrame"]];
        else
            _scanFrame.image = self.scanFrameImage;
        
        _scanFrame.clipsToBounds = YES;// 设置自动裁剪
        _scanFrame.backgroundColor = [UIColor clearColor];
    }
    return _scanFrame;
}

- (UIImageView *)scanLine {
    if (_scanLine == nil) {// 用户没有设置扫描线
        _scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scanFrame.frame.size.width, 10)];// 根据扫描框的宽度设置frame
        
        if (self.scanLineImage == nil)
            _scanLine.image = [UIImage imageNamed:[@"TF_QRScanner.bundle" stringByAppendingPathComponent:@"scanLine"]];
        else
            _scanLine.image = self.scanLineImage;
        
        _scanLine.backgroundColor = [UIColor clearColor];
        [self.scanFrame addSubview:_scanLine];
    }
    return _scanLine;
}

- (UIView *)coveringView {
    if (_coveringView == nil) {
        _coveringView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _coveringView.backgroundColor = [UIColor clearColor];
        
        UIColor *coveringColor = [UIColor colorWithWhite:0.0/255.0 alpha:0.3];
        
        UIView *topCovering = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       self.frame.size.width,
                                                                       self.scanFrame.frame.origin.y)];
        topCovering.backgroundColor = coveringColor;
        
        UIView *leftCovering = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                        self.scanFrame.frame.origin.y,
                                                                        self.scanFrame.frame.origin.x,
                                                                        self.scanFrame.frame.size.height)];
        leftCovering.backgroundColor = coveringColor;
        
        UIView *bottomCovering = [[UIView alloc] initWithFrame:CGRectMake
                                  (0,
                                   self.scanFrame.frame.origin.y + self.scanFrame.frame.size.height,
                                   self.frame.size.width,
                                   self.frame.size.height - (self.scanFrame.frame.origin.y + self.scanFrame.frame.size.height))];
        bottomCovering.backgroundColor = coveringColor;
        
        UIView *rightCovering = [[UIView alloc] initWithFrame:CGRectMake
                                 (self.scanFrame.frame.origin.x + self.scanFrame.frame.size.width,
                                  self.scanFrame.frame.origin.y,
                                  self.frame.size.width - (self.scanFrame.frame.origin.x + self.scanFrame.frame.size.width),
                                  self.scanFrame.frame.size.height)];
        rightCovering.backgroundColor = coveringColor;
        
        [_coveringView addSubview:topCovering];
        [_coveringView addSubview:leftCovering];
        [_coveringView addSubview:bottomCovering];
        [_coveringView addSubview:rightCovering];
    }
    return _coveringView;
}

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.scanFrame.frame.origin.x,
                                                              self.scanFrame.frame.origin.y + self.scanFrame.frame.size.height,
                                                              self.scanFrame.frame.size.width,
                                                              30)];// 自身高度为20像素。
        _tipLabel.backgroundColor = [UIColor clearColor];
        if (self.tipMessage == nil)
            _tipLabel.text = @"请将扫描框对准二维码";
        else
            _tipLabel.text = self.tipMessage;
        
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    return _tipLabel;
}

- (UIButton *)lightingButton {
    if (_lightingButton == nil) {
        _lightingButton = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width-60)/2,
                                                                     self.frame.size.height-85,
                                                                     60,
                                                                     60)];
        _lightingButton.backgroundColor = [UIColor lightGrayColor];
        _lightingButton.hidden = self.hiddenLightingButton;
        NSString *imageNamed = [@"TF_QRScanner.bundle" stringByAppendingPathComponent:@"lightingOff"];
        [_lightingButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
        _lightingButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        _lightingButton.layer.masksToBounds = YES;
        _lightingButton.layer.cornerRadius = 15.0;
        [_lightingButton addTarget:self action:@selector(onLightingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lightingButton;
}

- (UILabel *)lightingButtonLabel {
    if (_lightingButtonLabel == nil) {
        _lightingButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake
                                (self.lightingButton.frame.origin.x,
                                 self.lightingButton.frame.origin.y + self.lightingButton.frame.size.height,
                                 self.lightingButton.frame.size.width,
                                 25)];
        _lightingButtonLabel.backgroundColor = [UIColor clearColor];
        _lightingButtonLabel.hidden = self.hiddenLightingButton;
        _lightingButtonLabel.text = @"开灯";
        _lightingButtonLabel.textColor = [UIColor whiteColor];
        _lightingButtonLabel.textAlignment = NSTextAlignmentCenter;
        _lightingButtonLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _lightingButtonLabel;
}
@end
