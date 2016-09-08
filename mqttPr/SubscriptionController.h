//
//  SubscriptionController.h
//  RentlyKeyless
//
//  Created by luv mehta on 04/08/16.
//  Copyright © 2016 luv mehta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import <AWSIoT/AWSIoTManager.h>
#import <AWSIoT/AWSIoTDataManager.h>

@protocol SubscriptionDelegate <NSObject>
- (void)onTopicUpdate:(NSDictionary *)dict;
@end

@interface SubscriptionController : NSObject

@property (nonatomic, weak) id < SubscriptionDelegate > delegate;

@property (nonatomic, retain) AWSIoTDataManager *mAWSIoTDataManager;

-(void)unSubscribeForTopic:(NSString*)topic;
-(void)subscribeForTopic:(NSString*)topic;

@end
