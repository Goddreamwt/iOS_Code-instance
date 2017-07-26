//
//  SQLManager.m
//  NameList
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "SQLManager.h"

@implementation SQLManager

//定义宏的目的在于：我们操作数据库就相当于对本地文件的一个处理，首先要获取文件路径，去拼接它的名字，所以为了方便以后我们调用这个文件，先把文件名取好
#define kNameFile (@"Student.sqlite")

//创建单例
static SQLManager * manager = nil;

+(SQLManager *)shareManager{

    static dispatch_once_t once;
    dispatch_once(&once,^{
    
        manager = [[self alloc] init];
        [manager createDataBaseTableIfNeeded];
    });
    return manager;
}

//获取数据库的完整路径
-(NSString *)applicationDocumentsDirectoryFile{

    NSArray * paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths firstObject];
    NSString * filePath = [documentDirectory stringByAppendingPathComponent:kNameFile];
    return filePath;
}

//再定义一个函数，接下来的操作是创建数据库，在进行数据库操作之前，确保数据库存在，不存在的时候必须要进行创建
- (void)createDataBaseTableIfNeeded{

    //虽然说我们的数据库是SQLite内置了，但是仍属于第三方，开发时如果想要使用它的类库，需要再进行配置添加
    //NameList配置文件-> TARGETS -> General -> LinkedFrameworks and Libraries,点击+号，搜书sqlit，选择libsqlite3.tbd。然后才能继续后续的操作。
    NSString * writetablePath =[self applicationDocumentsDirectoryFile];
    NSLog(@"数据库的地址是：%@",writetablePath);
    
    //打开数据库
    
    //第一个参数数据库文件所在的完整路径
    //第二个参数是数据库 DataBase 对象
    if (sqlite3_open([writetablePath UTF8String], &db) != SQLITE_OK) {
        
        //SQLITE_OK 是苹果为我们定义的一个常量如果是OK的话，就代表我们的数据库打开是成功了
        
        //失败
        //数据库关闭
        sqlite3_close(db);
        NSAssert(NO, @"数据库打开失败！");//抛出错误信息
        
    }else{
    
        //成功
        char * err;
        NSString * createSQL =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS StudentName (idNum TEXT PRIMARYKEY, name TEXT);"];
        //SQLite的执行函数
        /*
         第一个参数 db对象
         第二个参数 语句
         第三个和第四个参数 回调函数和回调函数参数
         第五个参数 是一个错误信息
         */
        if (sqlite3_exec(db, [createSQL UTF8String], NULL, NULL, &err) !=SQLITE_OK) {
            
            //失败
            //数据库关闭
            sqlite3_close(db);
            NSAssert1(NO, @"建表失败！%s", err);//抛出错误信息
        }
        sqlite3_close(db);
    }
    
}

//查询数据
/*
 1.使用sqlite3_prepare_v2函数预处理SQL语句
 2.使用sqlite3_bind_text函数绑定参数
 3.使用sqlite3_step函数执行SQL语句，遍历结果集
 4.使用sqlite3_column_text等函数提取字段数据
 */
- (StudentModel *)searchWithIDNum:(StudentModel *)model{

    NSString * path =[self applicationDocumentsDirectoryFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        
        sqlite3_close(db);
        NSAssert(NO, @"打开数据库失败!");
        
    }else{
    
        NSString * qsql =@"SELECT idNum,name FROM StudentName where idNum = ?";
        sqlite3_stmt * statement;//语句对象
        
        //第一个参数：数据库对象
        //第二个参数：SQL语句
        //第三个参数：执行语句的长度 -1是指全部长度
        //第四个参数：语句对象
        //第五个参数：没有执行的语句部分 NULL
        
        //预处理
        if(sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, NULL) ==SQLITE_OK){
        
           
            //进行 按主键查询数据库
            NSString * idNum = model.idNum;
            //第一个参数 语句对象
            //第二个参数 参数开始执行的序号
            //第三个参数 我们要绑定的值
            //第四个参数 绑定的字符串的长度
            //第五个参数 指针 NULL
            
            //绑定
            sqlite3_bind_text(statement, 1, [idNum UTF8String], -1, NULL);
            
            //遍历结果集
            /*
             有一个返回值 SQLITE_ROW常量代表查出来了
             */
            if (sqlite3_step(statement) == SQLITE_ROW) {
                
                //提取数据
                /*
                 第一个：语句对象
                 第二个：字段的索引
                 */
                char * idNum = (char *)sqlite3_column_text(statement, 0);
                //数据转化
                NSString * idNumStr =[[NSString alloc]initWithUTF8String:idNum];
                
                char * name =(char *)sqlite3_column_text(statement, 1);
                NSString * nameStr =[[NSString alloc]initWithUTF8String:name];
                
                
                StudentModel * model =[[StudentModel alloc] init];
                model.idNum = idNumStr;
                model.name = nameStr;
                
                //释放
                sqlite3_finalize(statement);
                sqlite3_close(db);
                return model;
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    return nil;
}

//修改
-(int)insert:(StudentModel *)model{

    NSString * path =[self applicationDocumentsDirectoryFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO, @"数据库打开失败!");
    }else{
        
        NSString * sql =@"INSERT OR REPLACE INTO StudentName (idNum, name) VALUES (?,?)";
        sqlite3_stmt * statement;
        //预处理过程
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) ==SQLITE_OK) {
            
            sqlite3_bind_text(statement, 1, [model.idNum UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [model.name UTF8String], -1, NULL);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                
                NSAssert(NO, @"插入数据失败!");
                
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
        }
        
    }
    return 0;
}

//删除
-(void)remove:(StudentModel *)model{

    /*
     第一步 sqlite3_open 打开数据库
     第二步 sqlite3_prepare_v2 预处理 SQL 语句操作
     第三步 sqlite3_bind_text 函数绑定参数
     第四步 sqlite3_step 函数执行 SQL 语句
     第五步 sqlite3_finalize 和 sqlite3_close 释放资源
     */
    NSString * path =[self applicationDocumentsDirectoryFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        
        sqlite3_close(db);
        NSAssert(NO, @"数据库打开失败");
    }else{

        NSString * sql =@"DELETE FROM StudentName where idNum = ?";
        sqlite3_stmt * statement;
        //预处理
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) ==SQLITE_OK) {
            
            sqlite3_bind_text(statement, 1, [model.idNum UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [model.name UTF8String], -1, NULL);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                
                NSAssert(NO, @"插入数据失败!");
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
        }
    }
}

@end
