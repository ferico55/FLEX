//
//  InboxMessage.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InboxMessageDetailBetween : NSObject

@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *user_id;

+ (RKObjectMapping*)mapping;

@end
