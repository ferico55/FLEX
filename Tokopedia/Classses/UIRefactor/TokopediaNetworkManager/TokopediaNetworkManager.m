
//
//  TokopediaNetworkManager.m
//  Tokopedia
//
//  Created by Tokopedia on 3/11/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TokopediaNetworkManager.h"
#import "MaintenanceViewController.h"
#import "StickyAlertView.h"
#import "NSString+MD5.h"
#import "TkpdHMAC.h"
#import <BlocksKit/BlocksKit.h>

#define TkpdNotificationForcedLogout @"NOTIFICATION_FORCE_LOGOUT"

@implementation TokopediaNetworkManager
@synthesize tagRequest;

- (id)init {
    self = [super init];
    
    if(self != nil) {
        _operationQueue = [NSOperationQueue new];
        _isUsingDefaultError = YES;
    }
    
    return self;
}

- (NSString*)getStringRequestMethod:(int)requestMethod {
    if(requestMethod == RKRequestMethodPOST) {
        return @"POST";
    } else if (requestMethod == RKRequestMethodGET){
        return @"GET";
    } else if (requestMethod == RKRequestMethodPUT) {
        return @"PUT";
    }
    
    return nil;
}

#pragma mark - Process Request
- (void)doRequest {
    if(_objectRequest.isExecuting || !_delegate) return;
    
    _requestCount ++;
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionBeforeRequest:)]) {
        [_delegate actionBeforeRequest:self.tagRequest];
    }
    
    id requestObject = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(getRequestObject:)]) {
        requestObject = [_delegate getRequestObject:self.tagRequest];
    }
    
    RKRequestMethod requestMethod = RKRequestMethodPOST;
    if (_delegate && [_delegate respondsToSelector:@selector(getRequestMethod:)]) {
        requestMethod = [_delegate getRequestMethod:self.tagRequest];
    }
    
    _objectManager  = [_delegate getObjectManager:self.tagRequest];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_objectManager.HTTPClient setDefaultHeader:@"X-APP-VERSION" value:appVersion];

    [_objectManager.HTTPClient setDefaultHeader:@"X-Device" value:@"ios"];
    
    if(self.isUsingHmac) {
        TkpdHMAC *hmac = [TkpdHMAC new];
        NSString *signature = [hmac generateSignatureWithMethod:[self getStringRequestMethod:requestMethod] tkpdPath:[_delegate getPath:self.tagRequest] parameter:[_delegate getParameter:self.tagRequest]];
        
        [_objectManager.HTTPClient setDefaultHeader:@"Request-Method" value:[hmac getRequestMethod]];
        [_objectManager.HTTPClient setDefaultHeader:@"Content-MD5" value:[hmac getParameterMD5]];
        [_objectManager.HTTPClient setDefaultHeader:@"Content-Type" value:[hmac getContentType]];
        [_objectManager.HTTPClient setDefaultHeader:@"Date" value:[hmac getDate]];
        [_objectManager.HTTPClient setDefaultHeader:@"X-Tkpd-Path" value:[hmac getTkpdPath]];
        [_objectManager.HTTPClient setDefaultHeader:@"X-Method" value:[hmac getRequestMethod]];
        
        [_objectManager.HTTPClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"TKPD %@:%@", @"Tokopedia", signature]];
        [_objectManager.HTTPClient setDefaultHeader:@"X-Tkpd-Authorization" value:[NSString stringWithFormat:@"TKPD %@:%@", @"Tokopedia", signature]];
        
        _objectRequest = [_objectManager appropriateObjectRequestOperationWithObject:requestObject
                                                                              method:requestMethod
                                                                                path:[_delegate getPath:self.tagRequest]
                                                                          parameters:[[_delegate getParameter:self.tagRequest] autoParameters]];
    } else {
        NSDictionary *parameters;
        if (self.isParameterNotEncrypted) {
            parameters = [_delegate getParameter:self.tagRequest];
        } else {
            parameters = [[_delegate getParameter:self.tagRequest] encrypt];
        }
        _objectRequest = [_objectManager appropriateObjectRequestOperationWithObject:requestObject
                                                                              method:requestMethod
                                                                                path:[_delegate getPath:self.tagRequest]
                                                                          parameters:parameters];
        
    }
    
    
    
    [_requestTimer invalidate];
    _requestTimer = nil;
    [_objectRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Response string : %@", operation.HTTPRequestOperation.responseString);
        NSLog(@"Request body %@", [[NSString alloc] initWithData:[operation.HTTPRequestOperation.request HTTPBody]  encoding:NSUTF8StringEncoding]);
        [self requestSuccess:mappingResult  withOperation:operation];
        [_requestTimer invalidate];
        _requestTimer = nil; 
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        NSLog(@"Request body %@", [[NSString alloc] initWithData:[operation.HTTPRequestOperation.request HTTPBody]  encoding:NSUTF8StringEncoding]);

        [self requestFail:error];
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionRequestAsync:)]) {
        [_delegate actionRequestAsync:self.tagRequest];
    }
    
    [_operationQueue addOperation:_objectRequest];
    NSTimeInterval timeInterval = _timeInterval ? _timeInterval : kTKPDREQUEST_TIMEOUTINTERVAL;
    _requestTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_requestTimer forMode:NSRunLoopCommonModes];
}

- (void)requestProcess:(id)processResult withOperation:(RKObjectRequestOperation*)operation{
    if(processResult) {
        if([processResult isKindOfClass:[RKMappingResult class]]) {
            if (_delegate && [_delegate respondsToSelector:@selector(actionAfterRequest:withOperation:withTag:)]) {
                [_delegate actionAfterRequest:processResult withOperation:operation withTag:self.tagRequest];
            }
            
            
        } else {
            
            if(_delegate && [_delegate respondsToSelector:@selector(actionFailAfterRequest:withTag:)]) {
                [_delegate actionFailAfterRequest:processResult withTag:self.tagRequest];
            } else
            {
                NSError *error = processResult;
                StickyAlertView *alert;
                NSArray *errors;
                if(error.code == -1011) {
                    errors = @[@"Mohon maaf, terjadi kendala pada server"];
                } else if (error.code==-1009) {
                    errors = @[@"Tidak ada koneksi internet"];
                } else {
                    errors = @[error.localizedDescription];
                }
                
                if ([_delegate isKindOfClass:[UIViewController class]])
                    alert = [[StickyAlertView alloc] initWithErrorMessages:errors delegate:_delegate];
                else
                    alert = [[StickyAlertView alloc] initWithErrorMessages:errors delegate:                    [((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject]];
                
                //validate cancelled request
                if(error.code != -999) {
                    [alert show];
                }

                
            }
        }
    }
}

- (void)requestSuccess:(id)successResult withOperation:(RKObjectRequestOperation*)operation {
    if(successResult) {
        NSString* status = [_delegate getRequestStatus:successResult withTag:self.tagRequest];
        if([status isEqualToString:@"OK"]) {
            [self requestProcess:successResult withOperation:operation];
        } else if ([status isEqualToString:@"INVALID_REQUEST"]) {
            
        } else if ([status isEqualToString:@"UNDER_MAINTENANCE"]) {
            [self requestMaintenance];
        } else if ([status isEqualToString:@"REQUEST_DENIED"]) {
            NSLog(@"xxxxxxxxx REQUEST DENIED xxxxxxxxx");
            [[NSNotificationCenter defaultCenter] postNotificationName:TkpdNotificationForcedLogout object:nil userInfo:@{}];
        }
    }
}

- (void)requestFail:(id)errorResult {
    [self requestProcess:errorResult withOperation:nil];
}

- (void)requestTimeout {
    [self requestCancel];
    NSInteger requestCountMax = _maxTries?:kTKPDREQUESTCOUNTMAX;
    if(_requestCount < requestCountMax) {
        [self doRequest];
    } else {
        [self resetRequestCount];
        if ([_delegate respondsToSelector:@selector(actionAfterFailRequestMaxTries:)]) {
            
            [_delegate actionAfterFailRequestMaxTries:self.tagRequest];        }
    }
}

- (void)requestMaintenance  {
    //TODO:: Create MaintenanceViewController
    MaintenanceViewController *maintenanceController = [MaintenanceViewController new];
    UIViewController *vc = _delegate;
    
    if([[vc.navigationController.viewControllers lastObject] isMemberOfClass:[MaintenanceViewController class]])
        return;
    [vc.navigationController pushViewController:maintenanceController animated:YES];
}

- (void)requestRetryWithButton  {
    
}

#pragma mark - Util
- (RKManagedObjectRequestOperation *)getObjectRequest
{
    return _objectRequest;
}

- (NSString*)splitUriToPage:(NSString*)uri {
    NSURL *url = [NSURL URLWithString:uri];
    NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
    
    NSMutableDictionary *queries = [NSMutableDictionary new];
    [queries removeAllObjects];
    for (NSString *keyValuePair in querry)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [queries setObject:value forKey:key];
    }
    
    return [queries objectForKey:@"page"];
}

- (NSString*)explodeURL:(NSString*)URL withKey:(NSString*)key {
    NSURL *url = [NSURL URLWithString:URL];
    NSArray *querry = [[url query] componentsSeparatedByString: @"&"];
    
    NSMutableDictionary *queries = [NSMutableDictionary new];
    [queries removeAllObjects];
    
    for (NSString *keyValuePair in querry) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [queries setObject:value forKey:key];
    }
    
    return [queries objectForKey:key];
}



- (void)requestCancel {
    [_objectRequest cancel];
    _objectRequest = nil;
    
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
    
}

- (void)resetRequestCount {
    _requestCount = 0;
}

- (void)requestWithBaseUrl:(NSString *)baseUrl
                      path:(NSString *)path
                    method:(RKRequestMethod)method
                 parameter:(NSDictionary<NSString *,NSString *> *)parameter
                   mapping:(RKObjectMapping *)mapping
                 onSuccess:(void (^)(RKMappingResult *, RKObjectRequestOperation *))successCallback
                 onFailure:(void (^)(NSError *))errorCallback {
    if(_objectRequest.isExecuting) return;
    
    _requestCount ++;

    _objectManager  = [RKObjectManager sharedClient:baseUrl];
    RKResponseDescriptor* responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                  method:method
                                                                                             pathPattern:path
                                                                                                 keyPath:@""
                                                                                             statusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)]];
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_objectManager.HTTPClient setDefaultHeader:@"X-APP-VERSION" value:appVersion];
    
    if(self.isUsingHmac) {
        TkpdHMAC *hmac = [TkpdHMAC new];
        NSString *signature = [hmac generateSignatureWithMethod:[self getStringRequestMethod:method] tkpdPath:path parameter:parameter];
        
        [_objectManager.HTTPClient setDefaultHeader:@"Request-Method" value:[hmac getRequestMethod]];
        [_objectManager.HTTPClient setDefaultHeader:@"Content-MD5" value:[hmac getParameterMD5]];
        [_objectManager.HTTPClient setDefaultHeader:@"Content-Type" value:[hmac getContentType]];
        [_objectManager.HTTPClient setDefaultHeader:@"Date" value:[hmac getDate]];
        [_objectManager.HTTPClient setDefaultHeader:@"X-Tkpd-Path" value:[hmac getTkpdPath]];
        [_objectManager.HTTPClient setDefaultHeader:@"X-Method" value:[hmac getRequestMethod]];
        
        UserAuthentificationManager *userAuth = [UserAuthentificationManager new];
        NSString* userId = [userAuth getUserId];
        NSString* sessionId = [userAuth getMyDeviceToken];
        
        [_objectManager.HTTPClient setDefaultHeader:@"Tkpd-UserId" value:userId];
        [_objectManager.HTTPClient setDefaultHeader:@"Tkpd-SessionId" value:sessionId];
        [_objectManager.HTTPClient setDefaultHeader:@"X-Device" value:@"ios"];
        
        
        [_objectManager.HTTPClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"TKPD %@:%@", @"Tokopedia", signature]];
        [_objectManager.HTTPClient setDefaultHeader:@"X-Tkpd-Authorization" value:[NSString stringWithFormat:@"TKPD %@:%@", @"Tokopedia", signature]];
        
        _objectRequest = [_objectManager appropriateObjectRequestOperationWithObject:nil
                                                                              method:method
                                                                                path:path
                                                                          parameters:[parameter autoParameters]];
    } else {
        NSDictionary *parameters;
        if (self.isParameterNotEncrypted) {
            parameters = parameter;
        } else {
            parameters = [parameter encrypt];
        }
        _objectRequest = [_objectManager appropriateObjectRequestOperationWithObject:nil
                                                                              method:method
                                                                                path:path
                                                                          parameters:parameters];
    }
    
    
    [_requestTimer invalidate];
    _requestTimer = nil;
    [_objectRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
#ifdef DEBUG
        NSLog(@"Response string : %@", operation.HTTPRequestOperation.responseString);
        NSLog(@"Request body %@", [[NSString alloc] initWithData:[operation.HTTPRequestOperation.request HTTPBody]  encoding:NSUTF8StringEncoding]);
#endif
        
        NSDictionary* resultDict = mappingResult.dictionary;
        NSObject* mappedResult = [resultDict objectForKey:@""];
        
        if ([mappedResult respondsToSelector:@selector(status)]) {
        NSString* status = [mappedResult performSelector:@selector(status)];
        
            if([status isEqualToString:@"OK"]) {
                successCallback(mappingResult, operation);
            } else if ([status isEqualToString:@"INVALID_REQUEST"]) {
                
            } else if ([status isEqualToString:@"UNDER_MAINTENANCE"]) {
                [self requestMaintenance];
            } else if ([status isEqualToString:@"REQUEST_DENIED"]) {
                NSLog(@"xxxxxxxxx REQUEST DENIED xxxxxxxxx");
                [[NSNotificationCenter defaultCenter] postNotificationName:TkpdNotificationForcedLogout object:nil userInfo:@{}];
            }
        } else {
            successCallback(mappingResult, operation);
        }
        
        [_requestTimer invalidate];
        _requestTimer = nil;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Request body %@", [[NSString alloc] initWithData:[operation.HTTPRequestOperation.request HTTPBody]  encoding:NSUTF8StringEncoding]);
        
        NSInteger requestCountMax = _maxTries?:kTKPDREQUESTCOUNTMAX;
        if(_requestCount < requestCountMax) {
            //cancelled request
            if(error.code == -999) {
                [self requestWithBaseUrl:baseUrl
                                        path:path
                                      method:method
                                   parameter:parameter
                                     mapping:mapping
                                   onSuccess:successCallback
                                   onFailure:errorCallback];
            } else {
                [self handleErrorWithCallback:errorCallback error:error];
            }
        } else {
            [self handleErrorWithCallback:errorCallback error:error];
        }
        
    }];
    
    [_operationQueue addOperation:_objectRequest];
    NSTimeInterval timeInterval = _timeInterval ? _timeInterval : kTKPDREQUEST_TIMEOUTINTERVAL;

    __weak typeof(self) weakSelf = self;
    _requestTimer = [NSTimer bk_scheduledTimerWithTimeInterval:timeInterval block:^(NSTimer* timer) {
        [weakSelf requestCancel];
    } repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_requestTimer forMode:NSRunLoopCommonModes];

}

- (void)handleErrorWithCallback:(void (^)(NSError *))errorCallback error:(NSError *)error {
    if (errorCallback) {
        errorCallback(error);
        if(_isUsingDefaultError) {
            [self showErrorAlert:error];
        }
    } else {
        [self showErrorAlert:error];
    }
}

- (void)showErrorAlert:(NSError*)error {
    StickyAlertView *alert;
    NSArray *errors;
    if(error.code == -1011) {
        errors = @[@"Mohon maaf, terjadi kendala pada server"];
    } else if (error.code == -1009) {
        errors = @[@"Tidak ada koneksi internet"];
    } else if (error.code == -999) {
        errors = @[@"Terjadi kendala pada koneksi internet"];
    } else {
        errors = @[error.localizedDescription];
        return;
    }
    
    
    alert = [[StickyAlertView alloc] initWithErrorMessages:errors delegate:[((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject]];
    [alert show];
}

@end
