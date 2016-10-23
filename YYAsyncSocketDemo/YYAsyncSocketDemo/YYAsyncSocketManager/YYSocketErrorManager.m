//
//  YYSocketErrorManager.m
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#import "YYSocketErrorManager.h"

@implementation YYSocketErrorManager

+ (NSError *)errorWithErrorCode:(NSInteger )errorCode{
    
    NSString *errorMessage;
    switch (errorCode) {
        case 1:
            errorMessage = YY_REQUEST_ERROR;
            errorCode = 1001;
            break;
        case 2:
            errorMessage = YY_REQUEST_PARAM_ERROR;
            errorCode = 1002;
            break;
        case 3:
            errorMessage = YY_REQUEST_TIMEOUT;
            errorCode = 1003;
            break;
        case 4:
            errorMessage = YY_SERVER_MAINTENANCE_UPDATES;
            errorCode = 1004;
            break;
        case 1005:
            errorMessage = YY_AUTHAPPRAISAL_FAILED;
            break;
        case 2001:
            errorMessage = YY_NETWORK_DISCONNECTED;
            break;
        case 2002:
            errorMessage = YY_LOCAL_REQUEST_TIMEOUT;
            break;
        case 2004:
            errorMessage = YY_JSON_PARSE_ERROR;
            break;
        case 2003:
            errorMessage = YY_LOCAL_PARAM_ERROR;
            break;
        default:
            break;
    }
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:errorCode
                           userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
    

}
@end
