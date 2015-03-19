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

@end
