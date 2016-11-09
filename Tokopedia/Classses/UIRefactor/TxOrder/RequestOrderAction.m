//
//  RequestOrderAction.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/31/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestOrderAction.h"
#import "StickyAlertView+NetworkErrorHandler.h"
#import "GenerateHostRequest.h"
#import "RequestUploadImage.h"
#import "TxOrderConfirmation.h"
#import "TxOrderConfirmed.h"

typedef void (^failedCompletionBlock)(NSError *error);

static failedCompletionBlock failedCompletionSubmitConfirmation;
static failedCompletionBlock failedUploadProof;

@implementation RequestOrderAction

+(void)fetchConfirmDeliveryOrderStatus:(TxOrderStatusList*)order
                         success:(void (^)(TxOrderStatusList *order, TransactionActionResult* data))success
                         failure:(void (^)(NSError *error, TxOrderStatusList *order))failure{

    NSDictionary* param = @{@"order_id" : order.order_detail.detail_order_id};
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx-order/delivery_finish_order.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        TransactionAction *response = [successResult.dictionary objectForKey:@""];
        
        if (response.data.is_success == 1) {
            success(order,response.data);
        }
        else{
            [StickyAlertView showErrorMessage:response.message_error?:@[@"Permintaan anda gagal. Mohon coba kembali"]];
            failure(nil, order);
        }
        
    } onFailure:^(NSError *errorResult) {
        failure(errorResult, order);
    }];
}

+(void)fetchConfirmDeliveryOrderDeliver:(TxOrderStatusList*)order
                               success:(void (^)(TxOrderStatusList *order, TransactionActionResult* data))success
                               failure:(void (^)(NSError *error, TxOrderStatusList *order))failure {
    
    NSDictionary* param = @{@"order_id" : order.order_detail.detail_order_id};
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx-order/delivery_confirm.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TransactionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success == 1) {
                                     success(order,response.result);
                                 }
                                 else{
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Permintaan anda gagal. Mohon coba kembali"]];
                                     failure(nil, order);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult, order);
                             }];
}


+(void)fetchReorder:(TxOrderStatusList*)order
            success:(void (^)(TxOrderStatusList *order, TransactionActionResult* data))success
            failure:(void (^)(NSError *error, TxOrderStatusList *order))failure{
    
    NSDictionary* param = @{@"action"   : @"reorder",
                            @"order_id" : order.order_detail.detail_order_id};
    
    TokopediaNetworkManager *network = [TokopediaNetworkManager new];
    //network.isUsingHmac = YES;
    [network requestWithBaseUrl:[NSString basicUrl] //[NSString v4Url]
                           path:@"action/tx-order.pl" //@"/v4/action/tx-order/reorder.pl"
                         method:RKRequestMethodPOST//RKRequestMethodGET
                      parameter:param
                        mapping:[TransactionAction mapping]
                      onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        TransactionAction *response = [successResult.dictionary objectForKey:@""];
        
        if (response.result.is_success == 1) {
            success(order,response.result);
        }
        else
        {
            [StickyAlertView showErrorMessage:response.message_error?:@[@"Pesan ulang tidak dapat dilakukan"]];
            failure(nil,order);
        }
    } onFailure:^(NSError *errorResult) {
        failure(errorResult,order);
    }];
}

+(void)fetchUploadImageProof:(UIImage*)image imageName:(NSString*)imageName paymentID:(NSString*)paymentID success:(void (^)(TransactionActionResult *data))success failure:(void (^)(NSError *error))failure {
    
    failedUploadProof = failure;
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    RequestObjectUploadImage *objectRequest = [RequestObjectUploadImage new];
    objectRequest.user_id = [auth getUserId];
    objectRequest.payment_id = paymentID;
    objectRequest.action = @"upload_proof_image";
    
    [RequestOrderAction fetchImageProof:image
                           imageName:imageName?:@"image.png"
                       requestObject:objectRequest
                             success:^(ImageResult *data) {
                                 [RequestOrderAction fetchValidProof:data success:^(TransactionActionResult *data) {
                                     success(data);
                                 }];
                             }];
}

+(void)fetchValidProof:(ImageResult*)dataImage
               success:(void (^)(TransactionActionResult *data))success {
    
    NSDictionary* param = @{
                            @"pic_obj" : dataImage.pic_obj?:@"",
                            @"pic_src" : dataImage.pic_src?:@""
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx-order/upload_valid_proof_by_payment.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TransactionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data.is_success == 1) {
                                     success(response.data);
                                 }
                                 else{
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"Permintaan anda gagal. Mohon coba kembali"]];
                                     failedUploadProof(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedUploadProof(errorResult);
                             }];
}

+(void)fetchImageProof:(UIImage*)image imageName:(NSString*)imageName requestObject:(RequestObjectUploadImage*)object success:(void(^)(ImageResult *data))success {
    
    [GenerateHostRequest fetchGenerateHostOnSuccess:^(GeneratedHost *host) {
        NSString *uploadImageBaseURL = [NSString stringWithFormat:@"https://%@",host.upload_host];
        [RequestUploadImage requestUploadImage:image
                                withUploadHost:uploadImageBaseURL
                                          path:@"/web-service/v4/action/upload-image/upload_proof_image.pl"
                                          name:@"payment_image"
                                      fileName:imageName
                                 requestObject:object
                                     onSuccess:^(ImageResult *imageResult) {
                                         
                                         success(imageResult);
                                         
                                     } onFailure:^(NSError *error) {
                                         failedCompletionSubmitConfirmation(error);
                                     }];
        
        
    } onFailure:^{
        failedCompletionSubmitConfirmation(nil);
    }];
}

+(NSDictionary*)getParamWithToken:(NSString*)token
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
                           picObj:(NSString*)picObj {
    
    NSString *methodID = method.method_id?:@"";
    NSString *paymentAmount = totalPayment?:@"";
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:paymentDate];
    NSNumber *year = @([components year])?:@(0);
    NSNumber *month = @([components month])?:@(0);
    NSNumber *day = @([components day])?:@(0);
    NSNumber *bankID = @(bankAccount.bank_id)?:@(0);
    NSString *bankName = bankAccount.bank_name?:@"";
    
    NSDictionary* param = @{
                            @"payment_id"       : paymentID,
                            @"confirmation_id"  : paymentID,
                            @"token"            : token?:@"",
                            @"method_id"        : methodID,
                            @"payment_amount"   : paymentAmount,
                            @"payment_day"      : day,
                            @"payment_month"    : month,
                            @"payment_year"     : year,
                            @"comments"         : note,
                            @"password"         : password,
                            @"password_deposit" : password,
                            @"depositor"        : depositor,
                            @"bank_id"          : bankID,
                            @"bank_name"        : bankName,
                            @"bank_account_name": bankAccountName,
                            @"bank_account_branch" : bankAccountBranch,
                            @"bank_account_number" : bankAccountNumber,
                            @"bank_account_id"  : bankAccountID,
                            @"sysbank_id"       : systemBankID,
                            @"pic_obj"          : picObj
                            };
    
    return param;
}

+(void)fetchValidationParam:(NSDictionary*)param success:(void(^)(TransactionAction *data))success{
    NSMutableDictionary *paramFull = [NSMutableDictionary new];
    [paramFull addEntriesFromDictionary:param];
    [paramFull setObject:@"validate_confirm_payment" forKey:@"action"];
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:[NSString basicUrl]
                                  path:@"action/tx-order.pl"
                                method:RKRequestMethodPOST
                             parameter:paramFull
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TransactionAction *response = [successResult.dictionary objectForKey:@""];
                                 if(response.result.is_success == 1){
                                     success(response);
                                 } else {
                                     failedCompletionSubmitConfirmation(nil);
                                     NSArray *array = response.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                                     [StickyAlertView showErrorMessage:array];
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedCompletionSubmitConfirmation(errorResult);
                             }];
}

+(void)fetchConfirmPaymentParam:(NSDictionary*)param success:(void(^)(TransactionAction *data))success{
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx-order/confirm_payment.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TransactionAction *response = [successResult.dictionary objectForKey:@""];
                                 if(response.data.is_success == 1){
                                     success(response);
                                 } else {
                                     failedCompletionSubmitConfirmation(nil);
                                     NSArray *array = response.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                                     [StickyAlertView showErrorMessage:array];
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failedCompletionSubmitConfirmation(errorResult);
                             }];
}

+(void)fetchEditPaymentWithMethod:(MethodList*)method
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
                           failed:(void(^)(NSError *error))failed {
    
    NSDictionary *param = [RequestOrderAction getParamWithToken:@"" method:method systemBankID:systemBankID bankAccount:bankAccount paymentID:paymentID paymentDate:paymentDate totalPayment:totalPayment note:note password:password bankAccountName:bankAccountName bankAccountBranch:bankAccountBranch bankAccountNumber:bankAccountNumber bankAccountID:bankAccountID depositor:depositor picObj:@""];
        
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx-order/edit_payment.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TransactionAction *response = [successResult.dictionary objectForKey:@""];
                                 if(response.data.is_success == 1){
                                     success(response);
                                 } else {
                                     failed(nil);
                                     NSArray *array = response.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                                     [StickyAlertView showErrorMessage:array];
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failed(errorResult);
                             }];
}

+(void)fetchConfirmPaymentWithImageObject:(NSDictionary*)imageObject
                            token:(NSString*)token
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
                           failed:(void(^)(NSError *error))failed {
    
    failedCompletionSubmitConfirmation = failed;
    
    if ([imageObject isEqual:@{}]) {
        
        NSDictionary *param = [RequestOrderAction getParamWithToken:token method:method systemBankID:systemBankID bankAccount:bankAccount paymentID:paymentID paymentDate:paymentDate totalPayment:totalPayment note:note password:password bankAccountName:bankAccountName bankAccountBranch:bankAccountBranch bankAccountNumber:bankAccountNumber bankAccountID:bankAccountID depositor:depositor picObj:@""];
        
        [RequestOrderAction fetchConfirmPaymentParam:param success:^(TransactionAction *data) {
            success(data);
        }];
    } else {
        
        NSDictionary *param = [RequestOrderAction getParamWithToken:token method:method systemBankID:systemBankID bankAccount:bankAccount paymentID:paymentID paymentDate:paymentDate totalPayment:totalPayment note:note password:password bankAccountName:bankAccountName bankAccountBranch:bankAccountBranch bankAccountNumber:bankAccountNumber bankAccountID:bankAccountID depositor:depositor picObj:@""];
        
        [RequestOrderAction fetchValidationParam:param success:^(TransactionAction *data) {
            
            UserAuthentificationManager *auth = [UserAuthentificationManager new];
            RequestObjectUploadImage *objectRequest = [RequestObjectUploadImage new];
            objectRequest.token = token;
            objectRequest.user_id = [auth getUserId];
            objectRequest.payment_id = [auth getUserId];
            objectRequest.action = @"upload_proof_image";
            
            [RequestOrderAction fetchImageProof:imageObject[@"photo"]
                                   imageName:imageObject[@"cameraimagename"]?:@"image.png"
                               requestObject:objectRequest
                                     success:^(ImageResult *data) {
                                         
                                         NSDictionary *param = [RequestOrderAction getParamWithToken:token method:method systemBankID:systemBankID bankAccount:bankAccount paymentID:paymentID paymentDate:paymentDate totalPayment:totalPayment note:note password:password bankAccountName:bankAccountName bankAccountBranch:bankAccountBranch bankAccountNumber:bankAccountNumber bankAccountID:bankAccountID depositor:depositor picObj:data.pic_obj];
                                         
                                         [RequestOrderAction fetchConfirmPaymentParam:param
                                                                   success:^(TransactionAction *data) {
                                                                       success(data);
                                                                   }];
                                     }];
        }];
    }
}

+(void)fetchCancelConfirmationID:(NSString*)confirmationID
                             Success:(void (^)(TransactionAction *data))success
                             failure:(void (^)(NSError *error))failure {
    
    
    NSDictionary* param = @{
                            @"confirmation_id":confirmationID
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx-order/cancel_payment.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TransactionAction *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if(response.data.is_success == 1)
                                 {
                                     NSArray *array = response.message_status?:[[NSArray alloc] initWithObjects:@"Anda telah berhasil membatalkan konfirmasi pembayaran", nil];
                                     [StickyAlertView showSuccessMessage:array];
                                     success(response);
                                 } else {
                                     NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
                                     [StickyAlertView showErrorMessage:array];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

@end
