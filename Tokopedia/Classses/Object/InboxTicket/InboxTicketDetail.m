//
//  InboxTicketDetail.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketDetail.h"

@implementation InboxTicketDetail

- (ConversationViewModel *)viewModel {
    if (_viewModel == nil) {
        ConversationViewModel *viewModel = [ConversationViewModel new];
    }
    return _viewModel;
}

@end
