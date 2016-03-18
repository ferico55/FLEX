//
//  HotlistResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_home.h"
#import "HotlistResult.h"

@implementation HotlistResult

+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[HotlistResult class]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                                  toKeyPath:@"list"
                                                                                withMapping:[HotlistList mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                                  toKeyPath:@"paging"
                                                                                withMapping:[Paging mapping]]];
    return resultMapping;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_list forKey:kTKPDHOME_APILISTKEY];
    [encoder encodeObject:_paging forKey:kTKPDHOME_APIPAGINGKEY];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _list = [decoder decodeObjectForKey:kTKPDHOME_APILISTKEY];
        _paging = [decoder decodeObjectForKey:kTKPDHOME_APIPAGINGKEY];
    }
    return self;
}

@end
