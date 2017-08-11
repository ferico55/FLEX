//
//  TransactionCartResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionCartList.h"
#import "TransactionCartGateway.h"

@class Donation;
@class PromoSuggestion;

@interface TransactionCartResult : NSObject <TKPObjectMapping>

@property (nonatomic,strong) NSArray<TransactionCartList*> *list;
@property (nonatomic,strong) NSArray *gateway_list;

@property (nonatomic,strong) NSString *gateway;
@property (nonatomic,strong) NSString *grand_total;
@property (nonatomic,strong) NSString *grand_total_idr;
@property (nonatomic,strong) NSString *voucher_code;
@property (nonatomic,strong) NSString *deposit_idr;
@property (nonatomic,strong) NSString *not_empty;
@property (nonatomic,strong) NSString *ecash_flag;
@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) NSString *lp_amount_idr;
@property (nonatomic,strong) NSString *lp_amount;
@property (nonatomic,strong) NSString *cashback_idr;
@property (nonatomic,strong) NSString *cashback;
@property (nonatomic,strong) NSString *grand_total_without_lp_idr;
@property (nonatomic,strong) NSString *grand_total_without_lp;
@property (nonatomic, strong) Donation *donation;
@property (nonatomic, strong) PromoSuggestion *promoSuggestion;
@property (nonatomic,strong) NSString *keroToken;
@property (nonatomic,strong) NSString *ut;

@end
