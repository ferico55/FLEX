//
//  TKPHomeProductsStore.h
//  Tokopedia
//
//  Created by Harshad Dange on 15/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Hotlist;
@class TKPStoreManager;

@interface TKPHomeProductsStore : NSObject

- (instancetype)initWithStoreManager:(TKPStoreManager *)storeManager;

- (void)archiveHotListProducts:(NSArray *)hotlistProducts nextPage:(NSInteger)page completion:(void (^)(BOOL))completion;
- (void)loadCachedHotListProducts:(void (^) (NSArray *products, NSInteger lastPage))completion;

@property (weak, nonatomic) TKPStoreManager *storeManager;

@end
