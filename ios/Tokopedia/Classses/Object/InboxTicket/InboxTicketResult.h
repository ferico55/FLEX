//
//  InboxTicketResult.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paging.h"
#import "InboxTicketList.h"

@interface InboxTicketResult : NSObject <TKPObjectMapping>

@property (strong, nonatomic) Paging *paging;
@property (strong, nonatomic) NSArray<InboxTicketList*> *list;

@end
