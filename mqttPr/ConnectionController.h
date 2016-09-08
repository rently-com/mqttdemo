//
//  ConnectionController.h
//  RentlyKeyless
//
//  Created by luv mehta on 04/08/16.
//  Copyright © 2016 luv mehta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import <AWSIoT/AWSIoTManager.h>
#import <AWSIoT/AWSIoTDataManager.h>
#import "DeveloperAuthenticatedIdentityProvider.h"
#import "AwsLoginProvider.h"
#import "SubscriptionController.h"

@protocol ConnectionUpdateDelegate <NSObject>
- (void)isAWSMQTTConnected:(BOOL)isConnected;
@end


@interface ConnectionController : NSObject{
    
}

@property (nonatomic, weak) id <ConnectionUpdateDelegate> aWSMQTTConnectionDelegate;

@property (nonatomic, retain) AWSIoTDataManager *mAWSIoTDataManager;

-(void)connectToID:(NSString*)idStr;

-(void)disconnect;

@end
