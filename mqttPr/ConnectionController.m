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
    AWSIoTMQTTStatus status1;
    AWSIoTDataManager *dataMgr;
    AWSIoTData *iotData;
    AWSIoTManager *iotMgr;
    AWSIoT *iot;
    BOOL isMqttConnected;
    AWSRegionType awsRegion;
    AWSCognitoCredentialsProvider *prvd;
}

@end


@implementation ConnectionController

@synthesize mAWSIoTDataManager=mAWSIoTDataManager;


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
    
    if (mAWSIoTDataManager) {
        [mAWSIoTDataManager disconnect];
    }
    
   
    if(prvd){
        [prvd clearKeychain];
    }
}

//-(void)connect{
//    
//    RentlyWebServicesClass *rently= [[RentlyWebServicesClass alloc]init];
//    
//    [rently getCognitoToken_WithComplition:^(NSError *error, NSDictionary *result) {
//        
//        NSLog(@"TokenDict->%@",result);
//        
//        AwsLoginProvider *loginPrd = [[AwsLoginProvider alloc]init];
//        
//        // loginPrd.token=[result objectForKey:@"token"] ;
//        
//        DeveloperAuthenticatedIdentityProvider *crPrd=[[DeveloperAuthenticatedIdentityProvider alloc]initWithRegionType:AWSRegionUSEast1 identityId:[result objectForKey:@"identity_id"] identityPoolId :@"us-east-1:2ecefabe-d8d7-4aba-9bc3-77fb7f4f85b7" token:nil providerName:@"smarthome" identityProviderManager:loginPrd ];
//        
//        AWSCognitoCredentialsProvider *prvd=[[AWSCognitoCredentialsProvider alloc]initWithRegionType:AWSRegionUSEast1 unauthRoleArn:@"arn:aws:iam::847283250964:role/Cognito_smarthome_hubsAuth_Role" authRoleArn:@"arn:aws:iam::847283250964:role/Cognito_smarthome_hubsAuth_Role" identityProvider:crPrd];
//        
//        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:prvd];
//        
//        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
//        
//        AWSIoTDataManager *mAWSIoTDataManager = AWSIoTDataManager.defaultIoTDataManager;
//        
//        [mAWSIoTDataManager connectUsingWebSocketWithClientId:[[[UIDevice currentDevice] identifierForVendor] UUIDString] cleanSession:YES statusCallback:^(AWSIoTMQTTStatus status) {
//            
//            NSLog(@"AWSIoTMQTTStatus Status->%ld",(long)status);
//            
//            [self mqttConnectionWith:status];
//            
//        }];
//        
//        
//    }];
//    
//}


-(void)connectToID:(NSString*)idStr{
    
    NSURL *callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/hubs/%@/get_cognito_credentials",baseUrl2, idStr]];
    
    NSMutableURLRequest *request =[[NSMutableURLRequest alloc] init];
    
    [request setURL:callUrl];
    
    [request setHTTPMethod:@"GET"];
    
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse* response;
    
    NSError* error = nil;
    
    NSData* result = [self sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
    
    AwsLoginProvider *loginPrd = [[AwsLoginProvider alloc]init];
    loginPrd.idStr=idStr ;
    loginPrd.token = [dict objectForKey:@"token"];
    
    DeveloperAuthenticatedIdentityProvider *crPrd=[[DeveloperAuthenticatedIdentityProvider alloc]initWithRegionType:AWSRegionUSEast1 identityId:[dict objectForKey:@"identity_id"] identityPoolId :@"us-east-1:2ecefabe-d8d7-4aba-9bc3-77fb7f4f85b7" token:nil providerName:@"smarthome" identityProviderManager:loginPrd ];
    
    crPrd.idStr=idStr;
    
    prvd=[[AWSCognitoCredentialsProvider alloc]initWithRegionType:AWSRegionUSEast1 unauthRoleArn:@"arn:aws:iam::847283250964:role/Cognito_smarthome_hubsAuth_Role" authRoleArn:@"arn:aws:iam::847283250964:role/Cognito_smarthome_hubsAuth_Role" identityProvider:crPrd];
    
    [prvd clearKeychain];

    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:prvd];
    
    mAWSIoTDataManager = [[AWSIoTDataManager  alloc] initWithConfiguration:configuration];

    NSString *clt=[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [mAWSIoTDataManager connectUsingWebSocketWithClientId:clt cleanSession:YES statusCallback:^(AWSIoTMQTTStatus status) {
        
        NSLog(@"AWSIoTMQTTStatus Status->%ld",(long)status);
        
        [self mqttConnectionWith:status];
        
    }
     ];
    
}


-(void)mqttConnectionWith:(AWSIoTMQTTStatus)status{
    
    status1=status;
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
