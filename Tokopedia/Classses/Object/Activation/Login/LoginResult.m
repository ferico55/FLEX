//
//  LoginResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "activation.h"
#import "LoginResult.h"

@implementation LoginResult

- (NSString *)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

@end
