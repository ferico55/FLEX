//
//  TxOrderConfirmedList.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TxOrderConfirmedList : NSObject

@property (nonatomic, strong) NSString *order_count;
@property (nonatomic, strong) NSString *user_account_name;
@property (nonatomic, strong) NSString *user_bank_name;
@property (nonatomic, strong) NSString *payment_date;
@property (nonatomic, strong) NSString *payment_ref_num;
@property (nonatomic, strong) NSString *user_account_no;
@property (nonatomic, strong) NSString *bank_name;
@property (nonatomic, strong) NSString *system_account_no;
@property (nonatomic, strong) NSString *payment_id;
@property (nonatomic) NSInteger has_user_bank;
@property (nonatomic, strong) NSString *button;
@property (nonatomic, strong) NSString *payment_amount;

@end
