//
//  RequestCart.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TransactionAction.h"
#import "TransactionSummary.h"
#import "TransactionBuy.h"
#import "TransactionVoucher.h"
#import "TransactionCC.h"
#import "ListRekeningBank.h"

#import "TransactionObjectManager.h"
#import "string_transaction.h"

#define TAG_REQUEST_BRI_EPAY 19
#define TAG_REQUEST_TOPPAY 20

@protocol RequestCartDelegate <NSObject>
@required
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

-(void)dorequestBRIEPay;
-(void)doRequestToppay;

+(void)fetchCartData:(void(^)(TransactionCartResult *data))success error:(void (^)(NSError *error))error;

+(void)fetchCheckoutToken:(NSString *)token gatewayID:(NSString*)gatewayID listDropship:(NSArray *)listDropship dropshipDetail:(NSDictionary*)dropshipDetail listPartial:(NSArray *)listPartial partialDetail:(NSDictionary *)partialDetail isUsingSaldo:(BOOL)isUsingSaldo saldo:(NSString *)saldo voucherCode:(NSString*)voucherCode success:(void(^)(TransactionSummaryResult *data))success error:(void (^)(NSError *error))error;

+(void)fetchToppayWithToken:(NSString *)token gatewayID:(NSString *)gatewayID listDropship:(NSArray *)listDropship dropshipDetail:(NSDictionary *)dropshipDetail listPartial:(NSArray *)listPartial partialDetail:(NSDictionary *)partialDetail isUsingSaldo:(BOOL)isUsingSaldo saldo:(NSString *)saldo voucherCode:(NSString *)voucherCode success:(void (^)(TransactionActionResult *data))success error:(void (^)(NSError *))error;

+(void)fetchVoucherCode:(NSString*)voucherCode success:(void (^)(TransactionVoucherData *data))success error:(void (^)(NSError *error))error;

+(void)fetchDeleteProduct:(ProductDetail*)product cart:(TransactionCartList*)cart withType:(NSInteger)type success:(void (^)(TransactionAction *data, ProductDetail* product, TransactionCartList* cart, NSInteger type))success error:(void (^)(NSError *error))error;

+(void)fetchBuy:(TransactionSummaryDetail*)transaction dataCC:(NSDictionary*)dataCC mandiriToken:(NSString*)mandiriToken cardNumber:(NSString*)cardNumber password:(NSString*)password klikBCAUserID:(NSString*)klikBCAUserID success:(void (^)(TransactionBuyResult *data))success error:(void (^)(NSError *error))error;

+(void)fetchEditProduct:(ProductDetail*)product success:(void (^)(TransactionAction *data))success error:(void (^)(NSError *error))error;

+(void)fetchEMoneyCode:(NSString *)code success:(void (^)(TxEMoneyData *data))success error:(void (^)(NSError *error))error;

+(void)fetchBCAClickPaySuccess:(void (^)(TransactionBuyResult *data))success error:(void (^)(NSError *error))error;

+(void)fetchCCValidationFirstName:(NSString*)firstName lastName:(NSString*)lastName city:(NSString*)city postalCode:(NSString*)postalCode addressStreet:(NSString*)addressStreet phone:(NSString *)phone state:(NSString*)state cardNumber:(NSString*)cardNumber installmentBank:(NSString*)installmentBank InstallmentTerm:(NSString*)installmentTerm success:(void (^)(DataCredit *data))success error:(void (^)(NSError *error))error;

@end
