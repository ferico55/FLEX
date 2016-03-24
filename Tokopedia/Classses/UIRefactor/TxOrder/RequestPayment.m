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
#import "objectManagerPayment.h"
#import "RequestGenerateHost.h"
#import "string_tx_order.h"
#import "AlertInfoView.h"
#import "RequestObject.h"

@implementation RequestPayment
{
    objectManagerPayment *_objectManager;
    TokopediaNetworkManager *_networkManagerValidation;
    TokopediaNetworkManager *_networkManagerSubmit;
    
    UploadImage *_uploadImageObj;
}

-(TokopediaNetworkManager*)networkManagerValidation
{
    if (!_networkManagerValidation) {
        _networkManagerValidation = [TokopediaNetworkManager new];
        _networkManagerValidation.tagRequest = TAG_REQUEST_VALIDATION;
        _networkManagerValidation.delegate = self;
    }
    return _networkManagerValidation;
}

-(TokopediaNetworkManager *)networkManagerSubmit
{
    if (!_networkManagerSubmit) {
        _networkManagerSubmit = [TokopediaNetworkManager new];
        _networkManagerSubmit.tagRequest = TAG_REQUEST_SUBMIT;
        _networkManagerSubmit.delegate = self;
    }
    return _networkManagerSubmit;
}

-(objectManagerPayment*)objectManager
{
    if (!_objectManager) {
        _objectManager = [objectManagerPayment new];
    }
    return _objectManager;
}

-(void)doRequestPaymentConfirmation;
{
    if ([[_delegate getImageObject] isEqualToDictionary:@{}]) {
        [self doRequestSubmit];
    }
    else
    {
        [self doRequestValidation];
    }
}

-(void)doRequestValidation
{
    [[self networkManagerValidation]doRequest];
}

-(void)doRequestGenerateHost
{
    [RequestGenerateHost fetchGenerateHostSuccess:^(GeneratedHost *host) {
        
    }];
}

-(void)doUploadImage:(id)object withHost:(GenerateHost*)host;
{
    RequestUploadImage *requestImage = [RequestUploadImage new];
    requestImage.generateHost = host;
    requestImage.imageObject = @{DATA_SELECTED_PHOTO_KEY:object};
    requestImage.action = ACTION_UPLOAD_PROOF_IMAGE;
    requestImage.fieldName = API_FORM_FIELD_NAME_PROOF;
    requestImage.delegate = self;
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    requestImage.paymentID = [auth getUserId];
    //TxOrderConfirmedList *selectedConfirmation = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
    //requestImage.paymentID = selectedConfirmation.payment_id?:@"";
    [requestImage configureRestkitUploadPhoto];
    [requestImage requestActionUploadPhoto];
}

-(void)doRequestSubmit
{
    [[self networkManagerSubmit] doRequest];
}

#pragma mark - Generate Host Delegate
-(void)successGenerateHost:(GenerateHost *)generateHost
{
    [self doUploadImage:[_delegate getImageObject] withHost:generateHost];
}

- (void)failedGenerateHost:(NSArray *)errorMessages
{
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:_delegate];
    [stickyAlertView show];
    [_delegate actionAfterRequest];
}

#pragma mark - Request Image Delegate
-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    _uploadImageObj = uploadImage;
    [self doRequestSubmit];
}

-(void)failedUploadErrorMessage:(NSArray *)errorMessage
{
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:_delegate];
    [stickyAlertView show];
}

-(void)failedUploadObject:(id)object
{
    [_delegate actionAfterRequest];
}

#pragma mark - Network Manager Delegate

-(NSDictionary *)getParameter:(int)tag
{
    if (tag == TAG_REQUEST_VALIDATION) {
        return [_delegate getParamConfirmationValidation:YES pictObj:@""];
    }
    if (tag == TAG_REQUEST_SUBMIT) {
        return [_delegate getParamConfirmationValidation:NO pictObj:_uploadImageObj.result.pic_obj?:@""];
    }
    return nil;
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_REQUEST_VALIDATION) {
        return API_PATH_ACTION_TX_ORDER;
    }
    
    if (tag == TAG_REQUEST_SUBMIT) {
        return API_PATH_ACTION_TX_ORDER;
    }
    return nil;
}

-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_VALIDATION) {
        return [[self objectManager] objectManagerTransactionAction];
    }
    
    if (tag == TAG_REQUEST_SUBMIT) {
        return [[self objectManager] objectManagerTransactionAction];
    }
    return nil;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if (tag == TAG_REQUEST_VALIDATION) {
        TransactionAction *action = stat;
        return action.status;
    }
    if (tag == TAG_REQUEST_SUBMIT) {
        TransactionAction *action = stat;
        return action.status;
    }
    
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    if (tag == TAG_REQUEST_VALIDATION) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        id stat = [result objectForKey:@""];
        TransactionAction *order = stat;
        if(order.result.is_success == 1)
        {
            [self doRequestGenerateHost];
        }
        else
        {
            NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:_delegate];
            [alert show];
            [_delegate actionAfterRequest];
        }
    }
    if (tag == TAG_REQUEST_SUBMIT) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        id stat = [result objectForKey:@""];
        TransactionAction *order = stat;
        if(order.result.is_success == 1)
        {
            [_delegate requestSuccessConfirmPayment:order];
            [_delegate actionAfterRequest];
        }
        else
        {
            NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:_delegate];
            [alert show];
            [_delegate actionAfterRequest];
            
        }
    }
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    NSError *error = errorResult;
    NSArray *errors;
    
    if (error.code==-1009 || error.code==-999) {
        errors = @[@"Tidak ada koneksi internet"];
    } else {
        errors = @[@"Mohon maaf, terjadi kendala pada server"];
    }
    
    StickyAlertView *failedAlert = [[StickyAlertView alloc]initWithErrorMessages:errors?:@[@"Error"] delegate:_delegate];
    [failedAlert show];
    [_delegate actionAfterRequest];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    [_delegate actionAfterRequest];
}

+(void)requestPaymentConfirmationImage:(UIImage*)image imageName:(NSString*)imageName fileName:(NSString*)fileName requestObject:(RequestObjectUploadImage*)object Success:(void(^)(TransactionAction *data))success{
    
    if (image == nil) {
        
    }
    
    [RequestGenerateHost fetchGenerateHostSuccess:^(GeneratedHost *host) {
        [RequestUploadImage requestUploadImage:image withUploadHost:host.upload_host path:@"ws/action/upload-image.pl" name:imageName fileName:@"payment_image" requestObject:object onSuccess:^(ImageResult *imageResult) {
            
        } onFailure:^(NSError *error) {
            
        }];
    }];
}

+(void)requestSubmitSuccess:(void(^)(TransactionAction *data))success{
    
}

@end
