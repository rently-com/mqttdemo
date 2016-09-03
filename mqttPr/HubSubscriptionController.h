//
//  HubSubscriptionController.h
//  RentlyKeyless
//
//  Created by luv mehta on 18/08/16.
//  Copyright © 2016 Bitcanny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubscriptionController.h"

@protocol HubSubscriptionDelegate <NSObject>
- (void)onHubTopicUpdate:(NSDictionary *)dict;
@end

@interface HubSubscriptionController : SubscriptionController

@property (nonatomic, weak) id < HubSubscriptionDelegate > delegateHub;

-(void)subscribeHub;
-(void)unSubscribeHub;

@end
