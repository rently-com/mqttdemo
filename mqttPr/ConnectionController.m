 //
//  ConnectionController.m
//  RentlyKeyless
//
//  Created by luv mehta on 04/08/16.
//  Copyright © 2016 luv mehta. All rights reserved.
//

#import "ConnectionController.h"
#define baseUrl2 @"https://exp-smarthome-pr-41.herokuapp.com"
#define clientID2 @"00866ecd99e961c2a87c44b30d201381b34d31f94131de6d8d0b913845059e04"
#define clientSecretID2 @"1e2be16d31e3c3b84c8a2f7549c35e28c2c0c2371626eafb3fccb61489e69748"
@interface ConnectionController (){
    AWSIoTDataManager *dataMgr;
    AWSIoTData *iotData;
    AWSIoTManager *iotMgr;
    AWSIoT *iot;
    BOOL isMqttConnected;
    AWSRegionType awsRegion;
}

@end


@implementation ConnectionController

-(id)init{
    self = [super init];
    
    if(self)
    {
        isMqttConnected = NO;
        awsRegion = AWSRegionUSEast1;
    }
    return self;
}


-(void)disconnect{
    if(isMqttConnected){
        AWSIoTDataManager *mAWSIoTDataManager = AWSIoTDataManager.defaultIoTDataManager;
        
        [mAWSIoTDataManager disconnect];
        
    }
}

-(void)connectToID:(NSString*)idStr{
   
    NSURL *callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/hubs/%@/get_cognito_credentials",baseUrl2, idStr]];
    
    NSMutableURLRequest *request =[[NSMutableURLRequest alloc] init];
    
    [request setURL:callUrl];
    
    [request setHTTPMethod:@"GET"];
    
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    
    //NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    
    //[request setValue:[NSString stringWithFormat:@"Bearer  %@",accessToken]forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse* response;
    
    NSError* error = nil;
    //Capturing server response
//    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    NSData* result = [self sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
    
    AwsLoginProvider *loginPrd = [[AwsLoginProvider alloc]init];
    
    loginPrd.idStr=idStr ;
    
    DeveloperAuthenticatedIdentityProvider *crPrd=[[DeveloperAuthenticatedIdentityProvider alloc]initWithRegionType:AWSRegionUSEast1 identityId:[dict objectForKey:@"identity_id"] identityPoolId :@"us-east-1:2ecefabe-d8d7-4aba-9bc3-77fb7f4f85b7" token:nil providerName:@"smarthome" identityProviderManager:loginPrd ];
    
    crPrd.idStr=idStr;
    
    AWSCognitoCredentialsProvider *prvd=[[AWSCognitoCredentialsProvider alloc]initWithRegionType:AWSRegionUSEast1 unauthRoleArn:@"arn:aws:iam::847283250964:role/Cognito_smarthome_hubsAuth_Role" authRoleArn:@"arn:aws:iam::847283250964:role/Cognito_smarthome_hubsAuth_Role" identityProvider:crPrd];
    
    
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:prvd];
        
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    
    AWSIoTDataManager *mAWSIoTDataManager = AWSIoTDataManager.defaultIoTDataManager;
        
    
    NSString *clt=[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    [mAWSIoTDataManager connectUsingWebSocketWithClientId:[NSString stringWithFormat:@"%@%@",clt,timestamp] cleanSession:YES statusCallback:^(AWSIoTMQTTStatus status) {
        
            NSLog(@"AWSIoTMQTTStatus Status->%ld",(long)status);
            
            [self mqttConnectionWith:status];
            
              }
         ];
  
}

-(void)mqttConnectionWith:(AWSIoTMQTTStatus)status{
    
    switch(status)
    {
        case AWSIoTMQTTStatusConnecting:
            NSLog(@"Connecting...");
            break;
            
        case AWSIoTMQTTStatusConnected:
            NSLog(@"Connected");
            isMqttConnected=YES;
            [self.aWSMQTTConnectionDelegate isAWSMQTTConnected:YES];
            break;
        case AWSIoTMQTTStatusDisconnected:
            NSLog(@"Disconnected");
            isMqttConnected=NO;
            [self.aWSMQTTConnectionDelegate isAWSMQTTConnected:NO];
            break;
        case AWSIoTMQTTStatusConnectionRefused:
            NSLog(@"Connection Refused");
            isMqttConnected=NO;
            [self.aWSMQTTConnectionDelegate isAWSMQTTConnected:NO];
            break;
        case AWSIoTMQTTStatusConnectionError:
            NSLog(@"Connection Error");
            isMqttConnected=NO;
            [self.aWSMQTTConnectionDelegate isAWSMQTTConnected:NO];
            break;
            
        case AWSIoTMQTTStatusProtocolError:
            NSLog(@"Protocol Error");
            isMqttConnected=NO;
            [self.aWSMQTTConnectionDelegate isAWSMQTTConnected:NO];
            break;
        default:
            NSLog(@"Unknown State");
            isMqttConnected=NO;
            [self.aWSMQTTConnectionDelegate isAWSMQTTConnected:NO];
            break;
    }
}
-(NSURL*)getCognitoUrl{
    
    //Create an URLRequest
    NSURL *callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/hubs/%@/get_cognito_credentials",baseUrl2, [[NSUserDefaults standardUserDefaults]objectForKey:@"id"]]];
    NSLog(@"CognitoURL for HubID->%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"id"]);
    return callUrl;
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
