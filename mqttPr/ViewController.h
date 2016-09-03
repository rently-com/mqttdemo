//
//  ViewController.h
//  mqttPr
//
//  Created by luv mehta on 31/08/16.
//  Copyright © 2016 luv mehta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionController.h"
#import "SubscriptionController.h"
@interface ViewController : UIViewController<ConnectionUpdateDelegate,SubscriptionDelegate,UITextViewDelegate>{
    ConnectionController *connectionObj;
    SubscriptionController *subscriptionObj;
    
    BOOL isConnected;
}


@end

