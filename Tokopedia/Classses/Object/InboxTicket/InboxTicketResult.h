//
//  InboxTicketResult.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxTicketPaging.h"

@interface InboxTicketResult : NSObject

@property (strong, nonatomic) InboxTicketPaging *paging;
@property (strong, nonatomic) NSArray *list;

@end
