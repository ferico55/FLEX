//
//  InboxTicketDetail.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketDetail.h"

@implementation InboxTicketDetail

- (NSString *)ticket_detail_message {
    return [_ticket_detail_message kv_decodeHTMLCharacterEntities];
}

- (ConversationViewModel *)viewModel {
    if (_viewModel == nil) {
        ConversationViewModel *viewModel = [ConversationViewModel new];
        viewModel.userName = _ticket_detail_user_name;
        viewModel.userProfilePicture = _ticket_detail_user_image;
        viewModel.conversationMessage = _ticket_detail_message;
        viewModel.conversationDate = _ticket_detail_create_time_fmt;
        viewModel.conversationPhotos = _ticket_detail_attachment;
        viewModel.conversationDate = _ticket_detail_create_time;
        if ([_ticket_detail_is_cs boolValue]) {
            viewModel.conversationOwner = @"Administrator";
        } else {
            viewModel.conversationOwner = @"Pengguna";
        }
        _viewModel = viewModel;
    }
    return _viewModel;
}

@end
