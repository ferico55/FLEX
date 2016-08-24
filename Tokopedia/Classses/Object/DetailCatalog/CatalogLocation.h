//
//  CatalogLocation.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogLocation : NSObject<TKPObjectMapping>

@property (nonatomic, strong) NSString *location_name;
@property (nonatomic, strong) NSString *location_id;
@property (nonatomic, strong) NSString *total_shop;

@end
