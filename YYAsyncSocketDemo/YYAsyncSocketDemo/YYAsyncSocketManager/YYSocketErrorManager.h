//
//  YYSocketErrorManager.h
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYSocketErrorManager : NSObject


/**
 服务器定义错误类型
 */
#define YY_REQUEST_TIMEOUT              @"请求超时"
#define YY_REQUEST_PARAM_ERROR          @"入参错误"
#define YY_REQUEST_ERROR                @"请求失败"
#define YY_SERVER_MAINTENANCE_UPDATES   @"用户状态丢失"
#define YY_AUTHAPPRAISAL_FAILED         @"Token 失效"


/**
 SDK内定义错误信息
 */
#define YY_NETWORK_DISCONNECTED         @"网络断开"
#define YY_LOCAL_REQUEST_TIMEOUT        @"本地请求超时"
#define YY_JSON_PARSE_ERROR             @"JSON 解析错误"
#define YY_LOCAL_PARAM_ERROR            @"本地入参错误"

+ (NSError *)errorWithErrorCode:(NSInteger )errorCode;

@end
