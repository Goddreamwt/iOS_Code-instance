//
//  AddViewController.m
//  NameList
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "AddViewController.h"
#import "SQLManager.h"
#import "StudentModel.h"

@interface AddViewController ()

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"AddUser"]) {
        
        //写入数据库
        StudentModel * model =[[StudentModel alloc]init];
        model.idNum = self.idNumTextField.text;
        model.name = self.nameTextField.text;
        
        [[SQLManager shareManager] insert:model];
    }
}
@end
