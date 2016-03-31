//
//  Hotlist.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Hotlist.h"
#import "HotlistData.h"

@implementation Hotlist

#pragma mark NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_status forKey:kTKPD_APISTATUSKEY];
    [encoder encodeObject:_server_process_time forKey:kTKPD_APISERVERPROCESSTIMEKEY];
    [encoder encodeObject:_data forKey:@"data"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _status = [decoder decodeObjectForKey:kTKPD_APISTATUSKEY];
        _server_process_time = [decoder decodeObjectForKey:kTKPD_APISERVERPROCESSTIMEKEY];
        _data = [decoder decodeObjectForKey:@"data"];
    }
    return self;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromDictionary:@{@"status" : @"status"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[HotlistData mapping]]];
    
    return mapping;
}

@end
