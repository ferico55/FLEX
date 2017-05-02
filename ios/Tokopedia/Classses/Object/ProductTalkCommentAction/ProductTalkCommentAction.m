//
//  ProductTalkCommentAction.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductTalkCommentAction.h"

@implementation ProductTalkCommentAction : NSObject

+ (RKObjectMapping *)mapping {
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProductTalkCommentAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:[ProductTalkCommentActionResult mapping]];
    [statusMapping addPropertyMapping:resulRel];
    return statusMapping;
}
@end
