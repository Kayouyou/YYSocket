//
//  YYAsyncSocketConfig.h
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#ifndef YYAsyncSocketConfig_h
#define YYAsyncSocketConfig_h


/**
 socket config

 @return nothing
 */
#define DEV_STATE_ONLINE 1

static const int TIMEOUT = 30;

#define UPLOAD_ENV_ONLINE @"online"
#define UPLOAD_ENV_LOCAL @"local"

#if DEV_STATE_ONLINE
static NSString *HOST = @"online socket address";
static const int PORT = 7071;
#else
static NSString *HOST = @"local socket address";
static const int PORT = 7070;
#endif


#define PROTOCOL_VERSION 1

static const NSInteger kBeatLimit = 3;//重传三次

#endif /* YYAsyncSocketConfig_h */
