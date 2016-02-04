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
#define TAG_REQUEST_CC 18
#define TAG_REQUEST_BRI_EPAY 19
#define TAG_REQUEST_TOPPAY 20

@protocol RequestCartDelegate <NSObject>
@required
-(void)requestSuccessCart:(id)successResult withOperation:(RKObjectRequestOperation*)operation;
-(void)requestSuccessActionCancelCart:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessActionCheckout:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessActionBuy:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessActionVoucher:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessActionEditProductCart:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessEMoney:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessBCAClickPay:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessCC:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessBRIEPay:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessToppay:(id)object withOperation:(RKObjectRequestOperation *)operation;

-(void)actionBeforeRequest:(int)tag;
-(void)actionAfterFailRequestMaxTries:(int)tag;

- (void)requestError:(NSArray*)errorMessages;

@end

@interface RequestCart : NSObject

@property (nonatomic, weak) IBOutlet id<RequestCartDelegate> delegate;
@property (nonatomic, strong) NSDictionary *param;

@property (nonatomic, strong) UIViewController *viewController;

-(void)doRequestCart;
-(void)doRequestCancelCart;
-(void)doRequestCheckout;
-(void)dorequestBuy;
-(void)doRequestVoucher;
-(void)doRequestEditProduct;
-(void)doRequestEMoney;
-(void)doRequestBCAClickPay;
-(void)doRequestCC;
-(void)dorequestBRIEPay;
-(void)doRequestToppay;

@end
