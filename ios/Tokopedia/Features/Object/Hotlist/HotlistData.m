//
//  HotlistResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_home.h"
#import "HotlistData.h"
#import "HotlistList.h"
#import "Tokopedia-Swift.h"

@implementation HotlistData

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_list forKey:kTKPDHOME_APILISTKEY];
    [encoder encodeObject:_paging forKey:kTKPDHOME_APIPAGINGKEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _list = [decoder decodeObjectForKey:kTKPDHOME_APILISTKEY];
        _paging = [decoder decodeObjectForKey:kTKPDHOME_APIPAGINGKEY];
    }
    return self;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:[HotlistList mapping]];
    [mapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:[Paging mapping]];
    [mapping addPropertyMapping:pageRel];
    
    return mapping;
}


@end
