//
//  MedalComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MedalComponent.h"

@implementation MedalComponent

+ (instancetype)newMedalWithLevel:(NSInteger)level set:(NSInteger)set {
    NSInteger intLevel = level;
    NSInteger intSet = set;
    std::vector<CKStackLayoutComponentChild> medal;
    UIImage *medalImage;
    
    switch(intSet) {
        case 0:
            medalImage = [UIImage imageNamed:@"icon_medal14.png"];
            break;
        case 1:
            medalImage = [UIImage imageNamed:@"icon_medal_bronze14.png"];
            break;
        case 2:
            medalImage = [UIImage imageNamed:@"icon_medal_silver14.png"];
            break;
        case 3:
            medalImage = [UIImage imageNamed:@"icon_medal_gold14.png"];
            break;
        default:
            medalImage = [UIImage imageNamed:@"icon_medal_diamond_one14.png"];
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
             newWithView:{}
             size:{}
             style:{
                 .direction = CKStackLayoutDirectionHorizontal
             }
             children:medal]];
}

@end
