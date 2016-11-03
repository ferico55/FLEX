//
//  ReplyInboxTicketResult.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplyInboxTicketResult : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *is_success;
@property (strong, nonatomic) NSString *post_key;
@property (strong, nonatomic) NSString *file_uploaded;

@end
