//
//  InboxMessageResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Paging.h"
#import "InboxMessageList.h"

@interface InboxMessageResult : NSObject

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray<InboxMessageList*> *list;

+ (RKObjectMapping*)mapping;

@end
