//
//  EtalaseList.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "EtalaseList.h"

@implementation EtalaseList

- (NSString *)etalase_name {
    return [_etalase_name kv_decodeHTMLCharacterEntities];
}

@end
