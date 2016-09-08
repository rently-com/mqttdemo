/*
 * Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import <AWSCore/AWSCore.h>
#import "DeveloperAuthenticatedIdentityProvider.h"


#define baseUrl2 @"https://exp-smarthome-pr-41.herokuapp.com"
#define clientID2 @"00866ecd99e961c2a87c44b30d201381b34d31f94131de6d8d0b913845059e04"
#define clientSecretID2 @"1e2be16d31e3c3b84c8a2f7549c35e28c2c0c2371626eafb3fccb61489e69748"


NSString *developerProvider = @"smarthome";


@interface DeveloperAuthenticatedIdentityProvider()
@property (strong, atomic) NSString *providerName;
@property (strong, atomic) NSString *token2;
@end

@implementation DeveloperAuthenticatedIdentityProvider
@synthesize token2,providerName;

- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
                             token:(NSString *)token1
                      providerName:(NSString *)providerName1
          identityProviderManager : (AwsLoginProvider*)idMgr
{
    
    if (self =   [super initWithRegionType:regionType   identityPoolId:identityPoolId  useEnhancedFlow:YES    identityProviderManager:idMgr]) {
        
        self.identityId = identityId;
        self.token2 = token1;
        providerName = providerName1;
    }
    return self;
}
- (BOOL)authenticatedWithProvider {
    
    return self.isAuthenticated;
}


- (AWSTask *)getIdentityId {
    if (self.identityId) {
        return [AWSTask taskWithResult:nil];
    }
    else {
        return [[AWSTask taskWithResult:nil] continueWithBlock:^id(AWSTask *task) {
            if (!self.identityId) {
                return [self refresh];
            }
            return [AWSTask taskWithResult:self.identityId];
        }];
    }
    
    
}


- (AWSTask *)refresh {
    return [AWSTask taskWithResult:self.identityId];
}


@end
