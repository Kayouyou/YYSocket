//
//  YYSocketModel.m
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//


//http://zeeyang.com/2016/01/17/GCDAsyncSocket-socket/
#import "YYSocketModel.h"

@implementation YYSocketModel

- (NSString *)socketModelToJSONString{
    
    NSAssert(self.body != nil, @"Argument must be non-nil");
    
    if (![self.body isKindOfClass:[NSDictionary class]]) {
        
        return nil;
    }
    
    NSString *bodyString = [self dictionnaryObjectToString:self.body];
    self.body = (NSDictionary *)bodyString;
    NSString *jsonString = [self toJSONString];
    
    /*
     这个\r\n是socket消息的边界符，是为了防止发生消息黏连，没有\r\n的话，可能由于某种原因，后端会收到两条socket请求，但是后端不知道怎么拆分这两个请求,而且GCDAsyncSocket不支持自定义边界符，它提供了四种边界符供你使用\r\n、\r、\n、空字符串

     */
    jsonString = [jsonString stringByAppendingString:@"\r\n"];
    
    return jsonString;

}

- (NSString *)dictionnaryObjectToString:(NSDictionary *)object{
    
    NSError *error = nil;
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    }
    
    //里面可能包含\n " "需要替换掉
    NSString *jsonString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return jsonString;
}


@end
