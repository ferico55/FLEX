//
//  OrderDataManager.mm
//  Tokopedia
//
//  Created by Renny Runiawati on 11/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "TxOrderStatusList.h"
#import "ListOrderComponent.h"
#import "OrderCellContext.h"
#import "AFNetworkingImageDownloader.h"
#import "OrderDataManager.h"


@implementation OrderDataManager{
    CKCollectionViewDataSource* _dataSource;
    CKComponentFlexibleSizeRangeProvider *_sizeRangeProvider;

    NSMutableArray<TxOrderStatusList*>* _orders;
    OrderCellContext *_context;
}

-(instancetype)initWithCollectionView:(UICollectionView*)collectionView supplementaryViewDataSource:(id<CKSupplementaryViewDataSource>)viewDataSource{
    if (self = [super init]) {
        
        _orders = [NSMutableArray new];
        
        _sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
        
        _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:collectionView
                                                     supplementaryViewDataSource:viewDataSource
                                                               componentProvider:[self class]
                                                                         context:[self context]
                                                       cellConfigurationFunction:nil];
        
        CKArrayControllerSections sections;
        sections.insert(0);
        [_dataSource enqueueChangeset:sections constrainedSize:{}];
    }
    return self;
}

-(OrderCellContext*)context{
    if (!_context) {
        _context = [OrderCellContext new];
        _context.imageDownloader = [AFNetworkingImageDownloader new];
    }
    return _context;
}

-(NSArray<TxOrderStatusList *>*)orders{
    return [_orders copy];
}

-(void)removeOrders:(NSArray<TxOrderStatusList*>*)orders{
    
    CKArrayControllerInputItems items;
    [_orders removeObjectsInArray:orders];
    
    for (NSInteger index = 0; index < orders.count; index++) {
        items.remove({0, index});
    }
    
    [_dataSource enqueueChangeset:items
                  constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:_dataSource.collectionView.bounds.size]];
}

-(void)addOrders:(NSArray<TxOrderStatusList*>*)orders{
    
    CKArrayControllerInputItems items;
    
    for(int index = _orders.count, counter = 0; counter < orders.count; index++, counter++) {
        items.insert({0, index}, orders[counter]);
    }
    
    [_dataSource enqueueChangeset:items
                  constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:_dataSource.collectionView.bounds.size]];
    [_orders addObjectsFromArray:orders];
}

- (void)removeAllOrders {
    CKArrayControllerInputItems items;
    for (NSInteger index = 0; index < _orders.count; index++) {
        items.remove({0, index});
    }
    
    [_orders removeAllObjects];
    
    [_dataSource enqueueChangeset:items
                  constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:_dataSource.collectionView.bounds.size]];
}

+(CKComponent *)componentForModel:(TxOrderStatusList*)order context:(OrderCellContext*)context {
    return [ListOrderComponent newWithOrder:order context:context];
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource sizeForItemAtIndexPath:indexPath];
}

- (void)announceWillAppearForItemInCell:(UICollectionViewCell *)cell {
    [_dataSource announceWillAppearForItemInCell:cell];
}

- (void)announceDidDisappearForItemInCell:(UICollectionViewCell *)cell {
    [_dataSource announceDidDisappearForItemInCell:cell];
}
@end
