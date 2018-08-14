//
//  ViewController.m
//  Realm数据库
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "Post.h"
#import "User.h"

@import Realm;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Post * post =[[Post alloc] initWithValue:@{@"title":@"untitled"}];
    User * user =[[User alloc]init];
    
    post.author = user;
    
    RLMRealm * r =[RLMRealm defaultRealm];
    
    [r transactionWithBlock:^{
        
        [r addObject:post];
        [r addObject:user];
        
        NSLog(@"%@",user.posts);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
