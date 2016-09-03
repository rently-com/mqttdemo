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
    NSString *ids =allTrim(_idTextField.text);
    _idTextField.text=@"";
    topicArray = @[@"$aws/things/30020/shadow/update/accepted",@"$aws/things/ec8686d8-8e60-4656-b147-611a056dd8ae/shadow/update/accepted"];//[ids componentsSeparatedByString:@","];
    
    [self performSelector:@selector(test) withObject:nil afterDelay:3.0f];
}

-(void)test{
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
   _logTextView.text = [NSString stringWithFormat:@"%@\nFor Topic%@ Data->%@",_logTextView.text,[dict objectForKey:@"topic" ],[dict objectForKey:@"Data" ] ];
}
@end
