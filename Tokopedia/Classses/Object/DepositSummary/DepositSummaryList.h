//
//  DepositSummaryList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepositSummaryList : NSObject

@property (nonatomic, strong) NSString *deposit_id;
@property (nonatomic, strong) NSString *deposit_saldo_idr;
@property (nonatomic, strong) NSString *deposit_date_full;
@property (nonatomic, strong) NSString *deposit_amount;
@property (nonatomic, strong) NSString *deposit_amount_idr;
@property (nonatomic, strong) NSString *deposit_type;
@property (nonatomic, strong) NSString *deposit_date;
@property (nonatomic, strong) NSString *deposit_withdraw_date;
@property (nonatomic, strong) NSString *deposit_withdraw_status;
@property (nonatomic, strong) NSString *deposit_notes;

+ (RKObjectMapping*)mapping;

@end
