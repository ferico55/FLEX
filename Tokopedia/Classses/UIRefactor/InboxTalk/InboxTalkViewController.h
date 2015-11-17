//
//  InboxTalkViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TKPDTabViewController.h"

typedef NS_ENUM(NSInteger, InboxTalkType) {
    InboxTalkTypeAll,
    InboxTalkTypeMyProduct,
    InboxTalkTypeFollowing
};

@class ProductTalkDetailViewController;

@interface InboxTalkViewController : GAITrackedViewController

@property (strong,nonatomic) NSDictionary *data;
@property (weak, nonatomic) id<TKPDTabViewDelegate> delegate;
@property (strong, nonatomic) ProductTalkDetailViewController *detailViewController;
@property InboxTalkType inboxTalkType;


@end
