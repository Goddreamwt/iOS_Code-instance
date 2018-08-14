//
//  ViewController.m
//  ReactiveCocoa定位程序
//
//  Created by mac on 2017/7/14.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"

@import ReactiveCocoa;

@interface ViewController ()<CLLocationManagerDelegate>

@property (nonatomic,strong)CLLocationManager * manager;//位置管理器
@property (nonatomic) CLGeocoder * geocoder;//返地理位置编码
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;

@end

@implementation ViewController

-(CLLocationManager * )manager{
    
    if (!_manager) {
        
        _manager = [[CLLocationManager alloc]init];
        _manager.delegate = self;
    }
    return _manager;
}

-(CLGeocoder *)geocoder{
    
    if (!_geocoder) {
        
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}

-(RACSignal *)authorizedSignal{
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        
        [self.manager requestAlwaysAuthorization];
        
        return [[self rac_signalForSelector:@selector(locationManager:didChangeAuthorizationStatus:) fromProtocol:@protocol(CLLocationManagerDelegate)] map:^id(id value) {
            
            return @([value[1] integerValue] == kCLAuthorizationStatusAuthorizedAlways);
            
        }];
    }
    return [RACSignal return:@([CLLocationManager authorizationStatus]== kCLAuthorizationStatusAuthorizedAlways)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //    RACSequence * s1 = [[[@[@(1),@(2),@(3)] rac_sequence] map:^id(id value) {
    //
    //        return @([value integerValue]+2);
    //    }] filter:^BOOL(id value) {
    //
    //        return [value integerValue] <5;
    //    }];
    //
    //    NSLog(@"%@",[s1 array]);
    //    //3,4
    
    //    RACSequence * s1 = [@[@(1),@(2),@(3)] rac_sequence];
    //    RACSequence * s2 = [@[@(1),@(3),@(9)] rac_sequence];
    //
    //    RACSequence * s3 =[[@[s1,s2] rac_sequence] flattenMap:^RACStream *(id value) {
    //
    //        return [value filter:^BOOL(id value) {
    //
    //            return [value integerValue] % 3 ==0;
    //        }];
    //    }];
    //    NSLog(@"%@",[s3 array]);
    //    //3,3,9
    
    //知识点：获取某个对象的属性时，生成信号量
    //传统OC 使用KVO技术
    
    //    RAC  RACObserve观察者(对象，属性)
    //    RACSignal * signal = RACObserve(self, title);
    //
    //    [signal subscribeNext:^(id x) {
    //
    //
    //    }];
    
    //    常见的使用方式,进行绑定，将我们一个已知的属性绑定到另外一个对象的属性上
    //    RAC() = RACObserve(<#TARGET#>, <#KEYPATH#>)
    
    [[[[[self authorizedSignal] filter:^BOOL(id value) {
        
        return [value boolValue];
    }] flattenMap:^RACStream *(id value){
        
        return [[[[[[self rac_signalForSelector:@selector(locationManager:didUpdateLocations:) fromProtocol:@protocol(CLLocationManagerDelegate)] map:^id(id value) {
            
            return value[1];
        }] merge:[[self rac_signalForSelector:@selector(locationManager:didFailWithError:) fromProtocol:@protocol(CLLocationManagerDelegate)]map:^id(id value) {
            
            return [RACSignal error:value[1]];
        }]] take:1] initially:^{
            
            [self.manager startUpdatingLocation];
        }] finally:^{
            
            [self.manager stopUpdatingLocation];
        }];
    }] flattenMap:^RACStream *(id value) {
        
        CLLocation * location =[value firstObject];
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                
                if (error) {
                    
                    [subscriber sendError:error];
                }else{
                
                    [subscriber sendNext:[placemarks firstObject]];
                    [subscriber sendCompleted];
                }
            }];
            return [RACDisposable disposableWithBlock:^{
                
                
            }];
        }];
    }] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        self.placeLabel.text =[x addressDictionary][@"Name"];
        NSLog(@"地址%@",self.placeLabel.text);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
