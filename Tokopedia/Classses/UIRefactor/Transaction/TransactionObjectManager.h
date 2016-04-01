//
//  TransactionObjectManager.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionCart.h"
#import "TxEmoney.h"

@interface TransactionObjectManager : NSObject

@property NSInteger gatewayID;

-(RKObjectManager *)objectManagerCart;
-(RKObjectManager *)objectManagerCancelCart;
-(RKObjectManager *)objectManagerCheckout;
-(RKObjectManager *)objectManagerBuy;
-(RKObjectManager *)objectManagerVoucher;
-(RKObjectManager *)objectMangerEditProduct;
-(RKObjectManager *)objectManagerEMoney;
-(RKObjectManager *)objectManagerBCAClickPay;
-(RKObjectManager *)objectManagerCC;
-(RKObjectManager *)objectManagerBRIEPay;
-(RKObjectManager *)objectManagerToppay;
-(RKObjectManager*)objectManagerToppayThx;

@end
