//
//  InboxReviewActionResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxReviewActionResult : NSObject

@property (strong, nonatomic) NSString *is_success;
@property (strong, nonatomic) NSString *show_dialog_rate;
@property (strong, nonatomic) NSString *review_id;

@end
