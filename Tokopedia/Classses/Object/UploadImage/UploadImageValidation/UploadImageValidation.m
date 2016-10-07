//
//  UploadImageValidation.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "UploadImageValidation.h"

@implementation UploadImageValidation

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"message_status",
                      @"message_error",
                      @"status",
                      @"server_process_time"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result"
                                                                            toKeyPath:@"result"
                                                                          withMapping:[UploadImageValidationResult mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"data"
                                                                          withMapping:[UploadImageValidationResult mapping]]];
    return mapping;
}

@end
