//
//  AwsLoginProvider.m
//  RentlyKeyless
//
//  Created by luv mehta on 10/08/16.
//  Copyright © 2016 luv mehta. All rights reserved.
//

#import "AwsLoginProvider.h"
#import "AWSTask.h"

#define baseUrl2 @"https://exp-smarthome-pr-41.herokuapp.com"
#define clientID2 @"00866ecd99e961c2a87c44b30d201381b34d31f94131de6d8d0b913845059e04"
#define clientSecretID2 @"1e2be16d31e3c3b84c8a2f7549c35e28c2c0c2371626eafb3fccb61489e69748"

@implementation AwsLoginProvider

- (AWSTask<NSDictionary<NSString *, NSString *> *> *)logins{
    
    return [[AWSTask taskWithResult:nil] continueWithSuccessBlock:^id(AWSTask *task){
        
        NSURL *callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/hubs/%@/get_cognito_credentials",baseUrl2, self.idStr]];
        
        // Send a synchronous request
        NSMutableURLRequest *urlRequest =[[NSMutableURLRequest alloc] initWithURL:callUrl];
        [urlRequest setHTTPMethod:@"GET"];
        [urlRequest setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                              returningResponse:&response
                                                          error:&error];
        
        if (error == nil)
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSLog(@"TokenDict->%@",dict);
            
            NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init];
            
            [resultDict setObject:[dict objectForKey:@"token"] forKey:@"cognito-identity.amazonaws.com"];
            
            return [AWSTask taskWithResult:resultDict];
        }
        else
            return [AWSTask taskWithResult:nil];
        
    }];
   
//    NSDictionary *dict;
//    
//    NSURL *callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/hubs/%@/get_cognito_credentials",baseUrl2, self.idStr]];
//    
//    NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init];
//    
//    NSMutableURLRequest *request =[[NSMutableURLRequest alloc] init];
//   
//    [request setURL:callUrl];
//    
//    [request setHTTPMethod:@"GET"];
//    
//    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
//    
//    
//    NSURLResponse* response;
//    
//    NSError* error = nil;
//    
//    //Capturing server response
//    NSData* result = [self sendSynchronousRequest:request  returningResponse:&response error:&error];
//    
//    dict = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
//    
//    NSLog(@"TokenDict->%@",dict);
//    
//    [resultDict setObject:[dict objectForKey:@"token"] forKey:@"cognito-identity.amazonaws.com"];
//    
//    return [AWSTask taskWithResult:resultDict];
}

@end
