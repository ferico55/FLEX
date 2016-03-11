//
//  InboxMessageDetailViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 11/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InboxMessageViewController;

@interface InboxMessageDetailViewController : UIViewController

@property (strong, nonatomic) NSDictionary *data;
@property (copy) void(^onMessagePosted)(NSString* replyMessage);

-(void)replaceDataSelected:(NSDictionary*)data;


@end
