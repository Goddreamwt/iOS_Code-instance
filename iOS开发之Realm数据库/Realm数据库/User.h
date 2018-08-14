//
//  User.h
//  Realm数据库
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Realm/Realm.h>
#import "Post.h"

@interface User : RLMObject

@property NSString * nickname;

//to-Many 对多 关系
@property (readonly) RLMLinkingObjects * posts;

@end
