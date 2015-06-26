//
//  InboxTicketReplyViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/11/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InboxTicketList.h"
#import "InboxTicketDetail.h"

@protocol InboxTicketReplyDelegate <NSObject>

- (void)successReplyInboxTicket:(InboxTicketDetail *)reply;
- (void)successCloseInboxTicket:(InboxTicketDetail *)reply;
- (void)successCloseInboxTicket:(InboxTicketDetail *)reply withRating:(NSString *)rating;

@end

@interface InboxTicketReplyViewController : UIViewController

@property (strong, nonatomic) InboxTicketList *inboxTicket;
@property (weak, nonatomic) id<InboxTicketReplyDelegate> delegate;
@property BOOL isCloseTicketForm;
@property (strong, nonatomic) NSString *rating;

@end
