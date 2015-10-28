//
//  PromoCollectionReusableView.h
//  Tokopedia
//
//  Created by Tokopedia on 7/31/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PromoProduct.h"

typedef NS_ENUM(NSInteger, PromoCollectionViewCellType) {
    PromoCollectionViewCellTypeThumbnail,
    PromoCollectionViewCellTypeNormal,
};

@protocol PromoCollectionViewDelegate <NSObject>

- (void)promoDidScrollToPosition:(NSNumber *)position atIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectPromoProduct:(PromoProduct *)product;

@end

@interface PromoCollectionReusableView : UICollectionReusableView

@property (strong, nonatomic) NSArray *promo;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) PromoCollectionViewCellType collectionViewCellType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@property (weak, nonatomic) id<PromoCollectionViewDelegate> delegate;
@property (strong, nonatomic) NSNumber *scrollPosition;
@property (strong, nonatomic) NSIndexPath *indexPath;

- (void)scrollToCenter;
- (void)scrollToCenterWithoutAnimation;
+ (CGFloat)collectionViewHeightForType:(PromoCollectionViewCellType)type;
+ (CGFloat)collectionViewNormalHeight;

@end