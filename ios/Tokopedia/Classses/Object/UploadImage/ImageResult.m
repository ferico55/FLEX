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
                                                        @"src",
                                                        @"is_success",
                                                        @"pic_id",
                                                        @"file_path",
                                                        @"file_uploaded",
														@"file_th",
                                                        ]];
    
    [imageResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image" toKeyPath:@"image" withMapping:[UploadDataImage mapping]]];

    [imageResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"upload" toKeyPath:@"upload" withMapping:[UploadDataImage mapping]]];

    [imageResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[UploadDataImage mapping]]];

    return imageResultMapping;
}

- (UploadDataImage *)image {
    if (_upload && _image == nil) {
        _image = _upload;
    }
    return _image;
}

@end
