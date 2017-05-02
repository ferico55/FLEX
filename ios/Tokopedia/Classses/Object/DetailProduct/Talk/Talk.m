//
//  Talk.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Talk.h"

@implementation Talk

+ (RKObjectMapping *)mapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Talk class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];


    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:[TalkResult mapping]]];
    return statusMapping;
}

- (void)setData:(TalkResult *)data {
    _data = data;
    self.result = data;
}

+(RKObjectMapping *)mapping_v4{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Talk class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:[TalkResult mapping]]];
    return statusMapping;
}
@end
