//
//  VerifiedStatusMSISDN.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "VerifiedStatusMSISDN.h"

@implementation VerifiedStatusMSISDN
+(RKObjectMapping *)mapping{
    RKObjectMapping *msisdnMapping = [RKObjectMapping mappingForClass:[VerifiedStatusMSISDN class]];
    [msisdnMapping addAttributeMappingsFromArray:@[@"show_dialog", @"user_phone", @"is_verified"]];
    return msisdnMapping;
}
@end
