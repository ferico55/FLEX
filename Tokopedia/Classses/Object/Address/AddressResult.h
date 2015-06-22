//
//  AddressResult.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AddressCity.h"
#import "AddressDistrict.h"

@interface AddressResult : NSObject

@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, strong) NSArray *districts;

@end
