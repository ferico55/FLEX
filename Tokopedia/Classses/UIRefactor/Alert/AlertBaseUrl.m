//
//  AlertReputation.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertBaseUrl.h"

#define TkpdNotificationForcedLogout @"NOTIFICATION_FORCE_LOGOUT"

@implementation AlertBaseUrl



- (void)awakeFromNib {
    self.layer.cornerRadius = 5;
    baseUrl = kTkpdBaseURLString;
}

- (IBAction)tapBeta:(id)sender {
    baseUrl = @"http://staging.tokopedia.com/ws";
    [self didChangeButtonColor:_betaButton];
}

- (IBAction)tapDev:(id)sender {
    baseUrl = @"http://alpha.tokopedia.com/ws";
    [self didChangeButtonColor:_devButton];
}

- (IBAction)tapLive:(id)sender {
    baseUrl = @"http://staging.tokopedia.com/ws";
    [self didChangeButtonColor:_liveButton];
}

- (void)didChangeButtonColor:(UIButton*)button {
    [self dismissWithClickedButtonIndex:-1 animated:YES];
    [self dismissindex:-1 silent:YES animated:YES];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    [secureStorage setKeychainWithValue:baseUrl withKey:@"AppBaseUrl"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeBaseUrl" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TkpdNotificationForcedLogout object:nil];
    
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
}


@end
