
//
//  TokopediaNetworkManager.m
//  Tokopedia
//
//  Created by Tokopedia on 3/11/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TokopediaNetworkManager.h"
#import "StickyAlertView.h"
#import "NSString+MD5.h"
#import "TkpdHMAC.h"
#import <BlocksKit/BlocksKit.h>
#import "Tokopedia-Swift.h"
#import "NSOperationQueue+SharedQueue.h"

#define TkpdNotificationForcedLogout @"NOTIFICATION_FORCE_LOGOUT"

@implementation TokopediaNetworkManager {
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_objectRequest;
    
    NSTimer *_requestTimer;
    NSInteger _requestCount;
    NSDictionary *_parameter;
    NSOperationQueue *_operationQueue;
}
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

- (void)requestMaintenance  {
    MaintenanceViewController *maintenanceController = [MaintenanceViewController new];
    maintenanceController.hidesBottomBarWhenPushed = YES;
    UIViewController* vc = [UIApplication topViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
    
    if(vc.navigationController != nil) {
        [vc.navigationController pushViewController:maintenanceController animated:YES];
    }
}

- (void)requestRetryWithButton  {
    
}

#pragma mark - Util
- (RKManagedObjectRequestOperation *)getObjectRequest
{
    return _objectRequest;
}

- (NSString*)splitUriToPage:(NSString*)uri {
    return [TokopediaNetworkManager getPageFromUri:uri];
}

+ (NSString *)getPageFromUri:(NSString *)uri {
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
    [self requestWithBaseUrl:baseUrl
                        path:path
                      method:method
                      header:@{}
                   parameter:parameter
                     mapping:mapping
                   onSuccess:successCallback
                   onFailure:errorCallback];
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
    NSArray *errors;
    
    NSHTTPURLResponse *response = error.userInfo[AFRKNetworkingOperationFailingURLResponseErrorKey];
    
    if (response.statusCode == 403) {
        errors = @[@"Permintaan request ditolak"];
    }
    else if(error.code == -1011 || error.code == -999) {
        errors = @[@"Terjadi kendala pada server. Mohon coba beberapa saat lagi."];
    } else if (error.code == -1009) {
        errors = @[@"Tidak ada koneksi internet"];
    } else {
        errors = @[error.localizedDescription];
        return;
    }
    
    [StickyAlertView showErrorMessage:errors];
}

- (void)requestWithBaseUrl:(NSString*)baseUrl
                      path:(NSString*)path
                    method:(RKRequestMethod)method
                    header:(NSDictionary<NSString *, NSString *> *)header
                 parameter:(NSDictionary<NSString*, NSString*>*)parameter
                   mapping:(RKObjectMapping*)mapping
                 onSuccess:(void(^)(RKMappingResult* successResult, RKObjectRequestOperation* operation))successCallback
                 onFailure:(void(^)(NSError* errorResult)) errorCallback {
    if(_objectRequest.isExecuting) return;

    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"application/vnd.api+json"];
    
    NSDictionary* bindedParameters = [parameter autoParameters];
    
    _requestCount ++;
    
    _objectManager  = [RKObjectManager sharedClient:baseUrl];
    RKResponseDescriptor* responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                  method:method
                                                                                             pathPattern:path
                                                                                                 keyPath:@""
                                                                                             statusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)]];
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
    

    NSString *appVersion = [UIApplication getAppVersionString];
    [_objectManager.HTTPClient setDefaultHeader:@"X-APP-VERSION" value:appVersion];
    [_objectManager.HTTPClient setDefaultHeader:@"Accept-Language" value:@"id-ID"];
    NSString *xDevice = [NSString stringWithFormat:@"ios-%@",appVersion];
    [_objectManager.HTTPClient setDefaultHeader:@"X-Device" value:xDevice];
    [_objectManager.HTTPClient setDefaultHeader:@"Accept-Encoding" value:@"gzip"];

    RKManagedObjectRequestOperation *operation = nil;
    
    if(self.isUsingHmac) {
        TkpdHMAC *hmac = [TkpdHMAC new];
        [hmac signatureWithBaseUrl:baseUrl method:RKStringFromRequestMethod(method) path:path parameter:bindedParameters];
        
        NSDictionary* authorizedHeaders = [hmac authorizedHeaders];
        
        [authorizedHeaders bk_each:^(NSString* key, NSString* value) {
             [_objectManager.HTTPClient setDefaultHeader:key value:value];
        }];
        
        [header bk_each:^(NSString *key, NSString *value) {
            [_objectManager.HTTPClient setDefaultHeader:key value:value];
        }];
        
        operation = [_objectManager appropriateObjectRequestOperationWithObject:nil
                                                                         method:method
                                                                           path:path
                                                                     parameters:bindedParameters];
    } else {
        NSDictionary *parameters;
        if (self.isParameterNotEncrypted) {
            parameters = parameter;
        } else {
            parameters = [parameter encrypt];
        }
        
        [header bk_each:^(NSString *key, NSString *value) {
            [_objectManager.HTTPClient setDefaultHeader:key value:value];
        }];
        
        operation = [_objectManager appropriateObjectRequestOperationWithObject:nil
                                                                         method:method
                                                                           path:path
                                                                     parameters:parameters];
    }
    
    _objectRequest = operation;
    
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
                //TODO :: Need to handle this status.
            } else if ([status isEqualToString:@"UNDER_MAINTENANCE"]) {
                [self requestMaintenance];
            } else if ([status isEqualToString:@"TOO_MANY_REQUEST"]) {
                [self requestMaintenance];
            } else if ([status isEqualToString:@"REQUEST_DENIED"]) {
                NSArray *responseDescriptors = _objectRequest.responseDescriptors;
                RKResponseDescriptor *response = responseDescriptors[0];
                NSString *path = response.pathPattern;
                
                if (![path isEqualToString:@"/v4/session/make_login.pl"]) {
                    AuthenticationService *authService = AuthenticationService.shared;
                    [authService getNewTokenOnCompletion:^(OAuthToken * _Nullable token, NSError * _Nullable error) {
                        if (error == nil) {
                            [authService reloginAccount];
                        } else {
                            NSString *baseURL = [response.baseURL absoluteString];
                            
                            [LogEntriesHelper logForceLogoutWithLastURL:[NSString stringWithFormat:@"%@%@", baseURL, path]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_FORCE_LOGOUT" object:nil userInfo:@{}];
                        }
                    }];
                }
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
                                  header:header
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
    
    if (_isUsingSharedOperationQueue){
        [[NSOperationQueue sharedOperationQueue] addOperation:_objectRequest];
    } else {
        [_operationQueue addOperation:_objectRequest];
    }
    NSTimeInterval timeInterval = _timeInterval ? _timeInterval : kTKPDREQUEST_TIMEOUTINTERVAL;
    
    __weak typeof(self) weakSelf = self;
    _requestTimer = [NSTimer bk_scheduledTimerWithTimeInterval:timeInterval block:^(NSTimer* timer) {
        [weakSelf requestCancel];
    } repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_requestTimer forMode:NSRunLoopCommonModes];

}

@end
