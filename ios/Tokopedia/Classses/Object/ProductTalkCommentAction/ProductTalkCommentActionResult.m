//
//  ProductTalkCommentActionResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductTalkCommentAction.h"
#import "ProductTalkDetailViewController.h"
#import "ProductTalkCommentActionResult.h"

@implementation ProductTalkCommentActionResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProductTalkCommentActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success", @"comment_id":@"comment_id"}];
    return resultMapping;
}
@end
