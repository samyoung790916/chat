//
//  DBInterface.h
//  chat
//
//  Created by samyoung79 on 10/04/2019.
//  Copyright © 2019 samyoung79. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBInterface : NSObject

+(instancetype)sharedManager;
-(instancetype)init;


-(BOOL)createTable:(NSString *)strTableName arg1:(NSString *)strFieldName1 agrg2:(NSString *)strFieldName2 arg3:(NSString *)strFieldName3;
-(void)DropTable;
-(NSArray *)selectTable;
-(void)udpateRecordWithName:(NSString *)fromUser time:(int)timestamp toUser:(NSString *)contents;


@end

NS_ASSUME_NONNULL_END
