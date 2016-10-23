//
//  YYKeyChainManager.m
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#import "YYKeyChainManager.h"

@implementation YYKeyChainManager


+ (YYKeyChainManager *)sharedInstance{
    
    static YYKeyChainManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        sharedInstance = [[self alloc] init];;
    });
    
    return sharedInstance;
}

- (void)setToken:(NSString *)token{
    
    if (_token != token) {
        
        _token = token;
    }
}


@end
