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

@protocol ConnectionUpdateDelegate <NSObject>
- (void)isAWSMQTTConnected:(BOOL)isConnected;
@end


@interface ConnectionController : NSObject{
    
}

@property (nonatomic, weak) id <ConnectionUpdateDelegate> aWSMQTTConnectionDelegate;

-(void)connectToID:(NSString*)idStr;

-(void)disconnect;

@end
