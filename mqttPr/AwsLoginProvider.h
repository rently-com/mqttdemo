//
//  AwsLoginProvider.h
//  RentlyKeyless
//
//  Created by luv mehta on 10/08/16.
//  Copyright © 2016 luv mehta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import "AWSIdentityProvider.h"

@interface AwsLoginProvider  : NSObject <AWSIdentityProviderManager>

@property(nonatomic,retain) NSString *idStr;

@property(nonatomic,retain) NSString *token;

@end
