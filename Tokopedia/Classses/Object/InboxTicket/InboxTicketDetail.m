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
        viewModel.userName = _ticket_detail_user_name;
        viewModel.userProfilePicture = _ticket_detail_user_image;
        viewModel.conversationMessage = _ticket_detail_message;
        if (_ticket_detail_is_cs) {
            viewModel.conversationOwner = @"Administrator";
        } else {
            viewModel.conversationOwner = @"Pengguna";
        }
    }
    return _viewModel;
}

@end
