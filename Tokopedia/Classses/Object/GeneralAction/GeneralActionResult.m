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
    RKObjectMapping *generalActionResultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    
    [generalActionResultMapping addAttributeMappingsFromArray:@[@"feedback_id",
                                                                @"is_success"]];
    
    return generalActionResultMapping;
}

+(RKObjectMapping *)generalMapping{
    RKObjectMapping *generalActionResultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    
    [generalActionResultMapping addAttributeMappingsFromArray:@[@"is_success"]];
    
    return generalActionResultMapping;
}
@end
