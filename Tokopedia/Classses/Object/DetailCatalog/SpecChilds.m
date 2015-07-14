//
//  SpecChilds.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SpecChilds.h"

@implementation SpecChilds

- (NSString *)spec_key {
    return [_spec_key kv_decodeHTMLCharacterEntities];
}

- (NSArray *)spec_val {
    NSMutableArray *spec_val = [NSMutableArray new];
    for (NSString *val in _spec_val) {
        [spec_val addObject:[val kv_decodeHTMLCharacterEntities]];
    }
    return spec_val;
}

@end
