//
//  RequestMoveTo.m
//  Tokopedia
//
//  Created by IT Tkpd on 4/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestMoveTo.h"
#import "ShopSettings.h"
#import "EtalaseList.h"
#import "detail.h"

@implementation RequestMoveTo
{
    NSOperationQueue *_operationQueue;
    
    RKObjectManager *_objectmanagerActionMoveToWarehouse;
    RKManagedObjectRequestOperation *_requestActionMoveToWarehouse;
    
    RKObjectManager *_objectmanagerActionMoveToEtalase;
    RKManagedObjectRequestOperation *_requestActionMoveToEtalase;
    
    RKObjectManager *_objectmanagerActionAddEtalase;
    RKManagedObjectRequestOperation *_requestActionAddEtalase;
    
    NSString *_etalaseName;
    NSString *_etalaseID;
    NSString *_productID;
}


#pragma mark Request Action MoveToWarehouse
-(void)cancelActionMoveToWarehouse
{
    [_requestActionMoveToWarehouse cancel];
    _requestActionMoveToWarehouse = nil;
    [_objectmanagerActionMoveToWarehouse.operationQueue cancelAllOperations];
    _objectmanagerActionMoveToWarehouse = nil;
}

-(void)configureRestKitActionMoveToWarehouse
{
    _operationQueue = [NSOperationQueue new];
    _objectmanagerActionMoveToWarehouse = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionMoveToWarehouse addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionMoveToWarehouse:(NSString*)productID etalaseName:(NSString *)etalaseName
{
    _etalaseName = etalaseName;
    
    [self configureRestKitActionMoveToWarehouse];
    if (_requestActionMoveToWarehouse.isExecuting) return;
    NSTimer *timer;
    
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:ACTION_MOVE_TO_WAREHOUSE,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : productID,
                            };
    _requestActionMoveToWarehouse = [_objectmanagerActionMoveToWarehouse appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]]; //kTKPDPROFILE_PROFILESETTINGAPIPATH
    
    [_requestActionMoveToWarehouse setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionMoveToWarehouse:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionMoveToWarehouse:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionMoveToWarehouse];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionMoveToWarehouse) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionMoveToWarehouse:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionMoveToWarehouse:object];
    }
}

-(void)requestFailureActionMoveToWarehouse:(id)object
{
    [self requestProcessActionMoveToWarehouse:object];
}

-(void)requestProcessActionMoveToWarehouse:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    [_delegate failedMoveToWithMessages:array];
                }
                if (setting.result.is_success == 1) {
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:@"Anda telah berhasil menggudangkan produk", nil];
                    [_delegate successMoveToWithMessages:array];
                    [[NSNotificationCenter defaultCenter] postNotificationName:MOVE_PRODUCT_TO_WAREHOUSE_NOTIFICATION object:nil userInfo:nil];
                }
            }
        }
        else{
            [self cancelActionMoveToWarehouse];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionMoveToWarehouse
{
    [self cancelActionMoveToWarehouse];
}


#pragma mark Request Action MoveToEtalase
-(void)cancelActionMoveToEtalase
{
    [_requestActionMoveToEtalase cancel];
    _requestActionMoveToEtalase = nil;
    [_objectmanagerActionMoveToEtalase.operationQueue cancelAllOperations];
    _objectmanagerActionMoveToEtalase = nil;
}

-(void)configureRestKitActionMoveToEtalase
{
    _operationQueue = [NSOperationQueue new];
    _objectmanagerActionMoveToEtalase = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionMoveToEtalase addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionMoveToEtalase:(NSString*)productID etalaseID:(NSString*)etalaseID etalaseName:(NSString*)etalaseName
{
    _etalaseName = etalaseName;
    
    [self configureRestKitActionMoveToEtalase];
    if (_requestActionMoveToEtalase.isExecuting) return;
    NSTimer *timer;
    
    if ([etalaseID integerValue] == -1) {
        [self requestActionAddEtalase:etalaseName];
        _productID = productID;
        _etalaseID = etalaseID;
        _etalaseName = etalaseName;
        return;
    }
    
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY            : ACTION_EDIT_ETALASE,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY  : productID,
                            @"product_etalase_name"               : etalaseName,
                            @"product_etalase_id"             : etalaseID
                            };
    _requestActionMoveToEtalase = [_objectmanagerActionMoveToEtalase appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]]; //kTKPDPROFILE_PROFILESETTINGAPIPATH
    
    [_requestActionMoveToEtalase setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionMoveToEtalase:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionMoveToEtalase:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionMoveToEtalase];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionMoveToEtalase) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionMoveToEtalase:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionMoveToEtalase:object];
    }
}

-(void)requestFailureActionMoveToEtalase:(id)object
{
    [self requestProcessActionMoveToEtalase:object];
}

-(void)requestProcessActionMoveToEtalase:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    [_delegate failedMoveToWithMessages:array];
                    
                }
                if (setting.result.is_success == 1) {
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:@"Anda telah berhasil memindahkan produk ke etalase", nil];
                    [_delegate successMoveToWithMessages:array];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:MOVE_PRODUCT_TO_ETALASE_NOTIFICATION object:nil userInfo:@{kTKPDSHOP_APIETALASENAMEKEY : _etalaseName}];
                }
            }
        }
        else{
            [self cancelActionMoveToEtalase];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionMoveToEtalase
{
    [self cancelActionMoveToEtalase];
}

#pragma mark - Request Action AddEtalase
-(void)cancelActionAddEtalase
{
    [_requestActionAddEtalase cancel];
    _requestActionAddEtalase = nil;
    [_objectmanagerActionAddEtalase.operationQueue cancelAllOperations];
    _objectmanagerActionAddEtalase = nil;
}

-(void)configureRestKitActionAddEtalase
{
    _objectmanagerActionAddEtalase = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY,
                                                        @"etalase_id" : @"etalase_id"}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDDETAILSHOPETALASEACTION_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionAddEtalase addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionAddEtalase:(NSString*)etalaseName
{
    [self configureRestKitActionAddEtalase];
    if (_requestActionAddEtalase.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY    :@"event_shop_add_etalase",
                            kTKPDSHOP_APIETALASENAMEKEY : etalaseName,
                            };
    
    _requestActionAddEtalase = [_objectmanagerActionAddEtalase appropriateObjectRequestOperationWithObject:self
                                                                                                    method:RKRequestMethodPOST
                                                                                                      path:kTKPDDETAILSHOPETALASEACTION_APIPATH
                                                                                                parameters:[param encrypt]];
    
    [_requestActionAddEtalase setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddEtalase:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddEtalase:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionAddEtalase];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionAddEtalase) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionAddEtalase:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionAddEtalase:object];
    }
}

-(void)requestFailureActionAddEtalase:(id)object
{
    [self requestProcessActionAddEtalase:object];
}

-(void)requestProcessActionAddEtalase:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (setting.result.is_success == 1) {
                    [self requestActionMoveToEtalase:_productID etalaseID:setting.result.etalase_id etalaseName:_etalaseName];
                }
            }
            
            if(setting.message_error) {
                [_delegate failedMoveToWithMessages:setting.message_error?:@[@""]];

            }
        } else {
            [self cancelActionAddEtalase];
        }
    }
}

-(void)requestTimeoutActionAddEtalase
{
    [self cancelActionAddEtalase];
}

@end
