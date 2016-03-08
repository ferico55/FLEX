//
//  RequestCart.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TransactionCart.h"
#import "TransactionSummary.h"
#import "TransactionAction.h"
#import "TransactionVoucher.h"
#import "string_transaction.h"
#import "TransactionBuyResult.h"

#define TAG_REQUEST_CANCEL_CART 11
#define TAG_REQUEST_BUY 13
#define TAG_REQUEST_EDIT_PRODUCT 15
#define TAG_REQUEST_EMONEY 16
#define TAG_REQUEST_BCA_CLICK_PAY 17
#define TAG_REQUEST_CC 18
#define TAG_REQUEST_BRI_EPAY 19
#define TAG_REQUEST_TOPPAY 20

@protocol RequestCartDelegate <NSObject>
@required
-(void)requestSuccessEMoney:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessBCAClickPay:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessCC:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessBRIEPay:(id)object withOperation:(RKObjectRequestOperation *)operation;
-(void)requestSuccessToppayThx:(id)object withOperation:(RKObjectRequestOperation *)operation;

-(void)actionBeforeRequest:(int)tag;
-(void)actionAfterFailRequestMaxTries:(int)tag;

- (void)requestError:(NSArray*)errorMessages;

@end

@interface RequestCart : NSObject

@property (nonatomic, weak) IBOutlet id<RequestCartDelegate> delegate;
@property (nonatomic, strong) NSDictionary *param;

@property (nonatomic, strong) UIViewController *viewController;

-(void)doRequestEMoney;
-(void)doRequestBCAClickPay;
-(void)doRequestCC;
-(void)dorequestBRIEPay;
-(void)doRequestToppay;

+(void)fetchCartData:(void(^)(TransactionCartResult *data))success error:(void (^)(NSError *error))error;

+(void)fetchCheckoutToken:(NSString *)token gatewayID:(NSString*)gatewayID listDropship:(NSArray *)listDropship dropshipDetail:(NSDictionary*)dropshipDetail listPartial:(NSArray *)listPartial partialDetail:(NSDictionary *)partialDetail isUsingSaldo:(BOOL)isUsingSaldo saldo:(NSString *)saldo voucherCode:(NSString*)voucherCode success:(void(^)(TransactionSummaryResult *data))success error:(void (^)(NSError *error))error;

+(void)fetchToppayWithToken:(NSString *)token gatewayID:(NSString *)gatewayID listDropship:(NSArray *)listDropship dropshipDetail:(NSDictionary *)dropshipDetail listPartial:(NSArray *)listPartial partialDetail:(NSDictionary *)partialDetail isUsingSaldo:(BOOL)isUsingSaldo saldo:(NSString *)saldo voucherCode:(NSString *)voucherCode success:(void (^)(TransactionActionResult *data))success error:(void (^)(NSError *))error;

+(void)fetchVoucherCode:(NSString*)voucherCode success:(void (^)(TransactionVoucherData *data))success error:(void (^)(NSError *error))error;

+(void)fetchDeleteProduct:(ProductDetail*)product cart:(TransactionCartList*)cart withType:(NSInteger)type success:(void (^)(TransactionAction *data, ProductDetail* product, TransactionCartList* cart, NSInteger type))success error:(void (^)(NSError *error))error;

+(void)fetchBuy:(TransactionSummaryDetail*)transaction dataCC:(NSDictionary*)dataCC mandiriToken:(NSString*)mandiriToken cardNumber:(NSString*)cardNumber password:(NSString*)password klikBCAUserID:(NSString*)klikBCAUserID success:(void (^)(TransactionBuyResult *data))success error:(void (^)(NSError *error))error;

+(void)fetchEditProduct:(ProductDetail*)product success:(void (^)(TransactionAction *data))success error:(void (^)(NSError *error))error;

@end
