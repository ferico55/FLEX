//
//  InboxTicketPaging.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxTicketPaging : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *uri_next;
@property (strong, nonatomic) NSString *uri_previous;

@end
