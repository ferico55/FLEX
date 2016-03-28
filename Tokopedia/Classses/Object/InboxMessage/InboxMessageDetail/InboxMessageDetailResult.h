//
//  InboxMessageDetailResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Paging.h"
#import "InboxMessageDetailList.h"
#import "InboxMessageDetailBetween.h"

@interface InboxMessageDetailResult : NSObject

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *conversation_between;

+ (RKObjectMapping*)mapping;

@end
