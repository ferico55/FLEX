//
//  RatingComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "ImageStorage.h"

@interface RatingComponent : CKCompositeComponent
+ (instancetype)newWithRating:(NSInteger)rating imageCache:(ImageStorage*)imageCache;
@end
