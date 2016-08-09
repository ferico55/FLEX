//
//  ProductImages.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductImages.h"

@implementation ProductImages

- (NSString*)image_description {
    return [_image_description kv_decodeHTMLCharacterEntities];
}


+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
    
    [mapping addAttributeMappingsFromArray:@[@"image_id", @"image_status", @"image_description", @"image_primary", @"image_src"]];
    
    return mapping;
}

@end
