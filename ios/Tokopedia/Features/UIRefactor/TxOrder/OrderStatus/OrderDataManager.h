//
//  OrderDataManager.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OrderCellContext;
@class TxOrderStatusList;

@interface OrderDataManager : NSObject

-(instancetype)initWithCollectionView:(UICollectionView*)collectionView supplementaryViewDataSource:(id)viewDataSource;
-(void)addOrders:(NSArray<TxOrderStatusList*>*)orders;
-(void)removeAllOrders;
-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
-(void)announceWillAppearForItemInCell:(UICollectionViewCell *)cell;
-(void)announceDidDisappearForItemInCell:(UICollectionViewCell *)cell;

-(OrderCellContext*)context;
-(NSArray<TxOrderStatusList *>*)orders;

@end
