//
//  DBInterface.m
//  chat
//
//  Created by samyoung79 on 10/04/2019.
//  Copyright © 2019 samyoung79. All rights reserved.
//

#import "DBInterface.h"
#import <sqlite3.h>

@interface DBInterface()
@end

@implementation DBInterface


+(instancetype)sharedManager
{
    static id sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
-(instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(BOOL)createTable:(NSString *)strTableName arg1:(NSString *)strFieldName1 agrg2:(NSString *)strFieldName2 arg3:(NSString *)strFieldName3
{
    char * err;
    sqlite3 * database;
    
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];  // 도큐먼트 디렉토리 위치를 얻는다.
    NSString * filePath = [documentsDirectory stringByAppendingPathComponent:@"silver.sqlite"];                                         // 도큐먼트 위치에 db.sqlite 명으로 파일 패스 설정
    
    if(sqlite3_open([filePath UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSLog(@"Error");
    }
    
    //SQL문
    NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY NOT NULL, '%@' TEXT NOT NULL, '%@' TEXT NOT NULL);",strTableName, strFieldName1, strFieldName2, strFieldName3];
    
    if(sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK){
        sqlite3_close(database);
        return NO;
    }
    
    return YES;
}

-(void)DropTable
{
    char * err;
    sqlite3 * database;
    
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];  // 도큐먼트 디렉토리 위치를 얻는다.
    NSString * filePath = [documentsDirectory stringByAppendingPathComponent:@"silver.sqlite"];                                         // 도큐먼트 위치에 db.sqlite 명으로 파일 패스 설정

    
    if(sqlite3_open([filePath UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSLog(@"Error");
    }
    
    //SQL문
    NSString * sql = [NSString stringWithFormat:@"delete from communication_log;"];
    
    if(sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK){
        sqlite3_close(database);
    }
}

-(NSArray *)selectTable
{
    sqlite3 * db;
    NSMutableArray * result = [NSMutableArray array];
    
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];  // 도큐먼트 디렉토리 위치를 얻는다.
    NSString * filePath = [documentsDirectory stringByAppendingPathComponent:@"silver.sqlite"];                                         // 도큐먼트 위치에 db.sqlite 명으로 파일 패스 설정
    const char * dbFile = [filePath UTF8String];

    if(sqlite3_open(dbFile, &db) == SQLITE_OK)
    {
        const char * sql = [[NSString stringWithFormat:@"SELECT * FROM communication_log;"]UTF8String];
        sqlite3_stmt * stmt;
        
        if(sqlite3_prepare(db, sql, -1, &stmt, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSInteger time = sqlite3_column_int(stmt, 0);
                NSString * fromUser = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
                NSString * contents = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
                
                NSDictionary * anItem = @{@"fromUser":fromUser,@"time":[NSNumber numberWithInteger:time], @"toUser":contents};
                [result addObject:anItem];
            }
            sqlite3_finalize(stmt);
        }
        sqlite3_close(db);
    }
    if([result count] == 0){
        return nil;
    }
    return result;
}

-(void)udpateRecordWithName:(NSString *)fromUser time:(int)timestamp toUser:(NSString *)contents;
{
    sqlite3 * db;
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];  // 도큐먼트 디렉토리 위치를 얻는다.
    NSString * filePath = [documentsDirectory stringByAppendingPathComponent:@"silver.sqlite"];                                         // 도큐먼트 위치에 db.sqlite 명으로 파일 패스 설정
    
    const char * dbFile = [filePath UTF8String];
    
    if(sqlite3_open(dbFile, &db) == SQLITE_OK)
    {
        sqlite3_stmt * insertStatement;
        NSString * query = [NSString stringWithFormat:@"INSERT INTO communication_log (fromUser,time,toUser) VALUES(\"%@\",%ld,\"%@\")",fromUser,timestamp,contents];
        
        char * err;
        int nResult = sqlite3_exec(db, [query UTF8String], NULL, NULL, &err);
        
        if(nResult != SQLITE_OK){
            NSLog(@"%d",nResult);
        }
    }
    sqlite3_close(db);
}

@end
