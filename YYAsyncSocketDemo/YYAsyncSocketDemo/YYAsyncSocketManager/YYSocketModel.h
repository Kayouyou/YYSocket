//
//  YYSocketModel.h
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//




/**
 实际用的时候需要和后端的开发人员商定好socket协议格式
 比如：[NSString stringWithFormat:@"{\"version\":%d,\"reqType\":%d,\"body\":\"%@\"}\r\n",PROTOCOL_VERSION,reqType,reqBody]；

 */
#import <JSONModel/JSONModel.h>


/**
 json转model的牛逼库，这里根据业务的实际需求来定义属性
 */
@interface YYSocketModel : JSONModel


/**
 socket协议的版本号
 */
@property (nonatomic, assign) NSInteger version;


/**
 socket请求类型
 */
@property (nonatomic, assign) NSInteger reqType;


/**
 根据时间戳生成的socket唯一请求id
 */
@property (nonatomic, strong) NSString<Optional>*reqID;


/**
 socket通道，支持单通道和多通道
 */
@property (nonatomic, strong) NSString<Optional>*requsetChannel;


/**
 socket请求体
 */
@property (nonatomic, strong) NSDictionary<Optional>*body;


/**
 发送心跳是携带的接收到的最新消息的id
 */
@property (nonatomic, assign) NSInteger user_mid;



- (NSString *)socketModelToJSONString;


@end
