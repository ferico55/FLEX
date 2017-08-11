//
//  TransactionSummaryBCAParam.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionSummaryBCAParam : NSObject <TKPObjectMapping>

@property (nonatomic,strong) NSString *bca_descp;
@property (nonatomic,strong) NSString *bca_code;
@property (nonatomic,strong) NSString *bca_amt;
@property (nonatomic,strong) NSString *bca_url;
@property (nonatomic,strong) NSString *currency;
@property (nonatomic,strong) NSString *miscFee;
@property (nonatomic,strong) NSString *bca_date;
@property (nonatomic,strong) NSString *signature;
@property (nonatomic,strong) NSString *callback;
@property (nonatomic,strong) NSString *payment_id;
@property (nonatomic,strong) NSString *payType;

@end
