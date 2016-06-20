//
//  UploadDataImage.m
//  Tokopedia
//
//  Created by Tokopedia on 4/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "UploadDataImage.h"

@implementation UploadDataImage

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"message_status", @"pic_code", @"pic_src", @"src", @"success", @"is_success", @"file_uploaded"]];
    return mapping;
}

- (NSString *)pic_src {
    if (_src && _pic_src == nil) {
        _pic_src = _src;
    }
    return _pic_src;
}

@end
