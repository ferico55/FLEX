//
//  CategoryDataSource.h
//  Tokopedia
//
//  Created by Tonito Acen on 1/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iCarousel.h"
#import "SwipeView.h"
#import "AnnouncementTickerView.h"

@interface CategoryDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) UIViewController *delegate;
@property(nonatomic, weak) iCarousel *slider;
@property(nonatomic, weak) SwipeView *digitalGoodsSwipeView;
@property(nonatomic, strong) UIView* pulsaPlaceholder;
@property(nonatomic, weak) UIView* pulsaView;
@property(nonatomic, weak) AnnouncementTickerView *ticker;

@end
