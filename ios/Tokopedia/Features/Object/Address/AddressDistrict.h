//
//  AddressDistrict.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressDistrict : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *district_id;
@property (nonatomic, strong, nonnull) NSString *district_name;

@end
