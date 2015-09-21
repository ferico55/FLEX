//
//  ResolutionConversation.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionConversation.h"

@implementation ResolutionConversation

- (NSString *)remark_str {
    return [_remark_str kv_decodeHTMLCharacterEntities];
}

@end
