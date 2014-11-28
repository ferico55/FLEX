//
//  District.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface District : NSObject

@property (nonatomic) NSInteger district_id;
@property (nonatomic, strong) NSArray *district_shipping_supported;
@property (nonatomic, strong) NSString *district_name;

@end
