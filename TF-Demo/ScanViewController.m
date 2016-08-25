//
//  ScanViewController.m
//  TF-Demo
//
//  Created by apple on 16/8/25.
//  Copyright © 2016年 legentec. All rights reserved.
//

#import "ScanViewController.h"
#import "TF_QRScanner.h"

@interface ScanViewController () <UIWebViewDelegate, TF_QRScannerDelegate>

@property (strong, nonatomic) UITextView *resultInfo;// 扫描结果信息的展示视图

@property (strong, nonatomic) UIButton *loadWebPageButton;// 加载网页的按钮

@property (strong, nonatomic) UIWebView *webView;// 网页浏览器

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];// 设置背景色
    self.navigationItem.title = @"扫一扫";// 设置标题
    // 去掉导航栏返回按钮的文字
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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

#pragma mark - 按钮的点击事件loadWebPage
- (void)loadWebPage {
    self.navigationItem.title = @"加载中...";// 设置标题
    // 设置请求参数
    NSURL *url = [NSURL URLWithString:self.resultInfo.text];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:10.0];
    
    [self.webView loadRequest:request];
}
#pragma mark - webviewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.title = @"浏览网页";// 设置标题
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    self.navigationItem.title = @"加载失败";// 设置标题

}
#pragma mark - 懒加载
- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)]; 
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}
- (UITextView *)resultInfo {
    if (_resultInfo == nil) {
        _resultInfo = [[UITextView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 100, 200)];
        _resultInfo.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _resultInfo.font = [UIFont systemFontOfSize:14.0];
        _resultInfo.textAlignment = NSTextAlignmentLeft;
        _resultInfo.editable = NO;
        _resultInfo.selectable = YES;
        _resultInfo.layer.cornerRadius = 5.0;
        _resultInfo.layer.borderWidth = 2;
        _resultInfo.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self.view addSubview:_resultInfo];
    }
    return _resultInfo;
}
- (UIButton *)loadWebPageButton {
    if (_loadWebPageButton == nil) {
        _loadWebPageButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2,
                                                                       330,
                                                                       100,
                                                                       44)];
        [_loadWebPageButton setBackgroundColor:[UIColor blueColor]];
        [_loadWebPageButton setHidden:YES];
        [_loadWebPageButton setTitle:@"加载网页" forState:UIControlStateNormal];
        [_loadWebPageButton.layer setCornerRadius:5.0];
        [_loadWebPageButton addTarget:self action:@selector(loadWebPage) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_loadWebPageButton];
    }
    return _loadWebPageButton;
}

@end
