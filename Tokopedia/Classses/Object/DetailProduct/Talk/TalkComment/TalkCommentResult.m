//
//  TalkResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "TalkComment.h"
#import "ProductTalkDetailViewController.h"
#import "TalkCommentResult.h"

@implementation TalkCommentResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TalkCommentResult class]];

    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                 toKeyPath:kTKPD_APILISTKEY
                                                                               withMapping:[TalkCommentList mapping]];
    [resultMapping addPropertyMapping:listRel];

    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                                 toKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                               withMapping:[Paging mapping]];

    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *talkRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"talk"
                                                                                 toKeyPath:@"talk"
                                                                               withMapping:[TalkList mapping]];
    [resultMapping addPropertyMapping:talkRel];
    
    return resultMapping;
}
@end
