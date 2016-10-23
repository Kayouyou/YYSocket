//
//  YYAsyncSocketOperationManager.h
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,YYRequestType) {
    
    YYRequestType_Beat  =                1,//心跳
    YYRequestType_GetConversationsList,    //获取会话列表
    YYRequestType_ConnectAppraisal,        //选择鉴权
};

typedef NS_ENUM(NSInteger, YYSocketConnectStatus) {
    
    YYSocketConnectStatus_Disconnected     = -1,//未连接
    YYSocketConnectStatus_Connecting       = 0,//正在连接
    YYSocketConnectStatus_DidConnected     = 1,//已连接
};


/**
 socket回调
 
 @param error 返回的错误信息
 @param data  返回的回调信息
 */
typedef void (^SocketDidReadBlock)(NSError *__nullable error, id __nullable data);


/**
 业务常用代理协议！！！目的是为了监听几个时机，还可以优化！
 */
@protocol YYSocketDelegate <NSObject>

@optional

/**
 服务器发来消息
 
 @param data 数据
 @param type 返回类型
 */
- (void)socketReadedData:(nullable id)data forType:(NSInteger)type;


/**
 连上时
 */
- (void)socketDidConncet;


/**
 建里链接时检测到token失败
 
 @param error 错误描述
 */
- (void)connectionAuthAppraisalFailedWithError:(nonnull  NSError *)error;


@end

@interface YYAsyncSocketOperationManager : NSObject

//连接状态
@property (nonatomic, assign, readonly) YYSocketConnectStatus connectStatus;

//当前请求通道
@property (nonatomic, strong, nonnull) NSString *currentConnectChannel;

//socket代理回调
@property (nonatomic, copy, nullable) id<YYSocketDelegate>socketDelegate;

//单例对象
+ (nullable YYAsyncSocketOperationManager *)sharedInstance;

//初始化socket
- (void)createSocketWithToken:(nonnull NSString *)token channel:(nonnull NSString *)channel;

//断开连接
- (void)disconnectSocket;


/**
 通用的发送数据

 @param type     请求类型
 @param body     请求体
 @param callBack 请求结果回调
 */
- (void)socketWriteDataWithRequestType:(YYRequestType)type
                           requestBody:(nonnull NSDictionary *)body
                            completion:(nonnull SocketDidReadBlock)callBack;





@end
