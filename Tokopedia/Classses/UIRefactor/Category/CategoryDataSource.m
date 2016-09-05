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

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _categoryIds.count;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
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
    vc.tkpdTabNavigationController = viewController;
    NSDictionary *data = @{searchTypeKey : @(1),categoryIdKey : categoryId};
    [viewController setData:data];
    [viewController setNavigationTitle:categoryName];
    [viewController setSelectedIndex:0];
    [viewController setViewControllers:viewcontrollers];
    viewController.hidesBottomBarWhenPushed = YES;
    [viewController setNavigationTitle:categoryName?:@""];
    
    [_delegate.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if(IS_IPAD) {
        return CGSizeMake((screenWidth/5)-10, 135);
    } else {
        CGFloat cellWidth = screenWidth/3 - 8;
        
        return CGSizeMake(cellWidth, 130);
        
    }
    return CGSizeZero;
    
}


@end
