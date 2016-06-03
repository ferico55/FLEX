//
//  Talk.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TalkComment.h"

@implementation TalkComment

+ (RKObjectMapping *)mapping {
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TalkComment class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY
                                                        }];

    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:[TalkCommentResult mapping]]];
    return statusMapping;
}

@end
