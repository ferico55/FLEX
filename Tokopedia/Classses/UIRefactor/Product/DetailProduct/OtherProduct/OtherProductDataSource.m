//
//  OtherProductDataSource.m
//  Tokopedia
//
//  Created by Tokopedia on 3/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "OtherProductDataSource.h"
#import "SearchAWSProduct.h"
#import "ProductCell.h"
#import "Tokopedia-Swift.h"

typedef NS_ENUM(NSInteger, UITableViewCellType) {
    UITableViewCellTypeOneColumn,
    UITableViewCellTypeTwoColumn,
    UITableViewCellTypeThreeColumn,
};

@implementation OtherProductDataSource

@synthesize collectionViewItemSize = _collectionViewItemSize;

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (self.products) {
        return self.products.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCellIdentifier" forIndexPath:indexPath];
    SearchAWSProduct *product = [self.products objectAtIndex:indexPath.row];
    
    [cell setViewModel:product.viewModel];
    cell.productShop.hidden = YES;
    cell.locationImage.hidden = YES;
    cell.shopLocation.hidden = YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchAWSProduct *product = [self.products objectAtIndex:indexPath.row];
    [self.delegate didSelectOtherProduct:product];
}

#pragma mark - Collection view item size

- (void)setCollectionViewItemSize:(CGSize)collectionViewItemSize {
    _collectionViewItemSize = collectionViewItemSize;
}

- (CGSize)collectionViewItemSize {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGFloat numberOfCell = 4;
        CGFloat cellHeight = 250;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat cellWidth = screenWidth/numberOfCell - 12;
        return CGSizeMake(cellWidth, cellHeight);
    } else {
        CGSize normalSize = [ProductCellSize sizeWithType:UITableViewCellTypeTwoColumn];
        return CGSizeMake(normalSize.width, normalSize.height - 20);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self collectionViewItemSize];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint point = *targetContentOffset;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGSize itemSize = [self collectionViewItemSize];
    CGFloat visibleWidth = layout.minimumInteritemSpacing + itemSize.width;
    int indexOfItemToSnap = round(point.x / visibleWidth);
    if (indexOfItemToSnap + 1 == [self.collectionView numberOfItemsInSection:0]) {
        *targetContentOffset = CGPointMake(self.collectionView.contentSize.width - self.collectionView.bounds.size.width, 0);
    } else {
        NSInteger indent = indexOfItemToSnap * layout.sectionInset.left;
        *targetContentOffset = CGPointMake((indexOfItemToSnap * visibleWidth)+indent, 0);
    }
    [self updatePageControlCurrentPage:indexOfItemToSnap];
}

- (void)updatePageControlCurrentPage:(NSInteger)currentPage {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (currentPage == (self.products.count - 2)) {
            self.pageControl.currentPage = self.products.count;
        } else {
            self.pageControl.currentPage = currentPage;
        }
    } else {
        if (currentPage == (self.products.count - 1)) {
            self.pageControl.currentPage = self.products.count;
        } else {
            self.pageControl.currentPage = currentPage;
        }
    }
}


@end
