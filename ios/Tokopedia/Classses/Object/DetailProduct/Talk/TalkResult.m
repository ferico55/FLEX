//
//  TalkResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "Talk.h"
#import "InboxTalkViewController.h"
#import "TalkResult.h"
#import "Tokopedia-Swift.h"

@implementation TalkResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TalkResult class]];


    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                 toKeyPath:kTKPD_APILISTKEY
                                                                               withMapping:[TalkList mapping]];
    [resultMapping addPropertyMapping:listRel];

    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                                 toKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                               withMapping:[Paging mapping]];

    [resultMapping addPropertyMapping:pageRel];
    return resultMapping;
}
@end
