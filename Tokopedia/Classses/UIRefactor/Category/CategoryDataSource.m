//
//  CategoryDataSource.m
//  Tokopedia
//
//  Created by Tonito Acen on 1/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CategoryDataSource.h"
#import "CategoryViewCell.h"
#import "Localytics.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"
#import "TKPDTabNavigationController.h"
#import "Tokopedia-Swift.h"

#define categoryNames @[@"Pakaian",@"Handphone & Tablet", @"Office & Stationery", @"Fashion & Aksesoris", @"Laptop & Aksesoris", @"Souvenir, Kado & Hadiah", @"Kecantikan", @"Komputer & Aksesoris", @"Mainan & Hobi", @"Kesehatan", @"Elektronik", @"Makanan & Minuman", @"Rumah Tangga", @"Kamera, Foto & Video", @"Buku", @"Dapur", @"Otomotif", @"Software", @"Perawatan Bayi", @"Olahraga", @"Film, Musik & Game", @"Produk Lainnya"]

#define categoryIds @[@"78",@"65",@"642",  @"79",@"288",@"54",  @"61",@"297",@"55",  @"715",@"60",@"35",  @"984",@"578",@"8",  @"983",@"63",@"20",  @"56",@"62",@"57",  @"36"]
#define categoryIdKey @"department_id"
#define categoryNameKey @"department_name"
#define searchTypeKey @"type"


@implementation CategoryDataSource {
    NSArray <NSString*>*_categoryNames;
    NSArray *_categoryIds;
}


- (instancetype)init {
    self = [super init];
    
    if(!self) {
        return nil;
    }
    
    _categoryNames = categoryNames;
    _categoryIds = categoryIds;
    
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tickerCell" forIndexPath:indexPath];
        if (![_ticker isDescendantOfView:cell.contentView]) {
            CGRect bounds = cell.contentView.bounds;
            _ticker.frame = bounds;
            [_ticker updateConstraintsIfNeeded];
            [cell.contentView addSubview:_ticker];
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bannerCell" forIndexPath:indexPath];
        if (![_slider isDescendantOfView:cell.contentView]) {
            [cell.contentView addSubview:_slider];
        }
        
        return cell;
    } else if (indexPath.section == 2) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"miniSlideCell" forIndexPath:indexPath];
        if (![_pulsaContainer isDescendantOfView:cell.contentView]) {
            [_pulsaContainer attachToView:cell.contentView];
            
            [cell.contentView addSubview:_pulsaContainer];
        }
        
        
        return cell;
    } else if (indexPath.section == 3) {
        NSString *cellid = @"CategoryViewCellIdentifier";
        CategoryViewCell *cell = (CategoryViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        NSInteger index = indexPath.row;
        
        NSString *title =_categoryNames[index];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrahStyle setLineSpacing:6];
        [paragrahStyle setAlignment:NSTextAlignmentCenter];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [title length])];
        
        cell.categoryLabel.attributedText = attributedString;
        
        NSString *imageName = [NSString stringWithFormat:@"icon_%zd",index];
        cell.icon.image = [UIImage imageNamed:imageName];
        
        cell.backgroundColor = [UIColor whiteColor];
        
        return cell;
        
    }
    
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 3) {
        return _categoryIds.count;
    } else {
        return 1;
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        NSInteger index =  indexPath.row;
        NSString *categoryName = _categoryNames[index];
        NSString *categoryId = _categoryIds[index];
        
        [Localytics tagEvent:@"Event : Clicked Category" attributes:@{@"Category Name" : categoryName}];
        
        SearchResultViewController *vc = [SearchResultViewController new];
        vc.hidesBottomBarWhenPushed = YES;
        vc.isFromDirectory = YES;
        vc.data =@{@"sc" : categoryId,categoryNameKey : categoryName, searchTypeKey:@"search_product"};
        
        SearchResultViewController *vc1 = [SearchResultViewController new];
        vc1.hidesBottomBarWhenPushed = YES;
        vc.isFromDirectory = YES;
        vc1.data =@{@"sc" : categoryId,categoryNameKey : categoryName, searchTypeKey:@"search_catalog"};
        
        SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
        vc2.hidesBottomBarWhenPushed = YES;
        vc2.data =@{@"sc" : categoryId,categoryNameKey : categoryName, searchTypeKey:@"search_shop"};
        
        NSArray *viewcontrollers = @[vc,vc1,vc2];
        
        TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
        NSDictionary *data = @{searchTypeKey : @(1),categoryIdKey : categoryId};
        [viewController setData:data];
        [viewController setNavigationTitle:categoryName];
        [viewController setSelectedIndex:0];
        [viewController setViewControllers:viewcontrollers];
        viewController.hidesBottomBarWhenPushed = YES;
        [viewController setNavigationTitle:categoryName?:@""];
        
        PulsaViewController *controller = [[PulsaViewController alloc] init];
        
        [_delegate.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    // When there's no ticker/banner/slider, set the height of cell to be as smallest as possible.
    // The method doesn't accept zero as size, already tried it
    if (indexPath.section == 0) {
        if (_ticker) {
            return CGSizeMake(screenWidth, _ticker.messageLabel.bounds.size.height + _ticker.titleLabel.bounds.size.height + 40); // 40 is the constraints height total
        } else {
            return CGSizeMake(screenWidth, 1);
        }
    } else if (indexPath.section == 1) {
        if (_slider) {
            return CGSizeMake(screenWidth, IS_IPAD ? 225 : 175);
        } else {
            return CGSizeMake(screenWidth, 1);
        }
    } else if (indexPath.section == 2) {
        if (_pulsaContainer) {
            return CGSizeMake(screenWidth, 120);
        } else {
            return CGSizeMake(screenWidth, 1);
        }
    } else if (indexPath.section == 3) {
        if(IS_IPAD) {
            return CGSizeMake((screenWidth/5)-10, 135);
        } else {
            CGFloat cellWidth = screenWidth/3 - 8;
            
            return CGSizeMake(cellWidth, 130);
        }
    }
    
    return CGSizeZero;
    
}


@end
