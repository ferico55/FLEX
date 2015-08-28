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

@implementation RequestPayment
{
    objectManagerPayment *_objectManager;
    TokopediaNetworkManager *_networkManagerValidation;
    TokopediaNetworkManager *_networkManagerSubmit;
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
    return _networkManagerValidation;
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
    if ([_delegate getImageObject]) {
        [[self networkManagerValidation] doRequest];
    }
    else
    {
        [[self networkManagerSubmit] doRequest];
    }
}


-(void)doRequestValidation
{
    
}

-(void)doRequestGenerateHost
{
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
}

-(void)doUploadImage:(id)object withHost:(GenerateHost*)host;
{
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    uploadImage.imageObject = @{DATA_SELECTED_PHOTO_KEY:object};
    uploadImage.delegate = self;
    uploadImage.generateHost = host;
    //uploadImage.action = ACTION_UPLOAD_PRODUCT_IMAGE;
    uploadImage.fieldName = @"fileToUpload";
    [uploadImage configureRestkitUploadPhoto];
    [uploadImage requestActionUploadPhoto];
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
}

#pragma mark - Request Image Delegate
-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    [[self networkManagerSubmit] doRequest];
}

#pragma mark - Network Manager Delegate

-(NSDictionary *)getParameter:(int)tag
{
    if (tag == TAG_REQUEST_SUBMIT) {
        return [_delegate getParamConfirmation];
    }
    return nil;
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_REQUEST_SUBMIT) {
        return API_PATH_ACTION_TX_ORDER;
    }
    return nil;
}

-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_SUBMIT) {
        return [[self objectManager] objectManagerTransactionAction];
    }
    return nil;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
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
    if (tag == TAG_REQUEST_SUBMIT) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        id stat = [result objectForKey:@""];
        TransactionAction *order = stat;
        if(order.message_error)
        {
            NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:_delegate];
            [alert show];
        }
        if(order.result.is_success == 1)
        {
            [_delegate requestSuccessConfirmPayment:order];
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
    
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{

}

@end
