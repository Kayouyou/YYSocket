//
//  YYKeyChainManager.h
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYKeyChainManager : NSObject

@property (nonatomic, strong) NSString *token;

+ (YYKeyChainManager *)sharedInstance;


@end
