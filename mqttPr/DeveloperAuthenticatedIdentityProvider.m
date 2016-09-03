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
@synthesize token2,providerName,idStr;

- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
                             token:(NSString *)token1
                      providerName:(NSString *)providerName1
          identityProviderManager : (AwsLoginProvider*)idMgr
{
    
    if (self =   [super initWithRegionType:regionType   identityPoolId:identityPoolId  useEnhancedFlow:YES    identityProviderManager:idMgr]) {
        
        //self.identityId = identityId;
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
//- (AWSTask<NSDictionary<NSString *, NSString *> *> *)logins{
//    //NSDictionary *dict;
//    NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init];
//    //    NSMutableURLRequest *request =[[NSMutableURLRequest alloc] init];
//    //    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://exp-smarthome-pr-37.herokuapp.com/api/hubs/f6cc01d4-1cf0-45b8-bc57-777371bfefdd/get_cognito_credentials"]]];
//    //    [request setHTTPMethod:@"GET"];
//    //    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
//    //     NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
//    //   [request setValue:[NSString stringWithFormat:@"Bearer  %@",accessToken]forHTTPHeaderField:@"Authorization"];
//    //     NSURLResponse* response;
//    //    NSError* error = nil;
//    //    //Capturing server response
//    //    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
//    //    dict = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
//    [resultDict setObject:self.token2 forKey:@"cognito-identity.amazonaws.com"];
//    return[AWSTask taskWithResult:resultDict];
//
//}

- (AWSTask *)refresh {
    
    
        NSDictionary *dict;
        NSURL *callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/hubs/%@/get_cognito_credentials",baseUrl2, self.idStr]];
        NSMutableURLRequest *request =[[NSMutableURLRequest alloc] init];
        [request setURL:callUrl];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
        NSURLResponse* response;
        NSError* error = nil;
        //Capturing server response
        NSData* result = [self sendSynchronousRequest:request  returningResponse:&response error:&error];
        dict = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
         NSLog(@"TokenDict->%@",dict);
        self.identityId=[dict objectForKey:@"identity_id"];
        return [AWSTask taskWithResult:self.identityId];
    
    
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    
    NSError __block *err = NULL;
    NSData __block *data;
    BOOL __block reqProcessed = false;
    NSURLResponse __block *resp;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error) {
        resp = _response;
        err = _error;
        data = _data;
        reqProcessed = true;
    }] resume];
    
    while (!reqProcessed) {
        [NSThread sleepForTimeInterval:0];
    }
    
    *response = resp;
    *error = err;
    return data;
}

@end
