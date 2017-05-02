//
//  ShopCloseDetail.m
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopCloseDetail.h"

@implementation ShopCloseDetail

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"note", @"reason", @"until"]];
    return mapping;
}

- (NSString *)until {
    if ([_until isEqualToString:@"0"]) {
        return @"";
    }
    return _until;
}

- (NSString *)reason {
    if ([_reason isEqualToString:@"0"]) {
        return @"";
    }
    return _reason;
}

- (NSString *)note {
    if ([_note isEqualToString:@"0"]) {
        return @"";
    }
    return _note;
}

@end
