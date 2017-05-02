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
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    baseUrl = kTkpdBaseURLString;
    
    [_baseUrlText setText:baseUrl];
}

- (IBAction)tapSwithButton:(id)sender {
    baseUrl = _baseUrlText.text;
    [self dismissWithClickedButtonIndex:-1 animated:YES];
    [self dismissindex:-1 silent:YES animated:YES];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    [secureStorage setKeychainWithValue:baseUrl withKey:@"AppBaseUrl"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeBaseUrl" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TkpdNotificationForcedLogout object:nil];
}

- (IBAction)tapCancelButton:(id)sender {
    [self dismissWithClickedButtonIndex:-1 animated:YES];
    [self dismissindex:-1 silent:YES animated:YES];
}

@end
