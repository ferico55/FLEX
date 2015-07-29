//
//  ClosedInfo.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ClosedInfo.h"

@implementation ClosedInfo

- (NSString *)reason {
    return [_reason kv_decodeHTMLCharacterEntities];
}

- (NSString *)note {
    return [_note kv_decodeHTMLCharacterEntities];
}

@end
