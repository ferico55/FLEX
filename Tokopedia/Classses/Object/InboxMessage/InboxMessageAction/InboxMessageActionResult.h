//
//  InboxMessageActionResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InboxMessageActionResult : NSObject


@property (nonatomic, strong) NSString *is_success;

+ (RKObjectMapping *)mapping;
@end
