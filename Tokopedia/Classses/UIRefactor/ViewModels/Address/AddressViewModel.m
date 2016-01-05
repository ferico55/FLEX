//
//  AddressViewModel.m
//  Tokopedia
//
//  Created by Renny Runiawati on 12/22/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "AddressViewModel.h"

@implementation AddressViewModel

-(NSString *)addressStreet
{
    return [_addressStreet kv_decodeHTMLCharacterEntities];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
