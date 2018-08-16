//
//  ViewController.m
//  BuglyDemo
//
//  Created by mac on 2018/8/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"
#import "WTAlertController.h"

@interface ViewController ()
@property(nonatomic,strong)WTAlertController *alertController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn =[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 60)];
    [btn setBackgroundColor:[UIColor redColor]];
    btn.titleLabel.text =@"点击崩溃";
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 =[[UIButton alloc]initWithFrame:CGRectMake(200, 100, 100, 60)];
    [btn2 setBackgroundColor:[UIColor grayColor]];
    btn.titleLabel.text =@"测试alert内存泄露";
    [btn2 addTarget:self action:@selector(btn2Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}
-(void)btnClick:(UIButton *)btn{
    NSArray * array =@[@1,@2,@3];
    NSLog(@"%@",array[4]);
}
-(void)btn2Click:(UIButton *)btn{
    NSLog(@"按钮2点击了，程序正在运行");
   
//    检测在程序不崩溃的情况下，alertController是否存在内存泄露
    self.alertController = [WTAlertController alertControllerWithTitle:@"内存泄露了嘛"
                                                               message:[NSString stringWithFormat:@"使用MLeaksFinder看看alertController是不是内存泄露了\n"]
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [self.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //设置占位符,键盘样式什么的。。。
    }];

    [self.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){

    }];
    __weak typeof(self.alertController) weakAlert = self.alertController;
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action) {
                                   __strong typeof(weakAlert) strongAlert = weakAlert;
                                                             [self doSomethingWithAccount:strongAlert.textFields.firstObject.text withPassword:strongAlert.textFields.lastObject.text];
                                                         }];

    [self.alertController addAction:cancelAction];
    [self.alertController addAction:deleteAction];

    [self presentViewController:self.alertController animated:NO completion:nil];
}

- (void)doSomethingWithAccount:(NSString *)account withPassword:(NSString *)password
{

    NSLog(@"点击继续");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
