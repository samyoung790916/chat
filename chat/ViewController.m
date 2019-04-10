//
//  ViewController.m
//  chat
//
//  Created by samyoung79 on 05/04/2019.
//  Copyright © 2019 samyoung79. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>



@implementation WebServices

NSString * baseUrl = @"http://35.194.195.240/service/";

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
-(void)request:(NSString *)operation argment:(NSDictionary *)params complete:(void (^)(NSArray * list, NSError * error))completeHandler{
    
    NSString * method = [NSString stringWithFormat:@"%@%@",baseUrl,operation];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer.acceptableContentTypes = nil;
    
    
    [manager POST:method parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(completeHandler){
            completeHandler(responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(completeHandler) {
            completeHandler(nil, error);
        }
    }];
}

-(NSArray *)methodUsingJsonFromSuccessBlock:(NSData *)data
{
    NSError * error = nil;
    NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
    return jsonArray;
}
@end





@interface ViewController (){
    ZHCAudioMediaItem * currentAudioItem;
    NSTimer * timer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
    NSDictionary * param = @{@"clientid":@"dss_dasom2"};
    NSMutableDictionary * json = [NSMutableDictionary new];
    
    [[WebServices sharedManager]request:@"prevchats" argment:param complete:^(NSArray *list, NSError *error) {
        
        int a = 100;
    }];
    
    
    
    
    
    self.messageTableView.estimatedRowHeight = 50.0f;

    [[AVAudioSession sharedInstance]requestRecordPermission:^(BOOL granted) {
        if (!granted){
            UIAlertView * alertview = [[UIAlertView alloc]initWithTitle:@"Remind" message:@"The microphone cannot access will affect the recording function!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

            [alertview show];
        }
    }];

    self.demoData = [[ZHCModelData alloc]init];
    self.title = @"ZHCMessages";

    ZHCWeakSelf;

    if(self.automaticallyScrollsToMostRecentMessage){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf scrollToBottomAnimated:NO];
        });

    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.presentBool){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePresseed:)];
    }
}

#pragma mark - PrivateMethods
-(void)closePressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - ZHCMessagesTableViewDataSource

-(NSString *)senderDisplayName
{
    return kZHCDemoAvatarIdJobs;
}

-(NSString *)senderId
{
    return kZHCDemoAvatarIdJobs;
}

-(id<ZHCMessageData>)tableView:(ZHCMessagesTableView *)tableView messageDataForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.row];
}

-(void)tableView:(ZHCMessagesTableView *)tableView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.demoData.messages removeObjectAtIndex:indexPath.row];
}


-(nullable id<ZHCMessageBubbleImageDataSource>)tableView:(ZHCMessagesTableView *)tableView messageBubbleImageDataForCellAtIndexPath:(NSIndexPath *)indexPath
{
    ZHCMessage * message = [self.demoData.messages objectAtIndex:indexPath.row];
    
    if(message.isMediaMessage){
    }
    
    if([message.senderId isEqualToString:self.senderId]){
        return self.demoData.outgoingBubbleImageData;
    }
    return self.demoData.incomingBubbleImageData;
}

-(nullable id<ZHCMessageBubbleImageDataSource>)tableView:(ZHCMessagesTableView *)tableView avatarImageDataForCellAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    ZHCMessage * message = [self.demoData.messages objectAtIndex:indexPath.row];
    return [self.demoData.avatars objectForKey:message.senderId];
}


-(NSAttributedString *)tableView:(ZHCMessagesTableView *)tableView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 3 == 0){
        ZHCMessage * message = [self.demoData.messages objectAtIndex:indexPath.row];
        
        return [[ZHCMessagesTimestampFormatter sharedFormatter]attributedTimestampForDate:message.date];
    }
    
    return nil;
}

-(NSAttributedString *)tableView:(ZHCMessagesTableView *)tableView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    ZHCMessage * message = [self.demoData.messages objectAtIndex:indexPath.row];
    
    if([message.senderId isEqualToString:self.senderId]){
        return nil;
    }
    if((indexPath.row - 1) > 0){
        ZHCMessage * preMessage = [self.demoData.messages objectAtIndex:(indexPath.row - 1)];
        if([preMessage.senderId isEqualToString:message.senderId]){
            return nil;
        }
    }
    
    return [[NSAttributedString alloc]initWithString:message.senderDisplayName];
}

-(NSAttributedString *)tableView:(ZHCMessagesTableView *)tableView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Adjusting cell label heights
- (CGFloat)tableView:(ZHCMessagesTableView *)tableView heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat labelHeight = 0.0f;
    
    if(indexPath.row % 3 == 0){
        labelHeight = kZHCMessagesTableViewCellLabelHeightDefault;
    }
    
    return labelHeight;
}


- (CGFloat)tableView:(ZHCMessagesTableView *)tableView heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat labelHeight = kZHCMessagesTableViewCellLabelHeightDefault;
    
    ZHCMessage * currentMessage = [self.demoData.messages objectAtIndex:indexPath.row];
    
    if([[currentMessage senderId]isEqualToString:self.senderId]){
        labelHeight = 0.0f;
    }
    
    if(indexPath.row - 1 > 0){
        ZHCMessage * previousMessage = [self.demoData.messages objectAtIndex:indexPath.row - 1];
        if([[previousMessage senderId]isEqualToString:[currentMessage senderId]]){
            labelHeight = 0.0f;
        }
    }
    
    return labelHeight;
}


-(CGFloat)tableView:(ZHCMessagesTableView *)tableView  heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSAttributedString *string = [self tableView:tableView attributedTextForCellBottomLabelAtIndexPath:indexPath];
    if (string) {
        return kZHCMessagesTableViewCellSpaceDefault;
    }else{
        return 0.0;
    }
    
}


-(void)tableView:(ZHCMessagesTableView *)tableView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didTapMessageBubbleAtIndexPath:indexPath];
    // Do something
    
    ZHCMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    if (message.isMediaMessage) {
        if ([message.media isKindOfClass:[ZHCPhotoMediaItem class]]) {
            //            ZHCPhotoMediaItem *photoMedia = (ZHCPhotoMediaItem *)message.media;
            //            UIImage *img = photoMedia.image;
            NSLog(@"Photo");
        }else if ([message.media isKindOfClass:[ZHCVideoMediaItem class]]){
            //            ZHCVideoMediaItem *videoMedia = (ZHCVideoMediaItem *)message.media;
            //            NSURL *videoUrl = videoMedia.fileURL;
            NSLog(@"Video");
        }
    }
}

-(void)tableView:(ZHCMessagesTableView *)tableView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    [super tableView:tableView didTapCellAtIndexPath:indexPath touchLocation:touchLocation];
}


-(void)tableView:(ZHCMessagesTableView *)tableView performAction:(SEL)action forcellAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    [super tableView:tableView performAction:action forcellAtIndexPath:indexPath withSender:sender];
    
    NSLog(@"performAction:%ld",(long)indexPath.row);
}

#pragma mark － TableView datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%d", self.demoData.messages.count);
    
    
    return self.demoData.messages.count;
}

-(UITableViewCell *)tableView:(ZHCMessagesTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZHCMessagesTableViewCell *cell = (ZHCMessagesTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



#pragma mark Configure Cell Data
- (void)configureCell:(ZHCMessagesTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ZHCMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    
    
    if (!message.isMediaMessage)
    {
        if ([message.senderId isEqualToString:self.senderId])
        {
            cell.textView.textColor = [UIColor blackColor];
        }
        else
        {
            cell.textView.textColor = [UIColor whiteColor];
        }
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
}

#pragma mark - Messages view controller

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<ZHCMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    ZHCMessage *message = [[ZHCMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.demoData.messages addObject:message];
    

    
    
    
//    UITextView *textView = self.inputMessageBarView.contentView.textView;
//    textView.text = nil;
//    [textView.undoManager removeAllActions];
//    
//    [self.inputMessageBarView toggleSendButtonEnabled];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
    
   [self finishSendingMessageAnimated:NO];
    
}

#pragma mark - ZHCMessagesInputToolbarDelegate
-(void)messagesInputToolbar:(ZHCMessagesInputToolbar *)toolbar sendVoice:(NSString *)voiceFilePath seconds:(NSTimeInterval)senconds
{
    NSData * audioData = [NSData dataWithContentsOfFile:voiceFilePath];
    ZHCAudioMediaItem *audioItem = [[ZHCAudioMediaItem alloc] initWithData:audioData];
    audioItem.delegate = self;
    ZHCMessage *audioMessage = [ZHCMessage messageWithSenderId:self.senderId
                                                   displayName:self.senderDisplayName
                                                         media:audioItem];
    
    [self.demoData.messages addObject:audioMessage];
    
    [self finishSendingMessageAnimated:NO];
    
    
    //    NSFileManager *manager = [NSFileManager defaultManager];
    //    NSDictionary *dic = [manager attributesOfItemAtPath:voiceFilePath error:nil];
    //    long long size = [dic fileSize];
    //    NSLog(@"fileSize:%@",voiceFilePath);
    //    NSLog(@"fileSize:%lld",size/1024);
}


#pragma mark - ZHCMessagesMoreViewDelegate

-(void)messagesMoreView:(ZHCMessagesMoreView *)moreView selectedMoreViewItemWithIndex:(NSInteger)index
{
    
    switch (index) {
        case 0:{//Camera
            [self.demoData addVideoMediaMessage];
            [self.messageTableView reloadData];
            [self finishSendingMessage];
        }
            break;
            
        case 1:{//Photos
            [self.demoData addPhotoMediaMessage];
            [self.messageTableView reloadData];
            [self finishSendingMessage];
        }
            break;
            
        case 2:{//Location
            typeof(self) __weak weakSelf = self;
            __weak ZHCMessagesTableView *weakView = self.messageTableView;
            [self.demoData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
                [weakSelf finishSendingMessage];
                
            }];
        }
            
            break;
            
        default:
            break;
    }
}


#pragma mark - ZHAudioMediaItemDelegate
- (void)audioMediaItem:(ZHCAudioMediaItem *)audioMediaItem
didChangeAudioCategory:(NSString *)category
               options:(AVAudioSessionCategoryOptions)options
                 error:(nullable NSError *)error{
    if (!error) {
        if (currentAudioItem && ![audioMediaItem isEqual:currentAudioItem]) {
            [currentAudioItem stopPlay];
        }
        currentAudioItem = audioMediaItem;
    }else{
        NSLog(@"Play Audio error:%@",error.localizedDescription);
    }
}


#pragma mark - ZHCMessagesMoreViewDataSource
-(NSArray *)messagesMoreViewTitles:(ZHCMessagesMoreView *)moreView
{
    return @[@"Camera",@"Photos",@"Location"];
}


-(NSArray *)messagesMoreViewImgNames:(ZHCMessagesMoreView *)moreView
{
    return @[@"chat_bar_icons_camera",@"chat_bar_icons_pic",@"chat_bar_icons_location"];
}

















@end
