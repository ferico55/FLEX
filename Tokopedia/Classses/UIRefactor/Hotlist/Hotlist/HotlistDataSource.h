//
//  HotlistDataSource.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HotlistDataSource;

@protocol HotlistDataSourceDelegate <NSObject>

@optional
- (void)hotlistDataSourceDidSelectHotlist:(HotlistDataSource *)dataSource;
- (void)hotlistDataSource:(HotlistDataSource *)dataSource didSelectHotlist:(id)hotlist;

@end


@interface HotlistDataSource : NSObject<UICollectionViewDataSource, UICollectionViewDelegate>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)layout;
- (void)deactivate:(void (^)(BOOL))completion;
- (void)activate:(void (^)(BOOL))completion;

@property (weak, nonatomic, readonly) UICollectionView *collectionView;
@property (strong, nonatomic, readonly) UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) id <HotlistDataSourceDelegate> delegate;

@property (strong, nonatomic) NSArray *products;

@end