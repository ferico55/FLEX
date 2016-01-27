//
//  ProductDataSource.h
//  Tokopedia
//
//  Created by Tonito Acen on 1/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductDataSource : NSObject <UICollectionViewDataSource>

- (instancetype)initWithProducts:(NSArray*)products onComplete:(void(^)(NSInteger nextPage))completion;

@property (strong, nonatomic) NSArray *products;
@property (nonatomic) NSInteger currentPage;


@end
