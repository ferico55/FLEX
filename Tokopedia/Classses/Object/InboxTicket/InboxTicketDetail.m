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
    if ([_ticket_detail_message isEqualToString:@"0"]) {
        return @"";
    }
    return [_ticket_detail_message kv_decodeHTMLCharacterEntities];
}

- (ConversationViewModel *)viewModel {
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
    if ([_ticket_detail_new_rating isEqualToString:@"1"]) {
        viewModel.conversationNote = @"Memberikan Penilaian : Membantu";
    } else if ([_ticket_detail_new_rating isEqualToString:@"2"]) {
        viewModel.conversationNote = @"Memberikan Penilaian : Tidak Membantu";
    }

    return viewModel;
}

@end
