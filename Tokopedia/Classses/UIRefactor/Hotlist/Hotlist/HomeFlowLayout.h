//
//  HomeFlowLayout.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HomeFlowLayoutTransitionType) {
    HomeFlowLayoutTransitionTypeHotlist
};

@interface HomeFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) HomeFlowLayoutTransitionType transitionType;

@end
