//
//  ViewController.m
//  ReactiveCocoa实例之颜色选择器
//
//  Created by mac on 2017/7/11.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"

@import ReactiveCocoa;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *rLable;
@property (weak, nonatomic) IBOutlet UILabel *gLable;
@property (weak, nonatomic) IBOutlet UILabel *blable;
@property (weak, nonatomic) IBOutlet UISlider *rSlider;
@property (weak, nonatomic) IBOutlet UISlider *gSlider;
@property (weak, nonatomic) IBOutlet UISlider *bSlider;
@property (weak, nonatomic) IBOutlet UITextField *rTextFilde;
@property (weak, nonatomic) IBOutlet UITextField *GTextFilld;
@property (weak, nonatomic) IBOutlet UITextField *BTextField;
@property (weak, nonatomic) IBOutlet UIView *showView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.rTextFilde.text = self.GTextFilld.text = self.BTextField.text = @"0.5";
    
    RACSignal * rSignal= [self blindSlider:self.rSlider textFilde:self.rTextFilde];
    RACSignal * gSignal= [self blindSlider:self.gSlider textFilde:self.GTextFilld];
    RACSignal * bSignal= [self blindSlider:self.bSlider textFilde:self.BTextField];
    
    /*
     //方式一
     [[[RACSignal combineLatest:@[rSignal,gSignal,bSignal]] map:^id(id value) {
     
     return [UIColor colorWithRed:[value[0]floatValue] green:[value[2]floatValue] blue:[value[1]floatValue] alpha:1.0f];
     }] subscribeNext:^(id x) {
     
     //注意RAC的回调一般都不是主线程，需要回到主线程以避免不必要的BUG
     
     dispatch_async(dispatch_get_main_queue(), ^{
     
     self.showView.backgroundColor = x;
     });
     }];
     */
    
    //方式二
    RACSignal * changeValueSignal = [[RACSignal combineLatest:@[rSignal,gSignal,bSignal]] map:^id(id value) {
        
        return [UIColor colorWithRed:[value[0]floatValue] green:[value[2]floatValue] blue:[value[1]floatValue] alpha:1.0f];
    }];
    RAC(self.showView,backgroundColor) = changeValueSignal;
}
-(RACSignal* )blindSlider:(UISlider *)slider textFilde:(UITextField*)textField{

    //textField触发一次且仅触发一次
    RACSignal * textSignal =[[textField rac_textSignal] take:1];
    //信号量的端，理解为一个频道的端点
    RACChannelTerminal * signaSlider =[slider rac_newValueChannelWithNilValue:nil];
    RACChannelTerminal * signalText = [textField rac_newTextChannel];
    
    [signalText subscribe:signaSlider];
    
    [[signaSlider map:^id(id value) {
        
        return  [NSString stringWithFormat:@"%.02f",[value floatValue]];
    }] subscribe:signalText];
    return [[signalText merge:signaSlider] merge:textSignal];
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

@end
