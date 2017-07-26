# Code-instance-new
Store some code instances in iOS
iOS开发之SQLite

由简入繁地对SQLite中增、删、改、查的语法进行详细的讲解，并且以实例的形式演示在项目开发中对SQLite这四中语法的使用。步骤清晰、易懂，很容易就能上手。
优点：占用资源低，可移植性强，速度快 SQLite目前版本是SQLite3，我们使用的mac系统默认是会安装SQLite，所以我们iOS也内置了SQLite，我们可以直接调用SQLite的API进行开发就好。而且它植入到我们的进程空间，我不需要进行跨进程处理，这样也提升了我们的处理速度。 

一、数据类型及指令 INTEGER 有符号整型 REAL 浮点型 TEXT 字符串型，采用UTF-8,UTF-16编码 BLOB 大二进制对象类型，能够存放任何二进制数据 VARCHAR CHAR CLOB 转换成TEXT类型 FLOAT DOUBLE 转换成REAL NUMERIC 转换成 INTEGER 或者 REAL类型 注意：没有布尔类型数据 用整数0或者1代替 没有日期、时间类型数据 存储在TEXT、REAL类型中 SQLite语句 
1.创建数据表 指令： create table 表名（字段1，字段2，…）; 实例：create table USER(uid,name); 
2.条件创建：如果不存在则创建 指令：create table if not exists 表名（字段1，字段2,…）； 实例：create table if not exists USER(uid,name );
3.删除表 指令：drop table 表名; 实例：drop table USER; 
4.插入 指令：insert into 表名（字段1，字段2，…）values(值1，值2,…); 实例: insert into USER(uid,name)values(0,’慕课网’);
5.查询 指令：select 字段 from 表名; 实例：slect * from USER;
6.修改 指令：update 表名 set 字段 = ‘新值’ where 条件 实例：update USER set name = ‘Keegan’ where uid = 3;

二、打开数据库 创建数据库 1.使用sqlite3_open函数打开数据库 2.使用sqlite3_exe函数执行Create Table语句 3.使用sqliete3_close函数释放资源
