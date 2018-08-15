//
//  ViewController.m
//  BuglyDemo
//
//  Created by mac on 2018/8/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn =[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 60)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 =[[UIButton alloc]initWithFrame:CGRectMake(200, 100, 100, 60)];
    [btn2 setBackgroundColor:[UIColor grayColor]];
    [btn2 addTarget:self action:@selector(btn2Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}
-(void)btnClick:(UIButton *)btn{
    NSArray * array =@[@1,@2,@3];
    NSLog(@"%@",array[4]);
}
-(void)btn2Click:(UIButton *)btn{
    NSLog(@"按钮2点击了，程序正在运行");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
