//
//  InboxMessageActionResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageAction.h"
#import "InboxMessageViewController.h"
#import "InboxMessageActionResult.h"

@implementation InboxMessageActionResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxMessageActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success": @"is_success"}];
    return resultMapping;
}
@end
