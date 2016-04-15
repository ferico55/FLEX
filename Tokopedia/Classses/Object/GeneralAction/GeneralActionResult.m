//
//  GeneralActionResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralAction.h"
#import "ProductTalkDetailViewController.h"
#import "GeneralActionResult.h"

@implementation GeneralActionResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success"}];
    return resultMapping;
}
@end
