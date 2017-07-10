//
//  HeaderIntermediaryCollectionReusableView.h
//  Tokopedia
//
//  Created by Billion Goenawan on 3/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PromoProduct.h"
#import "PromoResult.h"
#import "PromoCollectionReusableView.h"
#import "Tokopedia-Swift.h"

@protocol HeaderIntermediaryCollectionViewDelegate <NSObject>

- (void)promoDidScrollToPosition:(NSNumber *)position atIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectPromoProduct:(PromoProduct *)product;
- (TopadsSource)topadsSource;

@end

@interface HeaderIntermediaryCollectionReusableView : UICollectionReusableView

@property (strong, nonatomic) NSArray<PromoResult*> *promo;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong, nonatomic) IBOutlet UIImageView* infoButton;
@property (nonatomic) PromoCollectionViewCellType collectionViewCellType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@property (weak, nonatomic) id<HeaderIntermediaryCollectionViewDelegate> delegate;
@property (strong, nonatomic) NSNumber *scrollPosition;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
@property (strong, nonatomic) IBOutlet CategoryIntermediarySubCategoryView *subCategoryView;
@property (nonatomic) BOOL isRevamp;

- (void)scrollToCenter;
- (void)scrollToCenterWithoutAnimation;
- (void) setTotalProduct: (NSString*)totalProduct;
- (void) setHeaderTitle: (NSString*) title;
- (void) setPromotionEmpty;
- (void) setPromotionNotEmpty;
+ (CGFloat)collectionViewHeightForType:(PromoCollectionViewCellType)type;
+ (CGFloat)collectionViewNormalHeight;
- (void) setBanner: (CategoryIntermediaryBanner *) banner didSelectBanner: (void (^)(Slide* slide)) didSelectBanner;
- (void) hideHeader;
- (void) closeHeader;

@end
