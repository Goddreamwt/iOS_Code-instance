//
//  SQLManager.h
//  NameList
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "StudentModel.h"

@interface SQLManager : NSObject{

    sqlite3 * db;
}

+(SQLManager *)shareManager;

//查询
- (StudentModel *)searchWithIDNum:(StudentModel *)model;

//插入
-(int)insert:(StudentModel *)model;

//删除
-(void)remove:(StudentModel *)model;

//修改
-(void)modify:(StudentModel *)model;

@end
