//
//  UploadReviewImageResult.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "UploadReviewImageResult.h"

@implementation UploadReviewImageResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *uploadReviewImageResultMapping = [RKObjectMapping mappingForClass:[UploadReviewImageResult class]];
    
    [uploadReviewImageResultMapping addAttributeMappingsFromArray:@[@"success",
                                                                    @"message_status",
                                                                    @"server_id",
                                                                    @"pic_src",
                                                                    @"pic_obj"]];
    
    return uploadReviewImageResultMapping;
}

@end
