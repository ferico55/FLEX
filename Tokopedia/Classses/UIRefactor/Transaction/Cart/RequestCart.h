//
//  RequestCart.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TAG_REQUEST_CART 10
#define TAG_REQUEST_CANCEL_CART 11
#define TAG_REQUEST_CHECKOUT 12
#define TAG_REQUEST_BUY 13
#define TAG_REQUEST_VOUCHER 14
#define TAG_REQUEST_EDIT_PRODUCT 15
#define TAG_REQUEST_EMONEY 16
#define TAG_REQUEST_BCA_CLICK_PAY 17

@protocol RequestCartDelegate <NSObject>
@required
- (void)successRequestList:(NSArray*)list;
- (void)requestError:(NSArray*)errorMessages;

@end


@interface RequestCart : NSObject

@end
