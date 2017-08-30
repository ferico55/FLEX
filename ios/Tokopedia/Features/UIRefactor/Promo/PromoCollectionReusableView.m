//
//  PromoCollectionReusableView.m
//  Tokopedia
//
//  Created by Tokopedia on 7/31/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoCollectionReusableView.h"
#import "ProductCell.h"
#import "ProductThumbCell.h"
#import "WebViewController.h"
#import "Tokopedia-Swift.h"

typedef NS_ENUM(NSInteger, PromoCellHeight) {
    PromoNormalCellHeight = 300,
    PromoNormalCellHeightSix = 280,
    PromoNormalCellHeightSixPlus = 340,
    PromoThumbnailCellHeight = 160,
    PromoThumbnailCellHeightSix = 180,
    PromoThumbnailCellHeightSixPlus = 274,
};

@interface PromoCollectionReusableView ()
<
UICollectionViewDataSource,
UICollectionViewDelegate
>

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSString *cellNibName;
@property (strong, nonatomic) NSString *cellIdentifier;

@end

@implementation PromoCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [_collectionView setCollectionViewLayout:_flowLayout];
    
    if (IS_IPAD) {
        _flowLayout.minimumLineSpacing = 14;
    }
    
    
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    UINib *cellNib = [UINib nibWithNibName:@"ProductCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ProductCellIdentifier"];
    
    UINib *thumbCellNib = [UINib nibWithNibName:@"ProductThumbCell" bundle:nil];
    [_collectionView registerNib:thumbCellNib forCellWithReuseIdentifier:@"ProductThumbCellIdentifier"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    _infoButton.userInteractionEnabled = YES;
    [_infoButton addGestureRecognizer:tap];
    
    _headerViewHeightConstraint.constant = 0;
}

- (void)setCollectionViewCellType:(PromoCollectionViewCellType)collectionViewCellType {
    _collectionViewCellType = collectionViewCellType;
    if (_collectionViewCellType == PromoCollectionViewCellTypeNormal) {
        _flowLayout.itemSize = [PromoCollectionReusableView itemSize:_collectionViewCellType];
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _cellNibName = @"ProductCell";
        _cellIdentifier = @"ProductCellIdentifier";
        _collectionViewHeightConstraint.constant = [self collectionHeightConstraint];
        _collectionView.scrollIndicatorInsets = UIEdgeInsetsZero;
        
    }
    
    else if (_collectionViewCellType == PromoCollectionViewCellTypeThumbnail) {
        _flowLayout.itemSize = [PromoCollectionReusableView itemSize:_collectionViewCellType];
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _cellNibName = @"ProductThumbCell";
        _cellIdentifier = @"ProductThumbCellIdentifier";
        _collectionViewHeightConstraint.constant = [self collectionHeightConstraint];
        _collectionView.scrollIndicatorInsets = UIEdgeInsetsZero;
        
    }
    
    [_collectionView reloadData];
}

- (void)setPromo:(NSArray *)promo {
    _promo = promo;
    [_collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _promo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_collectionViewCellType == PromoCollectionViewCellTypeNormal) {
        ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCellIdentifier" forIndexPath:indexPath];
        PromoResult *promoResult = [_promo objectAtIndex:indexPath.row];
        [cell setViewModel:promoResult.viewModel];
        [cell removeWishlistButton];
        return cell;
        
    } else if (_collectionViewCellType == PromoCollectionViewCellTypeThumbnail) {
        ProductThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
        PromoResult *promoResult = [_promo objectAtIndex:indexPath.row];
        [cell setViewModel:promoResult.viewModel];
        [cell removeWishlistButton];
        return cell;
        
    } else {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if([cell isKindOfClass:[ProductCell class]]) {
            [((ProductCell*) cell) removeWishlistButton];
        }
        else if([cell isKindOfClass:[ProductThumbCell class]]) {
            [((ProductThumbCell*) cell) removeWishlistButton];
        }
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectPromoProduct:)]) {
        PromoResult *promoResult = [_promo objectAtIndex:indexPath.row];
        [AnalyticsManager trackPromoClick:promoResult];
        [self.delegate didSelectPromoProduct:promoResult];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint point = *targetContentOffset;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat visibleWidth = layout.minimumInteritemSpacing + layout.itemSize.width;
    int indexOfItemToSnap = round(point.x / visibleWidth);
    if (indexOfItemToSnap + 1 == [self.collectionView numberOfItemsInSection:0]) {
        *targetContentOffset = CGPointMake(self.collectionView.contentSize.width - self.collectionView.bounds.size.width, 0);
    } else {
        *targetContentOffset = CGPointMake((indexOfItemToSnap * visibleWidth)-self.collectionView.contentInset.left, 0);
    }
}

- (IBAction)tap:(id)sender {
    TopAdsInfoActionSheet *alert = [TopAdsInfoActionSheet new];
    [alert show];
}

- (void)centerPositionAnimated:(BOOL)animated {
    if (IS_IPAD) return;
    NSInteger maxCount = 2;
    if (_collectionViewCellType == PromoCollectionViewCellTypeThumbnail) maxCount = 3;
    if ([_scrollPosition integerValue] == 0 && _promo.count > maxCount) {
        NSInteger x = _flowLayout.itemSize.width / 2;
        x += 5; // add cell spacing
        [_collectionView setContentOffset:CGPointMake(x, 0) animated:animated];
    }
}

- (void)scrollToCenter {
    NSLog(@"\n\n%ld\n\n", (long)self.indexPath.section);
    if (IS_IPAD) return;
    if (_indexPath.section == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self centerPositionAnimated:YES];
        });
    } else {
        [self centerPositionAnimated:YES];
    }
}

- (void)scrollToCenterWithoutAnimation {
    if (IS_IPAD) return;
    [self centerPositionAnimated:NO];
}

//- (void)setScrollPosition:(NSNumber *)scrollPosition {
//    _scrollPosition = scrollPosition;
//    if (IS_IPAD) return;
//    NSInteger x = [_scrollPosition integerValue] * _flowLayout.itemSize.width;
//    NSInteger padding = [_scrollPosition integerValue] * _flowLayout.minimumLineSpacing;
//    CGPoint point = CGPointMake(x + padding, 0);
//    _collectionView.contentOffset = point;
//}

- (void)animateScrollToCenter {
    if (IS_IPAD) return;
    if ([_scrollPosition integerValue] == 0 && _promo.count > 2) {
        NSInteger x = _flowLayout.itemSize.width / 2;
        x += 5; // add cell spacing
        [_collectionView setContentOffset:CGPointMake(x, 0) animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(promoDidScrollToPosition:atIndexPath:)]) {
        NSInteger position = scrollView.contentOffset.x / self.flowLayout.itemSize.width;
        [self.delegate promoDidScrollToPosition:[NSNumber numberWithInteger:position] atIndexPath:_indexPath];
    }
}

- (NSString*)topadsUrlFromSource:(TopadsSource)source {
    NSDictionary* sources = @{
                              @(TopadsSourceFeed) : @"fav_product",
                              @(TopadsSourceSearch) : @"search",
                              @(TopadsSourceHotlist) : @"hotlist",
                              @(TopadsSourceDirectory) : @"directory"
                              };
    
    return [sources objectForKey:@(source)];
}

- (CGFloat)collectionHeightConstraint {
    CGFloat height = [self viewHeight];
    height -= 33;
    return height;
}

- (CGFloat)viewHeight {
    CGFloat height = [PromoCollectionReusableView collectionViewHeightForType:_collectionViewCellType];
    return height;
}

+ (CGFloat)collectionViewHeightForType:(PromoCollectionViewCellType)type {
    CGFloat height;
    CGSize itemSize = [self itemSize:type];
    
    if (type == PromoCollectionViewCellTypeNormal) {
        height = itemSize.height + 40;
    } else if (type == PromoCollectionViewCellTypeThumbnail) {
        height = itemSize.height * 2 + 40;
    }
    
    return height;
}

+ (CGFloat)collectionViewNormalHeight {
    return [self collectionViewHeightForType:PromoCollectionViewCellTypeNormal];
}

+ (CGSize)itemSize:(NSInteger)type {
    CGSize cellSize = CGSizeMake(0, 0);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGFloat cellWidth;
    CGFloat cellHeight;
    if (type == PromoCollectionViewCellTypeNormal) {
        BOOL isPad = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        CGFloat numberOfCell = isPad ? 4 : 2;
        cellWidth = screenWidth/numberOfCell;
        cellHeight = cellWidth + 135;
        
    } else if (type == PromoCollectionViewCellTypeThumbnail) {
        BOOL isPad = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        CGFloat numberOfCell = isPad ? 2 : 1;
        cellWidth = screenWidth/numberOfCell;
        cellHeight = 140;
    }
    
    
    cellSize = CGSizeMake(cellWidth, cellHeight);
    return cellSize;
}


@end
