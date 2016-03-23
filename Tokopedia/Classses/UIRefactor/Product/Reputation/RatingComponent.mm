//
//  RatingComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RatingComponent.h"

@implementation RatingComponent
+ (instancetype)newWithRating:(NSInteger)rating imageCache:(ImageStorage *)imageCache {
    
    std::vector<CKStackLayoutComponentChild> stars;
    
    for (int i = 0; i < 5; i++) {
        UIImage *starImage = (i < rating)?[imageCache cachedImageWithDescription:@"IconStarActive"]:[imageCache cachedImageWithDescription:@"IconStar"];
        stars.push_back({
            [CKImageComponent
             newWithImage:starImage
             size:{15,15}]
        });
    }
    
    return [super newWithComponent:
            [CKStackLayoutComponent
             newWithView:{}
             size:{}
             style:{
                 .direction = CKStackLayoutDirectionHorizontal
             }
             children:stars]];
}

@end
