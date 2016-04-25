//
//  TxOrderConfirmedDetailPayment.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TxOrderConfirmedDetailPayment : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *payment_id;
@property (nonatomic, strong) NSString *payment_ref;
@property (nonatomic, strong) NSString *payment_date;

@end
