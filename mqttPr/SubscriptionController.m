//
//  SubscriptionController.m
//  RentlyKeyless
//
//  Created by luv mehta on 04/08/16.
//  Copyright © 2016 luv mehta. All rights reserved.
//

#import "SubscriptionController.h"
#import <AWSCore/AWSCore.h>
#import <AWSIoT/AWSIoTManager.h>
#import <AWSIoT/AWSIoTDataManager.h>

@implementation SubscriptionController

-(id)init{
    self = [super init];
    
    if(self)
    {
    }
    return self;
}

-(void)subscribeForTopic:(NSString*)topic{
    
    if (self.mAWSIoTDataManager) {
        [self.mAWSIoTDataManager subscribeToTopic:topic QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtLeastOnce messageCallback:^(NSData *data) {
            
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSLog(@"Dict->%@",dataDict);
            
            [self callBackFromTopicUpdate:dataDict];
        }];
    }
}

-(void)callBackFromTopicUpdate:(NSDictionary *)dict{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTopicUpdate:)]) {
        [self.delegate onTopicUpdate:dict];
    }
}

-(void)unSubscribeForTopic:(NSString*)topic{
    
    if (self.mAWSIoTDataManager)
        [self.mAWSIoTDataManager unsubscribeTopic:topic];
    
}


@end
