//
//  InboxMessageDetailResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageDetailResult.h"
#import "InboxMessageDetailBetween.h"
#import "string_home.h"
#import "inbox.h"

@implementation InboxMessageDetailResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxMessageDetailResult class]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:[InboxMessageDetailList mapping]];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *betweenRel = [RKRelationshipMapping relationshipMappingFromKeyPath:KTKPDMESSAGE_BETWEENCONVERSATIONKEY toKeyPath:KTKPDMESSAGE_BETWEENCONVERSATIONKEY withMapping:[InboxMessageDetailBetween mapping]];
    [resultMapping addPropertyMapping:betweenRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:[Paging mapping]];
    [resultMapping addPropertyMapping:pageRel];
    
    return resultMapping;
}

@end
