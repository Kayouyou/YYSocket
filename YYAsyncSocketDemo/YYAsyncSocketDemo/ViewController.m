//
//  ViewController.m
//  YYAsyncSocketDemo
//
//  Created by 叶杨杨 on 2016/10/23.
//  Copyright © 2016年 叶杨杨. All rights reserved.
//

#import "ViewController.h"
#import "YYAsyncSocketOperationManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[YYAsyncSocketOperationManager sharedInstance] createSocketWithToken:@"your token" channel:@"your channel"];

}

- (void)getConversationsList{
    
    NSDictionary *requestBody = @{};
    [[YYAsyncSocketOperationManager sharedInstance] socketWriteDataWithRequestType:YYRequestType_GetConversationsList requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data) {
      
        if (error) {
            
            
        }else{
            
            
        }
        
        
        
    }];
    
    
    
    
    
    
    
    
}











- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
