//
//  HomeViewController.m
//  NameList
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "HomeViewController.h"
#import "StudentModel.h"
#import "SQLManager.h"

@interface HomeViewController ()

@property (nonatomic,strong) NSMutableArray * studentArray; //数据源 —— 模型

@end

#define HomeCellIdentifier (@"StudentCell")

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.studentArray =[[NSMutableArray alloc]init];
    NSLog(@"%@",self.studentArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.studentArray.count >0) {
        
         return self.studentArray.count;
    }else{
    
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeCellIdentifier forIndexPath:indexPath];

    //等待给cell赋值
    if(self.studentArray.count > 0){
    
        StudentModel * model =[self.studentArray objectAtIndex:indexPath.row];
        cell.textLabel.text = model.name;
        cell.detailTextLabel.text = model.idNum;
    }
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //支持编辑
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 50;
}

-(IBAction)addUserDone:(UIStoryboardSegue *)sender{

    StudentModel * model =[[StudentModel alloc]init];
    model.idNum = @"100";
    StudentModel * result = [[SQLManager shareManager] searchWithIDNum:model];
    NSLog(@"%@",result);
    [self.studentArray addObject:result];
    [self.tableView reloadData];
}






@end
