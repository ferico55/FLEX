//
//  InboxTicketViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTabViewController.h"
#import "InboxTicketDetailViewController.h"

typedef NS_ENUM(NSInteger, InboxCustomerServiceType) {
    InboxCustomerServiceTypeAll,
    InboxCustomerServiceTypeInProcess,
    InboxCustomerServiceTypeClosed
};

@interface InboxTicketViewController : UITableViewController

@property InboxCustomerServiceType inboxCustomerServiceType;
@property (weak, nonatomic) id<TKPDTabViewDelegate> delegate;
@property (strong, nonatomic) InboxTicketDetailViewController* detailViewController;

@property (nonatomic, copy) void(^onTapContactUsButton)();

@end
