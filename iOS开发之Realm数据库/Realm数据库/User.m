//
//  User.m
//  Realm数据库
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "User.h"
#import "Post.h"

@implementation User

//反向关系
+ (NSDictionary<NSString *,RLMPropertyDescriptor *> *)linkingObejectsProperties{

    return @{
             @"posts" : [RLMPropertyDescriptor descriptorWithClass:Post.class propertyName:@"author"]
             };
}

@end
