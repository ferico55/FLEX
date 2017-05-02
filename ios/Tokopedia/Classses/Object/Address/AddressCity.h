//
//  AddressCity.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressCity : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *city_id;
@property (nonatomic, strong) NSString *city_name;

@end
