//
//  Post.h
//  Realm数据库
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Realm/Realm.h>
RLM_ARRAY_TYPE(Post);

@class User; //没有引用头文件是为了避免交叉引用

@interface Post : RLMObject

// id 主键
@property NSString * identifer;

//title 标题
@property NSString * title;

//author To-One 关系 对一关系
@property User * author;

//时间戳
@property NSDate * timestamp;

//内容
@property NSData * content;

//浏览量 //int long long long
@property NSInteger look;

//回帖 对多关系
@property RLMArray <Post*><Post> * comments;

//置顶 bool
@property NSNumber <RLMBool>*  isToop;

//不支持的类型 CGFloat ，请使用float，double  常量在Realm数据库里面是不可以为空的
@end
