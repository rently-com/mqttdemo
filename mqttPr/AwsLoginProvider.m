//
//  AwsLoginProvider.m
//  RentlyKeyless
//
//  Created by luv mehta on 10/08/16.
//  Copyright © 2016 luv mehta. All rights reserved.
//

#import "AwsLoginProvider.h"
#define baseUrl2 @"https://exp-smarthome-pr-41.herokuapp.com"
#define clientID2 @"00866ecd99e961c2a87c44b30d201381b34d31f94131de6d8d0b913845059e04"
#define clientSecretID2 @"1e2be16d31e3c3b84c8a2f7549c35e28c2c0c2371626eafb3fccb61489e69748"

@implementation AwsLoginProvider
- (AWSTask<NSDictionary<NSString *, NSString *> *> *)logins{
    NSDictionary *dict;
     NSURL *callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/hubs/%@/get_cognito_credentials",baseUrl2, self.idStr]];
     NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init];
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
    [resultDict setObject:[dict objectForKey:@"token"] forKey:@"cognito-identity.amazonaws.com"];
    return[AWSTask taskWithResult:resultDict];
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
