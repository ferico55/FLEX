//
//  NewOrderHistory.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderHistory.h"

@implementation OrderHistory

- (NSString *)history_comments {
    return [_history_comments stringByReplacingOccurrencesOfString:@"            " withString:@""];
}

@end
