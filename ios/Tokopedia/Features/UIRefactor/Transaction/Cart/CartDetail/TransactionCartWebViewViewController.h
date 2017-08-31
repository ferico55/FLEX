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

@class DigitalCartPayment, TransactionCartPayment;

@protocol TransactionCartWebViewViewControllerDelegate <NSObject>

@required

- (void)shouldDoRequestTopPayThxCode:(NSString*)code toppayParam:(NSDictionary *)param;

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
@property BOOL shouldAuthorizedRequest;

+(void)pushToppayFrom:(UIViewController*)vc data:(TransactionActionResult*)data;
+(void)pushToppayFromURL:(NSString*)url viewController:(UIViewController*)vc shouldAuthorizedRequest:(BOOL)shouldAuthorizedRequest;

-(instancetype)initWithDigital:(DigitalCartPayment *) cart;
-(instancetype)initWithCart:(TransactionCartPayment *) cart;
@end

