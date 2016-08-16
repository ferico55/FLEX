//
//  UploadImageResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "UploadImageResult.h"

@implementation UploadImageResult

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"pic_id",
                      @"file_path",
                      @"file_th",
                      @"pic_obj",
                      @"pic_src",
                      @"file_name",
                      @"file_uploaded",
                      @"is_success",
                      @"src"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"upload" toKeyPath:@"upload" withMapping:[Upload mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image" toKeyPath:@"image" withMapping:[UploadImageImage mapping]]];
    return mapping;
}

@end
