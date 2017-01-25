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
    return FBTweakValue(@"Security Question", @"General", @"Show Security Question", NO);
}

+ (BOOL)autoSendOTPBySMS {
    return FBTweakValue(@"Security Question", @"General", @"Auto Send OTP By SMS", NO);
}

@end
