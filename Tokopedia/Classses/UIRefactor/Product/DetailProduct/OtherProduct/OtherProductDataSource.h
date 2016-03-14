//
//  OtherProductDataSource.h
//  Tokopedia
//
//  Created by Tokopedia on 3/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchAWSProduct.h"

@protocol OtherProductDelegate <NSObject>

- (void)didSelectOtherProduct:(SearchAWSProduct *)product;

@end

@interface OtherProductDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property CGSize collectionViewItemSize;

@property (weak, nonatomic) id<OtherProductDelegate> delegate;

@end
