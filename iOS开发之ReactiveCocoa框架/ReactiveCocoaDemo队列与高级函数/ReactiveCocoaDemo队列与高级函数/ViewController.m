//
//  ViewController.m
//  ReactiveCocoaDemo队列与高级函数
//
//  Created by mac on 2017/7/14.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"

@import ReactiveCocoa;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //push-driven pull-driven 两种类型驱动的模型
    //拉驱动        推驱动
    
//    __block int a =10;
//    RACSignal * s=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        
//        //只有订阅者有订阅，block代码才执行。只有需求者有需求，生产者才能去生产，所以是一种拉动驱动的模式
//        a += 5;
//        
//        [subscriber sendNext:@(a)];
//        [subscriber sendCompleted];
//        
//        return [RACDisposable disposableWithBlock:^{
//            
//        }];
//    }] replayLast];
//    //replayLast 规避副作用，标识Signal是记录型的，它只是记录方法返回的值，而不会再次调用
//    
//    [s subscribeNext:^(id x) {
//        
//        NSLog(@"%@",x);
//    }];
//    
//    //第二次去订阅或者在不同的地方订阅
//    [s subscribeNext:^(id x) {
//        
//        NSLog(@"%@",x);
//    }];
    
    /*
     side effect 副作用
     在每次订阅信号量的时候，会导致信号量里面的代码重复的执行
     副作用有些地方是可以利用的，但是有些时候就需要规避它
     */
    
    /*
     RACSequence 也是继承与RACStream，本质上也是一种流
     与RACSignal的区别  它是一种推驱动，就是在它初始化的时候，内容就已经形成了，而RACSignal是在订阅的时候才会生成内容
     */
//    RACSequence * seq =[s sequence];
//    [seq signal];
    //RACSequence 与 signal 可以互相转换 意义是：例如signal是工厂的源头，转换成sequence的意义就是将生产出来的产品放在一个序列，放在一个容器里。
    //相反sequence转换signal：则是生产好的产品按照序列放到一个特即将发送的管道，去做为这个管道的发送源
    //从另外一个角度看，sequence队列实际是RAC世界里面的数组容器跟OC里面的NSArray是可以进行无缝转换的
    NSArray * array =@[@(1),@(2),@(3),@(4),@(5)];
    //数组转换成队列
     RACSequence * seq1 =[array rac_sequence];
    
    //队列转换成数组
//    [seq1 array];
    
    //map,filter,flattenMap,concat...
    //map映射
    NSArray * array1= [[seq1 map:^id(id value) {
        
        return @([value integerValue] * 3);
    }] array];
    NSLog(@"%@",array1);
    
    //filter筛选工作
    
    NSArray * array2 =[[seq1 filter:^BOOL(id value) {
        //返回布尔类型，表示队列里面是否还存留这个值
        return [value integerValue]%2 ==1;
    }] array];
    NSLog(@"%@",array2);
    
    //flattenMap整个RAC里面最重要的一个高级函数，但是实际应用到的地方很少，主要是RAC里面自己功能的实现 flattenMap先执行Map再执行flatten
    
//    [1,2]
//    [3,4]
//    [[1,2],[3,4]] 通过 flatten操作以后 转换成 [1,2,3,4]
    
//    concat 链接两个sequence
//      [1,2], [3,4]
//      [1,2,3,4]
//    RACSignal * s;
//    [s then:^RACSignal *{
//        
//        //忽略Signal再次订阅的方法
//    }];
    RACSignal * s1;
    RACSignal * s2;
    [[s1 concat:s2] subscribeNext:^(id x) {
        
        //s1 s2都会返回
    }];//串行Signal
    //与then的去呗
    [[s1 then:^RACSignal *{
        
        return s2;
    }] subscribeNext:^(id x) {
        
       //只会返回s2
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
