//
//  UncaughtExceptionHandler.m
//  UncaughtExceptionHandler
//
//  Created by chuzhaozhi on 2018/6/4.
//  Copyright © 2018年 JackerooChu. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "WTAlertController.h"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";//未捕获的异常处理程序信号异常名称
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

//捕获的异常的数量
volatile int32_t UncaughtExceptionCount = 0;
//捕获的异常的最大数量
const int32_t UncaughtExceptionMaximum = 10;

static BOOL showAlertView = nil;

void HandleException(NSException *exception);
void SignalHandler(int signal);
NSString* getAppInfo(void);


@interface UncaughtExceptionHandler()
@property (assign, nonatomic) BOOL dismissed;
@property (strong, nonatomic) UIAlertController *alertController;
@end

@implementation UncaughtExceptionHandler
/*
 *  异常的处理方法
 *
 *  @param install   是否开启捕获异常
 *  @param showAlert 是否在发生异常时弹出alertView
 */
+ (void)installUncaughtExceptionHandler:(BOOL)install showAlert:(BOOL)showAlert {
    
    if (install && showAlert) {
        [[self alloc] alertView:showAlert];
    }
    //1.发送异常信号
    NSSetUncaughtExceptionHandler(install ? HandleException : NULL);
    //FOUNDATION_EXPORT void NSSetUncaughtExceptionHandler(NSUncaughtExceptionHandler * _Nullable);
    //typedef void NSUncaughtExceptionHandler(NSException *exception);
    /*
     @interface NSException : NSObject <NSCopying, NSCoding> {
     @private
     NSString        *name;
     NSString        *reason;
     NSDictionary    *userInfo;
     id            reserved;
     }
     */
    signal(SIGABRT, install ? SignalHandler : SIG_DFL);
    signal(SIGILL, install ? SignalHandler : SIG_DFL);
    signal(SIGSEGV, install ? SignalHandler : SIG_DFL);
    signal(SIGFPE, install ? SignalHandler : SIG_DFL);
    signal(SIGBUS, install ? SignalHandler : SIG_DFL);
    signal(SIGPIPE, install ? SignalHandler : SIG_DFL);
    
    //产生上述的signal的时候就会调用我们定义的SignalHandler来处理异常。
    //NSSetUncaughtExceptionHandler就是iOS SDK中提供的一个现成的函数,用来捕获异常的方法，使用方便。但它不能捕获抛出的signal，所以定义了SignalHandler方法。
}
-(void)dealloc{
    NSLog(@"执行了");
}
- (void)alertView:(BOOL)show {
    
    showAlertView = show;
}

//处理报错信息
- (void)validateAndSaveCriticalApplicationData:(NSException *)exception {
    
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"\n--------Log Exception---------\nappInfo             :\n%@\n\nexception name      :%@\nexception reason    :%@\nexception userInfo  :%@\ncallStackSymbols    :%@\n\n--------End Log Exception-----", getAppInfo(),exception.name, exception.reason, exception.userInfo ? : @"no user info", [exception callStackSymbols]];
    
    NSLog(@"%@", exceptionInfo);
    //	[exceptionInfo writeToFile:[NSString stringWithFormat:@"%@/Documents/error.log",NSHomeDirectory()]  atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

//4.堆栈调用
//backtrace是Linux下用来追踪函数调用堆栈以及定位段错误的函数。
//获取调用堆栈
+ (NSArray *)backtrace {
    
    //指针列表
    void* callstack[128];
    //backtrace用来获取当前线程的调用堆栈，获取的信息存放在这里的callstack中
    //128用来指定当前的buffer中可以保存多少个void*元素
    //返回值是实际获取的指针个数
    int frames = backtrace(callstack, 128);
    //backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组
    //返回一个指向字符串数组的指针
    //每个字符串包含了一个相对于callstack中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < frames; i++) {
        
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}
//5.使用UIAlerView进行友好化提示
//在这里你可以做自己的crash收集操作，例如上传服务器等。
- (void)handleException:(NSException *)exception {
    
    [self validateAndSaveCriticalApplicationData:exception];
    
    if (!showAlertView) {
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    self.alertController = [WTAlertController alertControllerWithTitle:@"程序异常"
                                                                             message:[NSString stringWithFormat:@"您可以继续操作，或者退出重新进入，此异常已经记录在案，我们将尽快修复！感谢您的使用！.\n"]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
       
         self.dismissed = YES;
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action) {
                                         
                         NSLog(@"点击继续");
                                                         }];
    
    [self.alertController addAction:cancelAction];
    [self.alertController addAction:deleteAction];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentViewController:self.alertController animated:NO completion:nil];
    
#pragma clang diagnostic pop
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!self.dismissed) {
        //点击继续
        for (NSString *mode in (__bridge NSArray *)allModes) {
            //快速切换Mode
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    //点击退出
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
        
    } else {
        
        [exception raise];
    }
}

@end


//2.处理异常
//该方法就是对应NSSetUncaughtExceptionHandler的处理，只要方法关联到这个函数，那么发生相应错误时会自动调用该函数，调用时会传入exception参数。获取异常后会将捕获的异常传入最终调用处理的handleException函数。
void HandleException(NSException *exception) {
    
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    //获取调用堆栈
    NSArray *callStack = [exception callStackSymbols];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    //在主线程中，执行制定的方法, withObject是执行方法传入的参数
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:[exception name]
                             reason:[exception reason]
                           userInfo:userInfo]
     waitUntilDone:YES];
    
    
 
}
//3.无法捕获的signal处理
//处理signal报错
void SignalHandler(int signal) {
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    //以下方法是对于捕获不到的signal信号进行处理，列出常见的异常类型。
    NSString* description = nil;
    switch (signal) {
        case SIGABRT:
            description = [NSString stringWithFormat:@"Signal SIGABRT was raised!\n"];
            break;
        case SIGILL:
            description = [NSString stringWithFormat:@"Signal SIGILL was raised!\n"];
            break;
        case SIGSEGV:
            description = [NSString stringWithFormat:@"Signal SIGSEGV was raised!\n"];
            break;
        case SIGFPE:
            description = [NSString stringWithFormat:@"Signal SIGFPE was raised!\n"];
            break;
        case SIGBUS:
            description = [NSString stringWithFormat:@"Signal SIGBUS was raised!\n"];
            break;
        case SIGPIPE:
            description = [NSString stringWithFormat:@"Signal SIGPIPE was raised!\n"];
            break;
        default:
            description = [NSString stringWithFormat:@"Signal %d was raised!",signal];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    [userInfo setObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    
    //在主线程中，执行指定的方法, withObject是执行方法传入的参数
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                             reason: description
                           userInfo: userInfo]
     waitUntilDone:YES];
}

NSString* getAppInfo() {
    
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion];
    return appInfo;
}

