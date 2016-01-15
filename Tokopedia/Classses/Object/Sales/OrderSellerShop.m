//
//  OrderShop.m
//  Tokopedia
//
//  Created by Tokopedia on 1/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "OrderSellerShop.h"

@implementation OrderSellerShop

- (NSString *)address_street {
    NSString *address_street = _address_street;
    address_street = [address_street stringByReplacingOccurrencesOfString:@"[nl]" withString:@"\n"];
    address_street = [address_street stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    return address_street;
}

@end
