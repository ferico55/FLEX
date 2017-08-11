//
//  HotlistDataSource.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HotlistDataSource.h"
#import "HotlistCollectionCell.h"
#import "HotlistViewModel.h"
#import "HotlistList.h"

NSString *const HotlistCellIdentifier = @"HotlistCollectionCellIdentifier";

@implementation HotlistDataSource {
    BOOL _active;
    NSArray *_allIndexPaths;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)layout {
    self = [super init];
    if (self != nil) {
        NSMutableArray *allIndexPaths = [_products mutableCopy];
        for (NSInteger item = 0; item < _products.count; ++item) {
            [allIndexPaths addObject:[NSIndexPath indexPathForItem:item inSection:0]];
        }
        _allIndexPaths = allIndexPaths;
        
        _collectionView = collectionView;
        _layout = layout;
        UINib *cellNib = [UINib nibWithNibName:@"HotlistCollectionCell" bundle:nil];
        [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"HotlistCollectionCellIdentifier"];
        //[collectionView registerClass:[HotlistCollectionCell class] forCellWithReuseIdentifier:HotlistCellIdentifier];
    }
    
    return self;
}

- (void)tapHotlist:(UITapGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(hotlistDataSourceDidSelectHotlist:)]) {
        [self.delegate hotlistDataSourceDidSelectHotlist:self];
    }
}

- (void)activate:(void (^)(BOOL))completion {
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [_collectionView performBatchUpdates:^{
        _active = YES;
        //[_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[_products count]-1 inSection:0]]];

        [_collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:completion];
}

- (void)deactivate:(void (^)(BOOL))completion {
    [_collectionView performBatchUpdates:^{
        _active = NO;
        //        [_collectionView deleteItemsAtIndexPaths:_allIndexPaths];
        [_collectionView deleteSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:completion];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _active ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _active ? 1 : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HotlistCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HotlistCellIdentifier forIndexPath:indexPath];
    
    [cell setViewModel:((HotlistList*)_products[indexPath.row]).viewModel];
    
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    UICollectionReusableView *view = nil;
//    
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        HomeHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HomeCollectionViewHeaderIdentifier forIndexPath:indexPath];
//        [header.tapGestureRecognizer addTarget:self action:@selector(tapHotlist:)];
//        view = header;
//    } else {
//        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HomeCollectionViewFooterIdentifier forIndexPath:indexPath];
//    }
//    
//    return view;
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(152.0f, 215.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 170.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    return inset;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(hotlistDataSource:didSelectHotlist:)]) {
        [self.delegate hotlistDataSource: self didSelectHotlist:nil];
    }
}

-(void)setProducts:(NSArray *)products
{
    _products = products;
}

@end
