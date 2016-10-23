//
//  YYAsyncSocketManager.h
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, ConnectStatus) {
    
    DisConnected        = -1,//未连接
    isConnecting        =  0,//链接中
    DidConnected        =  1 //已链接
};


/**
 这一层是对GCDsocket的封装的一个操作层，不是具体的业务逻辑层 单例类
 */
@interface YYAsyncSocketManager : NSObject

@property (nonatomic, assign) ConnectStatus connectStatus;
@property (nonatomic, assign) NSInteger reConnectionCount;//建立接连失败重连次数


/**
 获取单例

 @return 返回单例对象
 */
+ (nullable YYAsyncSocketManager *)sharedInstance;


/**
 链接socket

 @param delegate 代理
 */
- (void)connectSocketWithDelegate:(nonnull id)delegate;


/**
 socket 链接成功后发送心跳操作

 @param beatBody 心跳包body
 */
- (void)socketDidConnectBeginSendBeat:(nonnull NSString *)beatBody;


/**
 socket 连接失败后重接操作

 @param reconnectBody 重连心跳body
 */
- (void)socketDidDisconnectBeginSendReconnect:(nonnull NSString *)
reconnectBody;


/**
 先服务器发送数据

 @param data body数据
 */
- (void)socketWriteData:(nonnull NSString *)data;


/**
 socket 读取数据
 */
- (void)socketBeginReadData;


/**
 socket 主动断开链接
 */
- (void)disconnectSocket;


/**
 重设心跳次数
 */
- (void)resetBeatCount;






@end
