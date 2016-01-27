//
//  ProductDataSource.m
//  Tokopedia
//
//  Created by Tonito Acen on 1/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ProductDataSource.h"

@implementation ProductDataSource {
    void(^_completion)(NSInteger nextPage);
}

- (instancetype)initWithProducts:(NSArray *)products onComplete:(void (^)(NSInteger))completion {
    self = [super init];
    if(!self) {
        _products = products;
    }
    
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [self numberOfSectionsInCollectionView:collectionView] - 1;
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (indexPath.section == section && indexPath.row == row) {
        _completion(_currentPage+1);
    }
    return nil;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
}



@end
