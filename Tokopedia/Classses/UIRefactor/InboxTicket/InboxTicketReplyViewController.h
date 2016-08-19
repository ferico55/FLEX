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

static NSString *TKPDInboxAddNewTicket = @"TKPDInboxAddNewTicket";
static NSString *TKPDInboxTicketReceiveData = @"TKPDInboxTicketReceiveData";

@interface InboxTicketReplyViewController : UIViewController

@property (strong, nonatomic) InboxTicketList *inboxTicket;
@property BOOL isCloseTicketForm;
@property (strong, nonatomic) NSString *rating;

@end
