//
//  HomeViewController.m
//  TF-Demo
//
//  Created by apple on 16/8/25.
//  Copyright © 2016年 legentec. All rights reserved.
//

#import "HomeViewController.h"
#import "ScanViewController.h"

@interface HomeViewController ()

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
    
    UIButton *testButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    testButton.center = self.view.center;
    testButton.backgroundColor = [UIColor blueColor];
    [testButton setTitle:@"扫一扫" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(goToScanView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 跳转
- (void)goToScanView {
    [self.navigationController pushViewController:[[ScanViewController alloc] init] animated:YES];
}
@end
