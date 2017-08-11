//
//  ProductTalkFormResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductTalkForm.h"
#import "ProductTalkFormViewController.h"
#import "ProductTalkFormResult.h"

@implementation ProductTalkFormResult

+ (RKRelationshipMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProductTalkFormResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success", @"talk_id":@"talk_id"}];

    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    return resulRel;
}
@end
