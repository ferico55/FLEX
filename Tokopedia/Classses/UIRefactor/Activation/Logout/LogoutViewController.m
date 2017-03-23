//
//  LogoutViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LogoutViewController.h"
#import "TokopediaNetworkManager.h"
#import "UserAuthentificationManager.h"

@interface LogoutViewController ()

@end

@implementation LogoutViewController {
    UserAuthentificationManager *_userManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userManager = [UserAuthentificationManager new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tokopedia Network Delegate
- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *param =  @{
             @"device_id" : [_userManager getMyDeviceToken] //token device from ios
             };
    
    return param;
}

- (NSString *)getPath:(int)tag {
    return @"logout.pl";
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (id)getObjectManager:(int)tag {
    return nil;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    
}



@end
