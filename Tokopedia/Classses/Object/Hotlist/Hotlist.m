//
//  Hotlist.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Hotlist.h"

@implementation Hotlist

#pragma mark NSCoding

+(RKObjectMapping *)mapping{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Hotlist class]];
    [statusMapping addAttributeMappingsFromArray:@[@"status", @"server_process_time"]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result"
                                                                                  toKeyPath:@"result"
                                                                                withMapping:[HotlistResult mapping]]];
    return statusMapping;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_status forKey:kTKPD_APISTATUSKEY];
    [encoder encodeObject:_server_process_time forKey:kTKPD_APISERVERPROCESSTIMEKEY];
    [encoder encodeObject:_result forKey:kTKPD_APIRESULTKEY];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _status = [decoder decodeObjectForKey:kTKPD_APISTATUSKEY];
        _server_process_time = [decoder decodeObjectForKey:kTKPD_APISERVERPROCESSTIMEKEY];
        _result = [decoder decodeObjectForKey:kTKPD_APIRESULTKEY];
    }
    return self;
}

@end
