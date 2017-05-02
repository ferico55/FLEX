//
//  ShopShipping.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopShipping.h"

@implementation ShopShipping

- (NSString *)addr_street {
    NSString *addr_street = _addr_street;
    addr_street = [addr_street stringByReplacingOccurrencesOfString:@"[nl]" withString:@"\n"];
    addr_street = [addr_street stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    return addr_street;
}

@end
