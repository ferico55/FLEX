//
//  ImageResult.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ImageResult.h"

@implementation ImageResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *imageResultMapping = [RKObjectMapping mappingForClass:[ImageResult class]];
    
    [imageResultMapping addAttributeMappingsFromArray:@[@"success",
                                                        @"message_status",
                                                        @"server_id",
                                                        @"pic_src",
                                                        @"pic_obj",
                                                        @"message_error",
                                                        @"src"]];
    
    [imageResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image" toKeyPath:@"image" withMapping:[UploadDataImage mapping]]];
    
    return imageResultMapping;
}

@end
