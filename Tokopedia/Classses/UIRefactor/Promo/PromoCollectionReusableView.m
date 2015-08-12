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
#import "PromoInfoAlertView.h"
#import "WebViewController.h"

typedef NS_ENUM(NSInteger, PromoCellHeight) {
    PromoNormalCellHeight = 260,
    PromoNormalCellHeightSix = 310,
    PromoNormalCellHeightSixPlus = 340,
    PromoThumbnailCellHeight = 160,
    PromoThumbnailCellHeightSix = 180,
    PromoThumbnailCellHeightSixPlus = 190,
};

@interface PromoCollectionReusableView ()
<
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    TKPDAlertViewDelegate
>

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSString *cellNibName;
@property (strong, nonatomic) NSString *cellIdentifier;

@end

@implementation PromoCollectionReusableView

- (void)awakeFromNib {
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [_collectionView setCollectionViewLayout:_flowLayout];
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    UINib *cellNib = [UINib nibWithNibName:@"ProductCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ProductCellIdentifier"];
    
    UINib *thumbCellNib = [UINib nibWithNibName:@"ProductThumbCell" bundle:nil];
    [_collectionView registerNib:thumbCellNib forCellWithReuseIdentifier:@"ProductThumbCellIdentifier"];
}

- (void)setCollectionViewCellType:(PromoCollectionViewCellType)collectionViewCellType {
    _collectionViewCellType = collectionViewCellType;
    if (_collectionViewCellType == PromoCollectionViewCellTypeNormal) {
        _flowLayout.itemSize = [self itemSize];
        _cellNibName = @"ProductCell";
        _cellIdentifier = @"ProductCellIdentifier";
        _collectionViewHeightConstraint.constant = [self collectionHeightConstraint];
        _collectionView.scrollIndicatorInsets = UIEdgeInsetsZero;

        CGRect frame = self.frame;
        frame.size.height = [self viewHeight];
        self.frame = frame;        
    }
    
    else if (_collectionViewCellType == PromoCollectionViewCellTypeThumbnail) {
        _flowLayout.itemSize = [self itemSize];
        _cellNibName = @"ProductThumbCell";
        _cellIdentifier = @"ProductThumbCellIdentifier";
        _collectionViewHeightConstraint.constant = [self collectionHeightConstraint];
        _collectionView.scrollIndicatorInsets = UIEdgeInsetsZero;

        CGRect frame = self.frame;
        frame.size.height = [self viewHeight];
        self.frame = frame;
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
        PromoProduct *product = [_promo objectAtIndex:indexPath.row];
        [cell setViewModel:product.viewModel];
        return cell;
        
    } else if (_collectionViewCellType == PromoCollectionViewCellTypeThumbnail) {
        ProductThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
        PromoProduct *product = [_promo objectAtIndex:indexPath.row];
        [cell setViewModel:product.viewModel];
        return cell;
    
    } else {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectPromoProduct:)]) {
        PromoProduct *product = [_promo objectAtIndex:indexPath.row];
        [self.delegate didSelectPromoProduct:product];
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
    PromoInfoAlertView *alert = [PromoInfoAlertView newview];
    alert.delegate = self;
    [alert show];
}

- (void)scrollToCenter {
    if ([_scrollPosition integerValue] == 0 && _promo.count > 2) {
        NSInteger x = _flowLayout.itemSize.width / 2;
        x += 5; // add cell spacing
        [_collectionView setContentOffset:CGPointMake(x, 0) animated:YES];
    }
}

- (void)setScrollPosition:(NSNumber *)scrollPosition {
    _scrollPosition = scrollPosition;
    if (_promo.count > 2) {
        NSInteger x = _flowLayout.itemSize.width * [_scrollPosition integerValue];
        x += [_scrollPosition integerValue] * 10;
        _collectionView.contentOffset = CGPointMake(x, 0);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(promoDidScrollToPosition:atIndexPath:)]) {
        NSInteger position = scrollView.contentOffset.x / self.flowLayout.itemSize.width;
        [self.delegate promoDidScrollToPosition:[NSNumber numberWithInteger:position] atIndexPath:_indexPath];
    }
}

- (void)alertView:(TKPDAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.tokopedia.com/iklan"]];
    }
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
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        if (type == PromoCollectionViewCellTypeNormal) {
            height = PromoNormalCellHeight;
        } else if (type == PromoCollectionViewCellTypeThumbnail) {
            height = PromoThumbnailCellHeight;
        }
    } else if (IS_IPHONE_6) {
        if (type == PromoCollectionViewCellTypeNormal) {
            height = PromoNormalCellHeightSix;
        } else if (type == PromoCollectionViewCellTypeThumbnail) {
            height = PromoThumbnailCellHeightSix;
        }
    } else if (IS_IPHONE_6P) {
        if (type == PromoCollectionViewCellTypeNormal) {
            height = PromoNormalCellHeightSixPlus;
        } else if (type == PromoCollectionViewCellTypeThumbnail) {
            height = PromoThumbnailCellHeightSixPlus;
        }
    }
    return height;
}

+ (CGFloat)collectionViewNormalHeight {
    return [self collectionViewHeightForType:PromoCollectionViewCellTypeNormal];
}

- (CGSize)itemSize {
    CGSize cellSize = CGSizeMake(0, 0);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSInteger cellCount = 0;
    float heightRatio = 0, widhtRatio = 0, inset = 0;
    CGFloat screenWidth = screenRect.size.width;
    if (_collectionViewCellType == PromoCollectionViewCellTypeNormal) {
        cellCount = 2;
        heightRatio = 41;
        widhtRatio = 29;
        inset = 15;
    } else if (_collectionViewCellType == PromoCollectionViewCellTypeThumbnail) {
        cellCount = 3;
        heightRatio = 1;
        widhtRatio = 1;
        inset = 14;
    }
    CGFloat cellWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        screenWidth = screenRect.size.width/2;
        cellWidth = screenWidth/cellCount-inset;
    } else {
        screenWidth = screenRect.size.width;
        cellWidth = screenWidth/cellCount-inset;
    }
    cellSize = CGSizeMake(cellWidth, cellWidth*heightRatio/widhtRatio);
    return cellSize;
}

@end
