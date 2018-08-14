//
//  LoginViewViewController.m
//  ReactiveCocoaDemo
//
//  Created by mac on 2017/7/7.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "LoginViewViewController.h"

@import ReactiveCocoa;//引用RAC

@interface LoginViewViewController ()
//原始方法：
//<UITextFieldDelegate>

@property(nonatomic,strong)UILabel * nameLabel;
@property(nonatomic,strong)UITextField * nameTextField;
@property(nonatomic,strong)UILabel * passwordLbale;
@property(nonatomic,strong)UITextField * passwordTextField;
@property(nonatomic,strong)UIButton * loginButton;

@end

@implementation LoginViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor =[UIColor whiteColor];
    
    [self createUI];
    
//    [self.nameTextField setDelegate:self];
//    [self.passwordTextField setDelegate:self];
//    self.loginButton.enabled = NO;
    
    //RAC方式
    /*
     //    展示：textField组件，RAC团队设置了一个专门取字符串的信号量。它跟应用回调去实现的方式是一样的
     [self.nameTextField.rac_textSignal subscribeNext:^(id x) {
     
     NSLog(@"%@",x);
     }];
     */
    
    /*
     //一个输入框的处理
     RACSignal * enableSignal =[self.nameTextField.rac_textSignal map:^id(NSString * value) {
     
     return @(value.length > 0);
     }];
     */
    RACSignal * enableSignal = [[RACSignal combineLatest:@[self.nameTextField.rac_textSignal,self.passwordTextField.rac_textSignal]] map:^id(id value) {
        NSLog(@"%@",value);
        return @([value[0] length]>0 && [value[1] length] >6);
    }];
    
    self.loginButton.rac_command =[[RACCommand alloc]initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        
        return [RACSignal empty];
    }];
}

//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    
//    NSString * str =[textField.text stringByReplacingCharactersInRange:range withString:string];
//    NSString * s1 =self.nameTextField.text;
//    NSString * s2 =self.passwordTextField.text;
//    
//    if (textField ==self.nameTextField) {
//        
//        s1 = str;
//    }else{
//        s2 = str;
//    }
//    
//    if (s1.length>0 && s2.length>6) {
//        
//        self.loginButton.enabled = YES;
//    }else{
//        self.loginButton.enabled = NO;
//    }
//    NSLog(@"%@,%@",s1,s2);
//   return YES;
//}

-(void)createUI{

    UIButton * backBtn =[UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn setRac_command:[[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [subscriber sendNext:[[NSDate date] description]];//返回给当前的时间给订阅者
            [subscriber sendCompleted];//调用sendCompleted来结束这次按键的操作
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }]];
    
    [backBtn setFrame:CGRectMake(15, 60, 100, 50)];
    backBtn.backgroundColor =[UIColor redColor];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    self.nameLabel =[[UILabel alloc]initWithFrame:CGRectMake(50, 200, 100, 40)];
    self.nameLabel.text = @"用户名:";
    self.nameLabel.textColor =[UIColor blueColor];
    [self.view addSubview:self.nameLabel];
    self.nameTextField =[[UITextField alloc]initWithFrame:CGRectMake(120, 200, 200, 40)];
    self.nameTextField.backgroundColor  =[UIColor grayColor];
    [self.view addSubview:self.nameTextField];
    
    self.passwordLbale =[[UILabel alloc]initWithFrame:CGRectMake(50, 260,100,40)];
    self.passwordLbale.text =@"密码：";
    self.passwordLbale.textColor =[UIColor blueColor];
    [self.view addSubview:self.passwordLbale];
    self.passwordTextField =[[UITextField alloc]initWithFrame:CGRectMake(120, 260, 200, 40)];
    self.passwordTextField.backgroundColor  =[UIColor grayColor];
    [self.view addSubview:self.passwordTextField];
    
    self.loginButton =[[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, 400, 100, 50)];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
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
