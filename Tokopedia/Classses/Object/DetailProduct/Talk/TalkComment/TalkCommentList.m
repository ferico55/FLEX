//
//  TalkList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TalkCommentList.h"

@implementation TalkCommentList

- (NSString*)comment_message {
    return [_comment_message kv_decodeHTMLCharacterEntities];
}

@end
