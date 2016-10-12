//
//  TransactionVoucherData.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionVoucherData : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *voucher_amount;
@property (nonatomic, strong) NSString *voucher_id;
@property (nonatomic, strong) NSString *voucher_status;
@property (nonatomic, strong) NSString *voucher_expired_time;
@property (nonatomic, strong) NSString *voucher_minimal_amount;
@property (nonatomic, strong) NSString *voucher_no_other_promotion;
@property (nonatomic, strong) NSString *voucher_promo_desc;

@end
