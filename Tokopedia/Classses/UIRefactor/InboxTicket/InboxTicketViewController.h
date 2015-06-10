//
//  InboxTicketViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, InboxCustomerServiceType) {
    InboxCustomerServiceTypeAll,
    InboxCustomerServiceTypeInProcess,
    InboxCustomerServiceTypeClosed
};

@interface InboxTicketViewController : UITableViewController

@property InboxCustomerServiceType inboxCustomerServiceType;

@end
