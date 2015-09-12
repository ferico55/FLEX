//
//  ContactUsActionResult.h
//  Tokopedia
//
//  Created by Tokopedia on 8/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsActionResultError.h"

@interface ContactUsActionResult : NSObject

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) ContactUsActionResultError *error_message_inline;
@property (nonatomic, strong) NSString *is_success;
@property (nonatomic, strong) NSString *ticket_inbox_id;
@property (nonatomic, strong) NSString *post_key;

@end
