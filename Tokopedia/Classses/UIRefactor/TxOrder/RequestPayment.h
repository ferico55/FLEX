//
//  RequestPayment.h
//  Tokopedia
//
//  Created by Renny Runiawati on 8/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestGenerateHost.h"
#import "RequestUploadImage.h"
#import "objectManagerPayment.h"
#import "RequestGenerateHost.h"
#import "string_tx_order.h"
#import "AlertInfoView.h"
#import "RequestObject.h"
#import "MethodList.h"
#import "BankAccountFormList.h"
#import "TxOrderConfirmationList.h"

@class TransactionAction;

@protocol RequestPaymentDelegate <NSObject>
@required
-(NSDictionary *)getImageObject;
-(NSDictionary *)getParamConfirmationValidation:(BOOL)isStepValidation pictObj:(NSString*)picObj;
-(void)requestSuccessConfirmPayment:(TransactionAction*)action;
-(void)actionAfterRequest;
@end

@interface RequestPayment : NSObject <GenerateHostDelegate, TokopediaNetworkManagerDelegate, RequestUploadImageDelegate>

@property (nonatomic, weak) IBOutlet id<RequestPaymentDelegate> delegate;

-(void)doRequestPaymentConfirmation;

+(void)fetchSubmitWithImageObject:(NSDictionary*)imageObject
                      isConfirmed:(BOOL)isConfirmed
                            token:(NSString*)token
                    selectedOrder:(NSArray*)selectedOrder
                           method:(MethodList*)method
                     systemBankID:(NSString*)systemBankID
                      bankAccount:(BankAccountFormList*)bankAccount
                        paymentID:(NSString*)paymentID
                      paymentDate:(NSDate*)paymentDate
                     totalPayment:(NSString*)totalPayment
                             note:(NSString*)note
                         password:(NSString*)password
                  bankAccountName:(NSString*)bankAccountName
                bankAccountBranch:(NSString*)bankAccountBranch
                bankAccountNumber:(NSString*)bankAccountNumber
                    bankAccountID:(NSString*)bankAccountID
                        depositor:(NSString*)depositor
                          success:(void(^)(TransactionAction *data))success
                           failed:(void(^)(NSError *error))failed ;

@end
