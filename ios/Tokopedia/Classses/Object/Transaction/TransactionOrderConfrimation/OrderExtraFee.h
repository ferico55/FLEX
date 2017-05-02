//
//  OrderExtraFee.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderExtraFee : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *extra_fee_amount;
@property (nonatomic, strong) NSString *extra_fee_amount_idr;
@property (nonatomic, strong) NSString *extra_fee_type;

@end
