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

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"ticket_detail_id",
                                             @"ticket_detail_create_time",
                                             @"ticket_detail_create_time_fmt",
                                             @"ticket_detail_user_name",
                                             @"ticket_detail_new_rating",
                                             @"ticket_detail_is_cs",
                                             @"ticket_detail_user_url",
                                             @"ticket_detail_user_label_id",
                                             @"ticket_detail_user_label",
                                             @"ticket_detail_user_image",
                                             @"ticket_detail_user_id",
                                             @"ticket_detail_new_status",
                                             @"ticket_detail_message",
                                             @"is_just_sent",
                                             @"ticket_detail_action"]
     ];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ticket_detail_attachment" toKeyPath:@"ticket_detail_attachment" withMapping:[InboxTicketDetailAttachment mapping]]];
    return mapping;
}

@end
