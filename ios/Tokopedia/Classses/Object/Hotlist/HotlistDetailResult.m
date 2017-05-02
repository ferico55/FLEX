//
//  HotlistDetailResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "HotlistDetailResult.h"

@implementation HotlistDetailResult

- (NSString*)desc_key {
    return [_desc_key kv_decodeHTMLCharacterEntities];
}

@end
