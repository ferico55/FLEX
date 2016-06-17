//
//  AddressProvince.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressProvince : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *province_id;
@property (nonatomic, strong) NSString *province_name;

@end
