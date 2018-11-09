//
//  ViewController.m
//  TCPClient
//
//  Created by MM on 2018/11/9.
//  Copyright © 2018年 MM. All rights reserved.
//

#import "ViewController.h"
#import "GCD/GCDAsyncSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ipContent;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UITextField *portContent;
@property (weak, nonatomic) IBOutlet UITextView *sendContent;
@property (weak, nonatomic) IBOutlet UITextView *receiveContent;
@property(nonatomic,strong)GCDAsyncSocket* tcpClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendContent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.sendContent.layer.borderWidth = 0.5;
    
    self.receiveContent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.receiveContent.layer.borderWidth = 0.5;
    
    self.tcpClient = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (IBAction)connectAction:(UIButton *)sender {
    NSError *error = nil;
    if(![self.tcpClient connectedHost]){
        if (![self.tcpClient connectToHost:_ipContent.text onPort:[_portContent.text intValue] error:&error]) {
            if (error==nil){
                NSLog(@"连接成功");
            }else{
                NSLog(@"连接失败：%@",error);
            }
        }else{
            NSLog(@"已经连接");
        }
    }else{
        [self.tcpClient disconnect];
    }
    [self.view endEditing:YES];
}
- (IBAction)sendClearAction:(UIButton *)sender {
    self.sendContent.text = @"";
}
- (IBAction)sendAction:(UIButton *)sender {
    NSData *data = [self.sendContent.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.tcpClient writeData:data withTimeout:-1 tag:0];
    [self.view endEditing:YES];
}
- (IBAction)receiveClearAction:(UIButton *)sender {
    self.receiveContent.text = @"";
}
/**
 连接成功
 */
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self.connectBtn setTitle:@"断开连接" forState:UIControlStateNormal];
    [self.tcpClient readDataWithTimeout:-1 tag:0];
}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Message didReceiveData :%@", str);
    _receiveContent.text = str;
    [self.tcpClient readDataWithTimeout:-1 tag:0];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    [self.connectBtn setTitle:@"开始连接" forState:UIControlStateNormal];
}
@end
