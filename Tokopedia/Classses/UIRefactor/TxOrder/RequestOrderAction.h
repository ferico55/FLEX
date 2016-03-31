//
//  RequestOrderAction.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/31/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxOrderStatus.h"
#import "TransactionAction.h"
#import "TxOrderCancelPaymentForm.h"
#import "TxOrderConfirmPaymentForm.h"
#import "TxOrderPaymentEdit.h"
#import "TxOrderConfirmedDetail.h"
#import "ImageResult.h"
#import "RequestObject.h"

@interface RequestOrderAction : NSObject

+(void)fetchConfirmDeliveryOrder:(TxOrderStatusList*)order
                          action:(NSString*)action
                         success:(void (^)(TxOrderStatusList *order, TransactionActionResult* data))success
                         failure:(void (^)(NSError *error, TxOrderStatusList *order))failure;

+(void)fetchReorder:(TxOrderStatusList*)order
            success:(void (^)(TxOrderStatusList *order, TransactionActionResult* data))success
            failure:(void (^)(NSError *error, TxOrderStatusList *order))failure;

+(void)fetchSubmitWithImageObject:(NSDictionary*)imageObject
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
                           failed:(void(^)(NSError *error))failed;

+(void)fetchUploadImageProof:(UIImage*)image
                   imageName:(NSString*)imageName
                   paymentID:(NSString*)paymentID
                     success:(void (^)(TransactionActionResult *data))success
                     failure:(void (^)(NSError *error))failure;

@end
