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

@interface LogoutViewController () <TokopediaNetworkManagerDelegate>

@end

@implementation LogoutViewController {
    TokopediaNetworkManager *_networkManager;
    UserAuthentificationManager *_userManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    _userManager = [UserAuthentificationManager new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tokopedia Network Delegate
- (NSDictionary *)getParameter:(int)tag {
    return @{
             
             @"device_token_id" : @"", //auto increment from database that had been saved in secure storage
             @"device_id" : [_userManager getMyDeviceToken] //token device from ios
             };
}

- (NSString *)getPath:(int)tag {
    return @"logout.pl";
}



@end
