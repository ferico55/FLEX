//
//  CatalogMarketPlace.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogMarketPlace : NSObject<TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *min_price;
@property (nonatomic, strong, nonnull) NSString *time;
@property (nonatomic, strong, nonnull) NSString *name;
@property (nonatomic, strong, nonnull) NSString *max_price;

@end
