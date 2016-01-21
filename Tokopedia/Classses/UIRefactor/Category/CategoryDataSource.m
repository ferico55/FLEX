//
//  CategoryDataSource.m
//  Tokopedia
//
//  Created by Tonito Acen on 1/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CategoryDataSource.h"
#import "CategoryViewCell.h"

#define categoryNames @[@"Pakaian",@"Handphone & Tablet", @"Office & Stationery", @"Fashion & Aksesoris", @"Laptop & Aksesoris", @"Souvenir, Kado & Hadiah", @"Kecantikan", @"Komputer & Aksesoris", @"Mainan & Hobi", @"Kesehatan", @"Elektronik", @"Makanan & Minuman", @"Rumah Tangga", @"Kamera, Foto & Video", @"Buku", @"Dapur", @"Otomotif", @"Software", @"Perawatan Bayi", @"Olahraga", @"Film, Musik & Game", @"Produk Lainnya"]

#define categoryIds @[@"78",@"65",@"642",  @"79",@"288",@"54",  @"61",@"297",@"55",  @"715",@"60",@"35",  @"984",@"578",@"8",  @"983",@"63",@"20",  @"56",@"62",@"57",  @"36"]


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



@end
