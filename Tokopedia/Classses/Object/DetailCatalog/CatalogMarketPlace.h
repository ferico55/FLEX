//
//  CatalogMarketPlace.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogMarketPlace : NSObject<TKPObjectMapping>

@property (nonatomic, strong) NSString *min_price;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *max_price;

@end
