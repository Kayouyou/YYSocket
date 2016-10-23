//
//  YYAsyncSocketOperationManager.m
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#import "YYAsyncSocketOperationManager.h"
#import "GCDAsyncSocket.h"//GCDsocket library
#import "YYKeyChainManager.h"//储存token
#import "YYAsyncSocketConfig.h"//socket的全局配置
#import "YYAsyncSocketManager.h"//socket的第一层封装
#import "YYSocketErrorManager.h"//socket错误类
#import "YYSocketModel.h"//具体使用时跟具体的商定的接口决定model属性
#import "AFNetworkReachabilityManager.h"


/**
 具体的业务处理层！
 */

@interface YYAsyncSocketOperationManager()<GCDAsyncSocketDelegate>//GCD的系统代理
@property (nonatomic, strong) NSString *socketAuthChannel;//socket验证通道，支持多通道
//用来存储不同业务请求的回调数组集合【block】
@property (nonatomic, strong) NSMutableDictionary *requestMap;
@property (nonatomic, strong) YYAsyncSocketManager *socketManager;
@property (nonatomic, assign) NSTimeInterval interval;//server 与本地的时间差

@end

@implementation YYAsyncSocketOperationManager

//单例对象
+ (nullable YYAsyncSocketOperationManager *)sharedInstance{
    static YYAsyncSocketOperationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        instance = [[self alloc] init];
    });
    
    return instance;

}

- (instancetype)init{
    
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    self.socketManager = [YYAsyncSocketManager sharedInstance];
    self.requestMap = [NSMutableDictionary dictionary];
    [self startMonitoringNetwork];//监听网络
    return self;
    
}


//初始化socket
- (void)createSocketWithToken:(nonnull NSString *)token channel:(nonnull NSString *)channel{
    
    if (!token || !channel) {
        
        return;
    }
    
    self.socketAuthChannel = channel;
    [YYKeyChainManager sharedInstance].token = token;
    [self.socketManager connectSocketWithDelegate:self];
}

//断开连接
- (void)disconnectSocket{
    
    [self.socketManager disconnectSocket];
}


/**
 通用的发送数据
 
 @param type     请求类型
 @param body     请求体
 @param callBack 请求结果回调
 */
- (void)socketWriteDataWithRequestType:(YYRequestType)type
                           requestBody:(nonnull NSDictionary *)body
                            completion:(nonnull SocketDidReadBlock)callBack{
    
    if (self.socketManager.connectStatus == DisConnected) {
        NSLog(@"socket 未连接通");
        if (callBack) {
            
            callBack([YYSocketErrorManager errorWithErrorCode:2003],
                     nil);
        }
        return;
    }
    
    NSString *blockRequestID = [self createRequestID];
   
    if (callBack) {
        //获取时间戳绑定对应的block
        [self.requestMap setObject:callBack forKey:blockRequestID];
    }
    
    YYSocketModel *socketModel = [[YYSocketModel alloc] init];
    socketModel.version = PROTOCOL_VERSION;
    socketModel.reqType = type;
    socketModel.reqID = blockRequestID;
    socketModel.requsetChannel = self.currentConnectChannel;
    socketModel.body = body;
    
    NSString *requestBody = [socketModel socketModelToJSONString];
    [self.socketManager socketWriteData:requestBody];
}

#pragma mark-- private method
- (NSString *)createRequestID {
    NSInteger timeInterval = [NSDate date].timeIntervalSince1970 * 1000000;
    NSString *randomRequestID = [NSString stringWithFormat:@"%ld%d", timeInterval, arc4random() % 100000];
    return randomRequestID;
}

- (void)differenceOfLocalTimeAndServerTime:(long long)serverTime {
    if (serverTime == 0) {
        self.interval = 0;
        return;
    }
    
    NSTimeInterval localTimeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    self.interval = serverTime - localTimeInterval;
}

- (long long)simulateServerCreateTime {
    NSTimeInterval localTimeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    localTimeInterval += 3600 * 8;
    localTimeInterval += self.interval;
    return localTimeInterval;
}

- (void)didConnectionAuthAppraisal {
    if ([self.socketDelegate respondsToSelector:@selector(socketDidConncet)]) {
        [self.socketDelegate socketDidConncet];
    }
    
    YYSocketModel *socketModel = [[YYSocketModel alloc] init];
    socketModel.version = PROTOCOL_VERSION;
    socketModel.reqType = YYRequestType_Beat;
    socketModel.user_mid = 0;
    
    NSString *beatBody = [NSString stringWithFormat:@"%@\r\n", [socketModel toJSONString]];
    [self.socketManager socketDidConnectBeginSendBeat:beatBody];
}

- (void)startMonitoringNetwork {
    AFNetworkReachabilityManager *networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager startMonitoring];
    __weak __typeof(&*self) weakSelf = self;
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                if (weakSelf.socketManager.connectStatus != DisConnected) {
                    [self disconnectSocket];
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                if (weakSelf.socketManager.connectStatus == DisConnected) {
                    [self createSocketWithToken:[YYKeyChainManager sharedInstance].token
                                        channel:self.socketAuthChannel];
                }
                break;
            default:
                break;
        }
    }];
}


#pragma mark - GCDAsyncSocketDelegate

//连接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
    YYSocketModel *socketModel = [[YYSocketModel alloc] init];
    socketModel.version = PROTOCOL_VERSION;
    socketModel.reqType = YYRequestType_ConnectAppraisal;
    socketModel.reqID  = [self createRequestID];
    socketModel.requsetChannel = self.socketAuthChannel;
    
    socketModel.body = @{@"token": [YYKeyChainManager sharedInstance].token ?: @"",
                         @"endpoint": @"ios" };
    
    [self.socketManager socketWriteData:[socketModel socketModelToJSONString]];
    
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", socket, host, port);
    NSLog(@"Cool, I'm connected! That was easy.");
}

//连接失败
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    YYSocketModel *socketModel = [[YYSocketModel alloc] init];
    socketModel.version = PROTOCOL_VERSION;
    socketModel.reqType = YYRequestType_ConnectAppraisal;
    socketModel.reqID = [self createRequestID];
    socketModel.requsetChannel = self.socketAuthChannel;
    socketModel.body = @{@"token": [YYKeyChainManager sharedInstance].token ?: @"",
                         @"endpoint": @"ios" };
    NSString *requestBody = [socketModel socketModelToJSONString];
    //连接失败处理
    [self.socketManager socketDidDisconnectBeginSendReconnect:requestBody];

}

//socket已经读取数据到内存中调用
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *jsonError;
    NSDictionary *json =
    [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    NSLog(@"socket - receive data %@", json);

    if (jsonError) {
        
        [self.socketManager socketBeginReadData];
        NSLog(@"json  解析失败:%@",jsonError);
        return;
    }
    
    NSInteger requestType = [json[@"reqType"] integerValue];
    NSInteger errorCode = [json[@"status"] integerValue];
    NSDictionary *body = @{};
    NSString *requestID = json[@"reqId"];
    NSString *requestChannel = nil;
    if ([[json allKeys] containsObject:@"requestChannel"]) {
        requestChannel = json[@"requestChannel"];
    }
    
    SocketDidReadBlock didReadBlock = self.requestMap[requestID];
    
    if (errorCode != 0) {
        
        NSError *error = [YYSocketErrorManager errorWithErrorCode:errorCode];
        if (requestType == YYRequestType_ConnectAppraisal && [self.socketDelegate respondsToSelector:@selector(connectionAuthAppraisalFailedWithError:)]) {
            
            [self.socketDelegate connectionAuthAppraisalFailedWithError:error];
        }
        
        if (didReadBlock) {
            
            didReadBlock(error,body);
        }
        
        return;
    }
    
    switch (requestType) {
        case YYRequestType_ConnectAppraisal:
        {
            [self didConnectionAuthAppraisal];//开始发心跳包
            NSDictionary *systemTimeDic = [body mutableCopy];
            [self differenceOfLocalTimeAndServerTime:[systemTimeDic[@"system_time"] longLongValue]];
        }
            break;
        case YYRequestType_Beat:
        {
            
            [self.socketManager resetBeatCount];
        }
            break;
        case YYRequestType_GetConversationsList:
        {
            if (didReadBlock) {
                
                didReadBlock(nil,body);
            }
        }
            break;
    
        default:
        {
            if ([self.socketDelegate respondsToSelector:@selector(socketReadedData:forType:)]) {
                
                [self.socketDelegate  socketReadedData:body forType:requestType];
            }
        }
            break;
    }
    
    //继续读取数据
    [self.socketManager socketBeginReadData];
    
}

- (YYSocketConnectStatus)connectStatus{
    
    return (YYSocketConnectStatus)self.socketManager.connectStatus;
}












@end
