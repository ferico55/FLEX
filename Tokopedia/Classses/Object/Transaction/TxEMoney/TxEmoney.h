//
//  TxEmoney.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/20/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TxEMoneyResult.h"

@interface TxEmoney : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) TxEMoneyResult *result;

@end
