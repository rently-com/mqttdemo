//
//  ViewController.m
//  mqttPr
//
//  Created by luv mehta on 31/08/16.
//  Copyright © 2016 luv mehta. All rights reserved.
//

#import "ViewController.h"


#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
@interface ViewController (){
    NSArray *topicArray;
}
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UIButton *connButton;
@property (weak, nonatomic) IBOutlet UIButton *subscribeButton;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;


- (IBAction)ConnectMqtt:(id)sender;
- (IBAction)subscribeMe:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    connectionObj = [[ConnectionController alloc]init];
    connectionObj.aWSMQTTConnectionDelegate=self;
    subscriptionObj = [[SubscriptionController alloc]init];
    subscriptionObj.delegate=self;
    _subscribeButton.enabled=NO;
    _connButton.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ConnectMqtt:(id)sender {
    
   [connectionObj connectToID:allTrim(_idTextField.text)];
    _idTextField.text=@"";
    _subscribeButton.enabled=YES;
    _connButton.enabled = NO;
    
    
}

- (IBAction)DisconnectMqtt:(id)sender {
    
    subscriptionObj.mAWSIoTDataManager = connectionObj.mAWSIoTDataManager;
    
    if(topicArray.count){
        for(NSString *idStr in topicArray)
            [subscriptionObj unSubscribeForTopic:idStr];
    }
    
    topicArray = nil;    
    
    [connectionObj disconnect];
    
    _idTextField.text=@"";
    
    _subscribeButton.enabled=NO;
    
    _connButton.enabled = YES;
    
    
}


- (IBAction)subscribeMe:(id)sender {
    
    subscriptionObj.mAWSIoTDataManager = connectionObj.mAWSIoTDataManager;
    
    NSString *ids =allTrim(_idTextField.text);

    _idTextField.text=@"";
    
    topicArray = [ids componentsSeparatedByString:@","];
    
    for(NSString *idStr in topicArray)
        [subscriptionObj subscribeForTopic:idStr];
}

- (void)isAWSMQTTConnected:(BOOL)isConnected1{
    
    isConnected=isConnected1;
    if (isConnected) {
        _logTextView.text = [NSString stringWithFormat:@"%@\nConnection%@",_logTextView.text,@"Connected" ];
    }
    else{
        _logTextView.text = [NSString stringWithFormat:@"%@\nConnection%@",_logTextView.text,@"Disconnected" ];
    }
    
}
- (void)onTopicUpdate:(NSDictionary *)dict{
   _logTextView.text = [NSString stringWithFormat:@"%@\n%@",_logTextView.text,dict ];
    
    if([dict objectForKey:@"state"]){
        
        NSDictionary *reportedDict = [[dict objectForKey:@"state"] objectForKey:@"reported"];
        
        if ([[reportedDict allKeys] containsObject:@"settings"]) {
            
            NSDictionary *settingsDict = [reportedDict objectForKey:@"settings"];

            if ([[settingsDict allKeys] containsObject:@"devices"]) {
                
                NSArray *oldDevices = [topicArray copy];
                
                NSArray *currentDevices = [settingsDict objectForKey:@"devices"];
                
                if ([currentDevices count]) {
                    
                    NSMutableArray *arrTemp1 = [[NSMutableArray alloc] init];
                    
                    for(NSString *idStr in currentDevices)
                        [arrTemp1 addObject:[NSString stringWithFormat:@"$aws/things/%@/shadow/update/accepted",idStr]];
                    
                    NSPredicate *intersectPredicate =[NSPredicate predicateWithFormat:@"self IN %@", arrTemp1];
                    
                    NSArray *arrTemp = [oldDevices filteredArrayUsingPredicate:intersectPredicate];
                    
                    NSMutableSet *setOld = [NSMutableSet setWithArray:oldDevices];
                    
                    NSMutableSet *setNew = [NSMutableSet setWithArray:arrTemp];
                    
                    //Finding deleted Devices
                    [setOld minusSet:setNew];
                    
                    NSMutableArray *arrDeletedDevices = [[setOld allObjects] mutableCopy];
                    
                    NSLog(@"Deleted : %@",arrDeletedDevices);
                    
                    if(arrDeletedDevices && [arrDeletedDevices count]>0){
                        
                        [arrDeletedDevices removeObject:@"$aws/things/30024/shadow/update/accepted"];
                        
                        for(NSString *idStr in arrDeletedDevices)
                            [subscriptionObj unSubscribeForTopic:idStr];
                    }
                    
                    //Finding newly added Devices
                    setOld = [NSMutableSet setWithArray:oldDevices];
                    
                    setNew = [NSMutableSet setWithArray:arrTemp1];
                    
                    [setNew unionSet: setOld];
                    
                    NSMutableArray *arrAddedDevices = [[setNew allObjects] mutableCopy];
                    
                    if ([arrAddedDevices count] == 0) {
                        for(NSString *idStr in currentDevices)
                            [arrAddedDevices addObject:[NSString stringWithFormat:@"$aws/things/%@/shadow/update/accepted",idStr]];
                    }
                    
                    [arrAddedDevices removeObjectsInArray:oldDevices];
                    
                    NSLog(@"Added : %@",arrAddedDevices);
                    
                    if (arrAddedDevices) {
                        for(NSString *topic in arrAddedDevices)
                            [subscriptionObj subscribeForTopic:topic];
                    }
                }
                else{
                    if ([oldDevices count]) {
                        //Unsubscripe current local Devices.
                        for(NSString *idStr in oldDevices)
                            [subscriptionObj unSubscribeForTopic:idStr];
                    }
                }
            }
        }
    }
    
    
    
}
@end
