//
//  RatingComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RatingComponent.h"

@implementation RatingComponent
+ (instancetype)newWithRating:(NSInteger)rating {
    
    std::vector<CKStackLayoutComponentChild> stars;
    
    for (int i = 0; i < 5; i++) {
        UIImage *starImage = (i < rating)?[UIImage imageNamed:@"icon_star_active.png"]:[UIImage imageNamed:@"icon_star.png"];
        stars.push_back({
            [CKImageComponent
             newWithImage:starImage
             size:{20,20}]
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
