//
//  TalkList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TalkList.h"

@implementation TalkList

- (NSString*)talk_message {
    return [_talk_message kv_decodeHTMLCharacterEntities];
}

- (NSString*)talk_product_name {
    return [_talk_product_name kv_decodeHTMLCharacterEntities];
}

@end
