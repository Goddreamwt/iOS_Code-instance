//
//  Post.m
//  Realm数据库
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "Post.h"
#import "User.h"

@implementation Post

//可空属性，决定属性是否可以为nil
+ (NSArray<NSString *> *)requiredProperties{

    return @[@"title"];
}

//忽略属性
+ (NSArray<NSString *> *)ignoredProperties{

    return @[];
}

//默认值
+ (NSDictionary *)defaultPropertyValues{

    return @{@"look":@(0)};
}

//索引属性 支持NSString,NSNumber(包括常量),NSDate
+(NSArray<NSString *> *)indexedProperties{

    return @[@"title",@"timestamp"];
}

//主键 唯一性
+ (NSString *)primaryKey{

    return @"identifer";
}





@end
