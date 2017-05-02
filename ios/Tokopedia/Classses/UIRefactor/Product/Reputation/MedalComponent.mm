//
//  MedalComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MedalComponent.h"

@implementation MedalComponent

+ (instancetype)newMedalWithLevel:(NSInteger)level set:(NSInteger)set imageCache:(ImageStorage *)imageCache selector:(SEL)sel {
    NSInteger intSet = set;
    NSInteger intLevel = set == 0? 1 : level; //need to show at least one medal
    
    std::vector<CKStackLayoutComponentChild> medal;
    UIImage *medalImage;
    
    switch(intSet) {
        case 0:
            medalImage = [imageCache cachedImageWithDescription:@"IconMedal"];
            break;
        case 1:
            medalImage = [imageCache cachedImageWithDescription:@"IconMedalBronze"];
            break;
        case 2:
            medalImage = [imageCache cachedImageWithDescription:@"IconMedalSilver"];
            break;
        case 3:
            medalImage = [imageCache cachedImageWithDescription:@"IconMedalGold"];
            break;
        default:
            medalImage = [imageCache cachedImageWithDescription:@"IconMedalDiamond"];
            break;
    }
    
    for (NSInteger ii = 0; ii < intLevel; ii++) {
        medal.push_back({
           [CKImageComponent
            newWithImage:medalImage
            size:{14,14}]
        });
    }
    
    return [super newWithComponent:
            [CKStackLayoutComponent
             newWithView:{
                 [UIView class],
                 {
                     CKComponentTapGestureAttribute(sel)
                 }
             }
             size:{.minWidth = 50} //prevent bounding rect from being too small to touch
             style:{
                 .direction = CKStackLayoutDirectionHorizontal
             }
             children:medal]];
}

@end
