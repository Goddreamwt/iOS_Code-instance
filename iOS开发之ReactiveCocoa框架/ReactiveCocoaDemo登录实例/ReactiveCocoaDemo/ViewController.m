//
//  ViewController.m
//  ReactiveCocoaDemo
//
//  Created by mac on 2017/7/7.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewViewController.h"

@import ReactiveCocoa;
@interface ViewController()
{

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self foo];
//    [ViewController instance];//函数名调用
//    [[self class] instance];  //使用自指针的class类调用
//    void(^foo)() = ^{
//    
//    };//block调用 块语法
//    foo();
//    UIButton * button =[UIButton buttonWithType:UIButtonTypeSystem];
//    [button addTarget:self action:@selector(top:) forControlEvents:UIControlEventTouchUpInside];
//    
//    //deleagte-协议模式
//    UITableView * tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
//    tableView.delegate = self;
//    tableView.dataSource = self;
//    
//    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
//    
//    NSBlockOperation * block =[NSBlockOperation blockOperationWithBlock:^{
//       
//    }];
//    [block start];
//    [[NSOperationQueue mainQueue] addOperation:block];
    
    
    /*
     ReactiveCocoa框架方式
     */
    //信号量
    RACSignal * viewDidAppearSiganl =[self rac_signalForSelector:@selector(viewDidAppear:)];
    
    [viewDidAppearSiganl subscribeNext:^(id x) {
        //会在每次viewDidAppear调用的时候，执行
        NSLog(@"打印日志：viewDidAppearSiganl-%s",__func__);
        NSLog(@"打印日志：参数-%@",x);
    }];
    
    [viewDidAppearSiganl subscribeError:^(NSError *error) {
        //订阅错误
        
    }];
    
    [viewDidAppearSiganl subscribeCompleted:^{
        
        //订阅完成状态
    }];
    
    UIButton * button =[UIButton buttonWithType:UIButtonTypeSystem];
    [button setRac_command:[[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"Clicked");

//            测试异步操作
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                LoginViewViewController * loginViewViewController =[[LoginViewViewController alloc]init];
                [self presentViewController:loginViewViewController animated:YES completion:nil];
                [subscriber sendNext:[[NSDate date] description]];//返回给当前的时间给订阅者
                [subscriber sendCompleted];//调用sendCompleted来结束这次按键的操作
            });
            return [RACDisposable disposableWithBlock:^{
                
                
            }];
        }];
    }]];
    [[[button rac_command] executionSignals] subscribeNext:^(id x) {
        
        [x subscribeNext:^(id x) {
            
            NSLog(@"%@",x);
        }];
    }];
    
    [button setTitle:@"点我" forState:UIControlStateNormal];
    [button setBounds:CGRectMake(0, 0, 100, 200)];
    [self.view addSubview:button];
    [button setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    NSLog(@"打印日志：%s",__func__);
}
//- foo{
//    return nil;
//}

//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 10;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
//    return cell;
//}
//-(void)top:(id)sender{
//
//}
////类方法
//+ instance {
//    return nil;
//}

@end
