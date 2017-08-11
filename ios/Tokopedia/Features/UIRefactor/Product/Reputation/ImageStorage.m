//
//  ImageStorage.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ImageStorage.h"

@implementation ImageStorage

- (void)initImageStorage {
    _imageCache = [NSMutableDictionary new];
}

- (void)loadImageNamed:(NSString *)imageName description:(NSString *)description {
    UIImage *image = [UIImage imageNamed:imageName];
    
    [_imageCache setValue:image forKey:description];
}

- (UIImage*)cachedImageWithDescription:(NSString *)description {
    return [_imageCache objectForKey:description];
}

@end
