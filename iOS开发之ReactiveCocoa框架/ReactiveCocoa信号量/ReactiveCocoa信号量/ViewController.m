//
//  ViewController.m
//  ReactiveCocoa信号量
//
//  Created by mac on 2017/7/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"

@import ReactiveCocoa;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //http://www.orzer.club/test.json
    
    [[self signalFormJson:@"http://www.orzer.club/test.json"] subscribeNext:^(id x) {
        
        NSLog(@"%@",x[@"data"]);
    } error:^(NSError * error){
    NSLog(@"%@",error);
    } completed:^{
        
        NSLog(@"错误");
    }];
    
    //第二个显著的优势就是信号量简化了多线程的操作的复杂程度
    //例如：
    RACSignal * s=[self signalFormJson:@"http://www.orzer.club/test.json"];
    RACSignal * s2=[self signalFormJson:@"http://www.orzer.club/test.json"];
    RACSignal * s3=[self signalFormJson:@"http://www.orzer.club/test.json"];
    
    //使用传统的GCD方式异步请求
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //网络请求
        
       dispatch_async(dispatch_get_main_queue(), ^{
           
          //主线程刷新UI
       });
    });
    
    //如果使用同步请求，三个请求完成以后再调用
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
       //并行操作一
       //如果并行操作里面，还是一个异步请求，甚至需要用同步锁这样的复杂技术
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
       //并行操作二
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
       //同步操作
    });
    
    //三个信号量的顺序执行，把三个信号量合并成一条管道
    [[s merge:s2] merge:s3];
    //三个信号量的串行
    [[[s then:^RACSignal *{
        
        return s2;
    }] then:^RACSignal *{
        
        return s3;
    }] subscribeNext:^(id x) {
        
        
    }];
    //同步,将三个信号量并行，三个请求完毕以后才交给订阅者
    [[RACSignal combineLatest:@[s,s2,s3]] subscribeNext:^(id x) {
        
        
    }];
}

-(RACSignal *)signalFormJson:(NSString *)urlStr{
 
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSURLSessionConfiguration * c =[NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession * session =[NSURLSession sessionWithConfiguration:c];
        NSURLSessionDataTask * data =[session dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if(error){
                [subscriber sendError:error];
            }else{
             
                NSError * e;
                NSDictionary * jsonDic =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
                if(e){
                    [subscriber sendError:e];
                }else{
                    [subscriber sendNext:jsonDic];
                    [subscriber sendCompleted];
                }
            }
        }];
        [data resume];
       return [RACDisposable disposableWithBlock:^{
           
           
       }];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
