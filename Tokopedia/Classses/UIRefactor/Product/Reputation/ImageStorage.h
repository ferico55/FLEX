//
//  ImageStorage.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageStorage : NSObject

@property (nonatomic, strong) NSMutableDictionary *imageCache;

- (void)initImageStorage;

- (void)loadImageNamed:(NSString*)imageName
           description:(NSString*)description;

- (UIImage*)cachedImageWithDescription:(NSString*)description;

@end
