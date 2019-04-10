//
//  ViewController.h
//  chat
//
//  Created by samyoung79 on 05/04/2019.
//  Copyright © 2019 samyoung79. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

#import "ZHCMessages.h"
#import "ZHCModelData.h"


@interface WebServices : NSObject
+(instancetype)sharedManager;
-(instancetype)init;
-(void)request:(NSString *)operation argment:(NSDictionary *)params complete:(void (^)(NSArray * list, NSError * error))completeHandler;
-(NSArray *)methodUsingJsonFromSuccessBlock:(NSData *)data;
@end



@interface ViewController : ZHCMessagesViewController<ZHCAudioMediaItemDelegate>
@property (strong, nonatomic) ZHCModelData *demoData;
@property (assign, nonatomic) BOOL presentBool;


@end

