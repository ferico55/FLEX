//
//  TxOrderConfirmedDetailInvoice.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TxOrderConfirmedDetailInvoice : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *invoice;
@property (nonatomic, strong) NSString *url;

@end
