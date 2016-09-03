//
//  HubSubscriptionController.m
//  RentlyKeyless
//
//  Created by luv mehta on 18/08/16.
//  Copyright © 2016 Bitcanny. All rights reserved.
//

#import "HubSubscriptionController.h"

@implementation HubSubscriptionController

-(NSDictionary*)getHub{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    // Path to save dictionary
    NSString   *hubPath = [[paths objectAtIndex:0]
                             stringByAppendingPathComponent:[NSString stringWithFormat:@"homeDict.out"]];
    return [NSDictionary dictionaryWithContentsOfFile:hubPath];
}

-(void)subscribeHub{
    
    NSDictionary *hubObj = [self getHub];
    
    [self subscribeForTopic:[hubObj objectForKey:@"topic_name"]];
    NSLog(@"SubscribeHub->%@",hubObj );

}

-(void)unSubscribeHub{
    
    NSDictionary *hubObj = [self getHub];
    
    [self unSubscribeForTopic:[hubObj objectForKey:@"topic_name"]];
    NSLog(@"UnSubscribeHubID->%@",[hubObj objectForKey:@"id"]);
}

-(void)callBackFromTopicUpdate:(NSDictionary *)dict{
    
    if (self.delegateHub && [self.delegateHub respondsToSelector:@selector(onHubTopicUpdate:)]) {
        [self.delegateHub onHubTopicUpdate:dict];
    }
        
    NSLog(@"Hub Data from mqqt->%@",dict);
    
//    UIAlertView *altView =[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"MQTT data"] message:[NSString stringWithFormat:@"%@",dict] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//   
//    [altView show];
}

@end
