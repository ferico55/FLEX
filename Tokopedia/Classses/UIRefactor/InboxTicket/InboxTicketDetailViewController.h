//
//  InboxTicketDetailViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InboxTicketList.h"

@protocol InboxTicketDetailDelegate <NSObject>

- (void)updateInboxTicket:(InboxTicketList *)inboxTicket;

@end

@interface InboxTicketDetailViewController : UIViewController

@property (strong, nonatomic) InboxTicketList *inboxTicket;
@property (weak, nonatomic) id<InboxTicketDetailDelegate> delegate;

- (void)updateTicket:(InboxTicketList *)inboxTicket;

@end
