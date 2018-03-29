//
//  HomeViewController.m
//  TF-Demo
//
//  Created by apple on 16/8/25.
//  Copyright © 2016年 legentec. All rights reserved.
//

#import "HomeViewController.h"
#import "ScanViewController.h"
#import "TF_QRScanner.h"

@interface HomeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"首页";
    
    // 隐藏导航栏按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    // 扫描二维码
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake((width - 200) / 2, height * 0.2, 200, 40)];
    btn1.layer.cornerRadius = 5.0;
    btn1.backgroundColor = [UIColor colorWithRed:118/255.0 green:143/255.0 blue:101/255.0 alpha:1];
    [btn1 setTitle:@"扫描二维码" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(goToScanView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    // 生成二维码
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake((width - 200) / 2, height * 0.35, 200, 40)];
    btn2.layer.cornerRadius = 5.0;
    btn2.backgroundColor = [UIColor colorWithRed:176/255.0 green:96/255.0 blue:63/255.0 alpha:1];
    [btn2 setTitle:@"生成二维码" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(createQRCodeImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    // 识别相册中的二维码
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake((width - 200) / 2, height * 0.5, 200, 40)];
    btn3.layer.cornerRadius = 5.0;
    btn3.backgroundColor = [UIColor colorWithRed:237/255.0 green:85/255.0 blue:54/255.0 alpha:1];
    btn3.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn3 setTitle:@"识别相册中的二维码" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(parsingQRCodeImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    // 二维码图片展示视图
    UIImageView *imagaeView = [[UIImageView alloc] initWithFrame:CGRectMake((width - 150) / 2, height * 0.65, 150, 150)];
    imagaeView.userInteractionEnabled = YES;
    [self.view addSubview:imagaeView];
    self.imageView = imagaeView;
    // 添加长安手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
    [self.imageView addGestureRecognizer:longPress];
    // 长按二维码可识别内容 提示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((width - 150) / 2, CGRectGetMaxY(imagaeView.frame) + 5, 150, 15)];
    label.layer.cornerRadius = 7.5;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:10.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"长按二维码可识别内容";
    label.hidden = YES;
    [self.view addSubview:label];
    self.label = label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event
- (void)goToScanView {// 扫描二维码
    [self.navigationController pushViewController:[[ScanViewController alloc] init] animated:YES];
}
- (void)createQRCodeImage {// 生成二维码
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入内容" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.returnKeyType = UIReturnKeyDone;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *content = alert.textFields.firstObject.text;
        UIImage *logo = [UIImage imageNamed:@"LaunchImage"];
        UIImage *image = [TF_QRScanner createQRImageWithString:content size:150 logo:logo];
        if (image) {
            NSLog(@"image:%@", image);
            self.imageView.image = image;
            self.label.hidden = NO;
        } else {
            NSString *message;
            if (content.length == 0) message = @"二维码内容是空的！";
            else message = @"二维码尺寸设置太小！";
            [[[UIAlertView alloc] initWithTitle:@"创建失败" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)parsingQRCodeImage {// 识别相册中的二维码
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
- (void)longPressEvent:(UILongPressGestureRecognizer *)sender {// 长按了二维码图片
    if (self.imageView.image == nil) return;
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIImage *image = self.imageView.image;
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"保存到系统相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"识别二维码" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [TF_QRScanner parsingQRCodeImage:image completion:^(NSString *result, NSString *msg) {
                NSString *message = result.length == 0 ? msg : result;
                [[[UIAlertView alloc] initWithTitle:@"识别结果" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            }];
        }]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
// 保存图片操作的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"保存图片出错" message:error.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
}
// 选中了照片的回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *resultImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [TF_QRScanner parsingQRCodeImage:resultImage completion:^(NSString *result, NSString *msg) {
            NSString *message = result.length == 0 ? msg : result;
            [[[UIAlertView alloc] initWithTitle:@"识别结果" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }];
    }];
}
// 取消选择照片的回调
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
