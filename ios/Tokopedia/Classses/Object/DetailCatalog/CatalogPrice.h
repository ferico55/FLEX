//
//  CatalogPrice.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogPrice : NSObject<TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *price_min;
@property (nonatomic, strong, nonnull) NSString *price_max;

@end
