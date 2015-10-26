//
//  TKPString.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/21/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPString.h"

@implementation TKPString

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self kv_decodeHTMLCharacterEntities];
    }
    return self;
}

@end
