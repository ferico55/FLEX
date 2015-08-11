//
//  ConversationModelView.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ConversationViewModel.h"

@implementation ConversationViewModel

- (NSString *)conversationMessage {
    return [_conversationMessage kv_decodeHTMLCharacterEntities];
}

@end
