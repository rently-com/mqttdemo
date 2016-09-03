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
   
    AWSIoTDataManager *mAWSIoTDataManager = AWSIoTDataManager.defaultIoTDataManager;
    [mAWSIoTDataManager subscribeToTopic:topic QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtLeastOnce extendedCallback:^(NSObject *mqttClient, NSString *topic, NSData *data) {
         NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         NSDictionary *newDataDict =[NSDictionary dictionaryWithObjectsAndKeys:dataDict,@"Data",topic,@"topic", nil];
        [self callBackFromTopicUpdate:newDataDict];
        }
     ];

}

-(void)callBackFromTopicUpdate:(NSDictionary *)dict{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTopicUpdate:)]) {
        [self.delegate onTopicUpdate:dict];
    }
}

-(void)unSubscribeForTopic:(NSString*)topic{
    
    AWSIoTDataManager *mAWSIoTDataManager = AWSIoTDataManager.defaultIoTDataManager;
    
    [mAWSIoTDataManager unsubscribeTopic:topic];
    
}


@end
