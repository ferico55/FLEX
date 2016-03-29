//
//  RequestPayment.m
//  Tokopedia
//
//  Created by Renny Runiawati on 8/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#define TAG_REQUEST_VALIDATION 10
#define TAG_REQUEST_SUBMIT 12

#import "RequestPayment.h"
#import "StickyAlertView+NetworkErrorHandler.h"

typedef void (^failedCompletionBlock)(NSError *error);

static failedCompletionBlock failedCompletion;

@implementation RequestPayment

+(void)fetchImageProof:(UIImage*)image imageName:(NSString*)imageName requestObject:(RequestObjectUploadImage*)object success:(void(^)(ImageResult *data))success {
    
    [RequestGenerateHost fetchGenerateHostSuccess:^(GeneratedHost *host) {
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
                                         failedCompletion(error);
                                     }];
        
    } failure:^(NSError *error) {
        failedCompletion(error);
    }];
}

+(NSDictionary*)getParamIsValidation:(BOOL)isValidation
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
                              picObj:(NSString*)picObj {
    
    NSMutableArray *confirmationIDs = [NSMutableArray new];
    for (TxOrderConfirmationList *detail in selectedOrder) {
        [confirmationIDs addObject:detail.confirmation.confirmation_id];
    }
    
    NSString * confirmationID = [[confirmationIDs valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
    NSString *methodID = method.method_id?:@"";
    NSString *paymentAmount = totalPayment?:@"";
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:paymentDate];
    NSNumber *year = @([components year])?:@(0);
    NSNumber *month = @([components month])?:@(0);
    NSNumber *day = @([components day])?:@(0);
    NSNumber *bankID = @(bankAccount.bank_id)?:@(0);
    NSString *bankName = bankAccount.bank_name?:@"";
    NSString *action = isConfirmed?ACTION_EDIT_PAYMENT:ACTION_CONFIRM_PAYMENT;
    if (isValidation) {
        action = ACTION_CONFIRM_PAYMENT_VALIDATION;
    }
    
    NSDictionary* param = @{API_ACTION_KEY : action,
                            API_PAYMENT_ID_KEY : paymentID,
                            API_CONFIRMATION_CONFIRMATION_ID_KEY : confirmationID,
                            API_TOKEN_KEY : token,
                            API_METHOD_ID_KEY : methodID,
                            API_ORDER_PAYMENT_AMOUNT_KEY : paymentAmount,
                            API_PAYMENT_DAY_KEY : day,
                            API_PAYMENT_MONTH_KEY: month,
                            API_PAYMENT_YEAR_KEY :year,
                            API_PAYMENT_COMMENT_KEY : note,
                            API_PASSWORD_KEY : password,
                            API_PASSWORD_DEPOSIT_KEY :password,
                            API_DEPOSITOR_KEY : depositor,
                            API_BANK_ID_KEY : bankID,
                            API_BANK_NAME_KEY : bankName,
                            API_BANK_ACCOUNT_NAME_KEY : bankAccountName,
                            API_BANK_ACCOUNT_BRANCH_KEY : bankAccountBranch,
                            API_BANK_ACCOUNT_NUMBER_KEY : bankAccountNumber,
                            API_BANK_ACCOUNT_ID_KEY : bankAccountID,
                            API_SYSTEM_BANK_ID_KEY : systemBankID,
                            @"pic_obj":picObj
                            };

    return param;
}

+(void)fetchValidationParam:(NSDictionary*)param success:(void(^)(TransactionAction *data))success{
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString
                                  path:@"action/tx-order.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        TransactionAction *response = [successResult.dictionary objectForKey:@""];
        if(response.result.is_success == 1){
            success(response);
        } else {
            failedCompletion(nil);
            NSArray *array = response.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            [StickyAlertView showErrorMessage:array];
        }
        
    } onFailure:^(NSError *errorResult) {
        failedCompletion(errorResult);
    }];
}

+(void)fetchSubmitParam:(NSDictionary*)param success:(void(^)(TransactionAction *data))success{
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString
                                  path:@"action/tx-order.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        TransactionAction *response = [successResult.dictionary objectForKey:@""];
        if(response.result.is_success == 1){
            success(response);
        } else {
            failedCompletion(nil);
            NSArray *array = response.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            [StickyAlertView showErrorMessage:array];
        }
        
    } onFailure:^(NSError *errorResult) {
        failedCompletion(errorResult);
    }];
}

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
                           failed:(void(^)(NSError *error))failed {
    
    failedCompletion = failed;
    
    if ([imageObject isEqual:@{}]) {
        
        NSDictionary *param = [RequestPayment getParamIsValidation:NO isConfirmed:isConfirmed token:token selectedOrder:selectedOrder method:method systemBankID:systemBankID bankAccount:bankAccount paymentID:paymentID paymentDate:paymentDate totalPayment:totalPayment note:note password:password bankAccountName:bankAccountName bankAccountBranch:bankAccountBranch bankAccountNumber:bankAccountNumber bankAccountID:bankAccountID depositor:depositor picObj:@""];
        
        [RequestPayment fetchSubmitParam:param success:^(TransactionAction *data) {
            success(data);
        }];
    } else {
        
        NSDictionary *param = [RequestPayment getParamIsValidation:YES isConfirmed:isConfirmed token:token selectedOrder:selectedOrder method:method systemBankID:systemBankID bankAccount:bankAccount paymentID:paymentID paymentDate:paymentDate totalPayment:totalPayment note:note password:password bankAccountName:bankAccountName bankAccountBranch:bankAccountBranch bankAccountNumber:bankAccountNumber bankAccountID:bankAccountID depositor:depositor picObj:@""];
        
        [RequestPayment fetchValidationParam:param success:^(TransactionAction *data) {
            
            UserAuthentificationManager *auth = [UserAuthentificationManager new];
            RequestObjectUploadImage *objectRequest = [RequestObjectUploadImage new];
            objectRequest.token = token;
            objectRequest.user_id = [auth getUserId];
            objectRequest.payment_id = [auth getUserId];
            objectRequest.action = @"upload_proof_image";
            
            [RequestPayment fetchImageProof:imageObject[@"photo"]
                                  imageName:imageObject[@"cameraimagename"]?:@"image.png"
                              requestObject:objectRequest
                                    success:^(ImageResult *data) {
                                        
                                        NSDictionary *param = [RequestPayment getParamIsValidation:NO isConfirmed:isConfirmed token:token selectedOrder:selectedOrder method:method systemBankID:systemBankID bankAccount:bankAccount paymentID:paymentID paymentDate:paymentDate totalPayment:totalPayment note:note password:password bankAccountName:bankAccountName bankAccountBranch:bankAccountBranch bankAccountNumber:bankAccountNumber bankAccountID:bankAccountID depositor:depositor picObj:data.pic_obj];
                                        
                                        [RequestPayment fetchSubmitParam:param success:^(TransactionAction *data) {
                                            success(data);
                                        }];
                                    }];
        }];
    }
}

@end
