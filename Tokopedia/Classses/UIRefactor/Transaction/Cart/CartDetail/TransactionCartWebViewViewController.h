//
//  TransactionCartWebViewViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionSummaryDetail.h"
#import "TransactionActionResult.h"

@protocol TransactionCartWebViewViewControllerDelegate <NSObject>

@required
- (void)shouldDoRequestEMoney:(BOOL)isWSNew;
- (void)shouldDoRequestBCAClickPay;
- (void)doRequestCC:(NSDictionary*)param;
- (void)isSucessSprintAsia:(NSDictionary*)param;
- (void)shouldDoRequestBRIEPayCode:(NSString*)code;
- (void)shouldDoRequestTopPayThxCode:(NSString*)code;

@end

@interface TransactionCartWebViewViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<TransactionCartWebViewViewControllerDelegate> delegate;

@property NSDictionary *CCParam;
@property NSNumber *gateway;
@property (strong, nonatomic) NSString *gatewayCode;
@property BOOL isVeritrans;
@property NSString *token;
@property NSString *URLString;
@property NSString *emoney_code;
@property NSString *transactionCode;
@property TransactionSummaryDetail *cartDetail;
@property NSString *toppayQueryString;
@property NSDictionary *toppayParam;
@property NSString *paymentID;
@property NSString *callbackURL;

+(void)pushBCAKlikPayFrom:(UIViewController*)vc cartDetail:(TransactionSummaryDetail*)cartDetail;
+(void)pushMandiriECashFrom:(UIViewController*)vc cartDetail:(TransactionSummaryDetail*)cartDetail LinkMandiri:(NSString*)linkMandiri;
+(void)pushBRIEPayFrom:(UIViewController*)vc cartDetail:(TransactionSummaryDetail*)cartDetail;
+(void)pushToppayFrom:(UIViewController*)vc data:(TransactionActionResult*)data gatewayID:(NSInteger)gatewayID gatewayName:(NSString*)gatewayName;

@end

