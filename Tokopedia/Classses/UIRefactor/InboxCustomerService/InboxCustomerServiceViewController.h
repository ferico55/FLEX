//
//  InboxCustomerServiceViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, InboxCustomerServiceType) {
    InboxCustomerServiceTypeAll,
    InboxCustomerServiceTypeInProcess,
    InboxCustomerServiceTypeClosed
};

@interface InboxCustomerServiceViewController : UITableViewController

@property InboxCustomerServiceType inboxCustomerServiceType;

@end
