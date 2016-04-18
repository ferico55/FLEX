//
//  OrderShop.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderShop : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *shop_uri;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;

@property (nonatomic, strong) NSString *shop_pic;

@end
