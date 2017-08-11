//
//  SecurityQuestionTweaks.m
//  Tokopedia
//
//  Created by Billion Goenawan on 12/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SecurityQuestionTweaks.h"

@implementation SecurityQuestionTweaks

+ (BOOL)alwaysShowSecurityQuestion {
    return FBTweakValue(@"Others", @"Security", @"Show Security Question", NO);
}

+ (BOOL)autoSendOTPBySMS {
    return FBTweakValue(@"Others", @"Security", @"Auto Send OTP By SMS", NO);
}

@end
