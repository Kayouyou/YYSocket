//
//  YYAsyncSocketManager.m
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#import "YYAsyncSocketManager.h"
#import "GCDAsyncSocket.h"
#import "YYAsyncSocketConfig.h"

@interface YYAsyncSocketManager()

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, assign) NSInteger beatCount;//心跳次数
@property (nonatomic, strong) NSTimer *beatTimer;//心跳计时器
@property (nonatomic, strong) NSTimer *reconnectTimer;//重连计时器


@end


@implementation YYAsyncSocketManager

/**
 获取单例
 
 @return 返回单例对象
 */
+ (nullable YYAsyncSocketManager *)sharedInstance{
    
    static YYAsyncSocketManager *insatnce = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        insatnce = [[self alloc] init];;
    });
    
    return insatnce;
}

- (instancetype)init{
    
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    self.connectStatus = DisConnected;
    
    return self;
    
}


/**
 链接socket
 
 @param delegate 代理
 */
- (void)connectSocketWithDelegate:(nonnull id)delegate{
    
    if (self.connectStatus != DisConnected) {
        NSLog(@"socket has connected");
        return;
    }
    
    self.connectStatus = isConnecting;
    
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:delegate delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![self.socket connectToHost:HOST onPort:PORT withTimeout:TIMEOUT error:&error]) {
        
        self.connectStatus = DisConnected;
        NSLog(@"socket connect error : %@",error);
    }
}


/**
 socket 链接成功后发送心跳操作
 
 @param beatBody 心跳包body
 */
- (void)socketDidConnectBeginSendBeat:(nonnull NSString *)beatBody{
    
    self.connectStatus = DidConnected;
    self.reConnectionCount = 0;
    if (!self.beatTimer) {
        
        self.beatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendBeat:) userInfo:beatBody repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.beatTimer forMode:NSRunLoopCommonModes];
        
    }
}


/**
 socket 连接失败后重接操作
 
 @param reconnectBody 重连心跳body
 */
- (void)socketDidDisconnectBeginSendReconnect:(nonnull NSString *)
reconnectBody{
    
    self.connectStatus = DisConnected;
    
    if (self.reConnectionCount >= 0 && self.reConnectionCount <= kBeatLimit) {
        
        NSTimeInterval time = pow(2, self.reConnectionCount);//2的reConnectionCount次方
        if (!self.reconnectTimer) {
            self.reconnectTimer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(reconnection:) userInfo:reconnectBody repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.reconnectTimer forMode:NSRunLoopCommonModes];
        }
        self.reConnectionCount ++;
    }else{
        
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
        self.reConnectionCount = 0;
    }
}


/**
 先服务器发送数据
 
 @param data body数据
 */
- (void)socketWriteData:(nonnull NSString *)data{
    
    NSData *requestData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:requestData withTimeout:-1 tag:0];
    [self socketBeginReadData];
}


/**
 socket 读取数据
 */
- (void)socketBeginReadData{
    
    [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 maxLength:0 tag:0];
}


/**
 socket 主动断开链接
 */
- (void)disconnectSocket{
    
    self.reConnectionCount = -1;
    [self.socket disconnect];
    
    [self.beatTimer invalidate];
    self.beatTimer = nil;
}


/**
 重设心跳次数
 */
- (void)resetBeatCount{
    
    self.beatCount = 0;
}

#pragma mark - private 计时器方法

- (void)sendBeat:(NSTimer *)timer{
    
    if (self.beatCount >= kBeatLimit) {
        
        [self disconnectSocket];
        return;
    }else{
        
        self.beatCount ++;
    }
    
    if (timer != nil) {
        
        [self socketWriteData:timer.userInfo];
    }
}

- (void)reconnection:(NSTimer *)timer{
    
    NSError *error = nil;
    if (![self.socket connectToHost:HOST onPort:PORT withTimeout:TIMEOUT error:&error]) {
        
        self.connectStatus = DisConnected;
    }
}












@end
