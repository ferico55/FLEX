
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

#define TkpdNotificationForcedLogout @"NOTIFICATION_FORCE_LOGOUT"

@implementation TokopediaNetworkManager
@synthesize tagRequest;

- (id)init {
    self = [super init];
    
    if(self != nil) {
        _operationQueue = [NSOperationQueue new];
    }
    
    return self;
}

#pragma mark - Process Request
- (void)doRequest {
    if(_objectRequest.isExecuting) return;
    
    _requestCount ++;
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionBeforeRequest:)]) {
        [_delegate actionBeforeRequest:self.tagRequest];
    }
    
    
    _objectManager  = [_delegate getObjectManager:self.tagRequest];
    _objectRequest = [_objectManager appropriateObjectRequestOperationWithObject:_delegate
                                                                          method:(_delegate && [_delegate respondsToSelector:@selector(didReceiveRequestMethod:)])?[_delegate didReceiveRequestMethod:self.tagRequest]:RKRequestMethodPOST
                                                                            path:[_delegate getPath:self.tagRequest]
                                                                      parameters:(!_isParameterNotEncrypted ? [[_delegate getParameter:self.tagRequest] encrypt] : [_delegate getParameter:self.tagRequest])];
    
    
    [_requestTimer invalidate];
    _requestTimer = nil;
    [_objectRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [self requestSuccess:mappingResult  withOperation:operation];
        [_requestTimer invalidate];
        _requestTimer = nil;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
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
                } else if (error.code==-1009 || error.code==-999) {
                    errors = @[@"Tidak ada koneksi internet"];
                } else {
                    errors = @[error.localizedDescription];
                }
                
                if ([_delegate isKindOfClass:[UIViewController class]])
                    alert = [[StickyAlertView alloc] initWithErrorMessages:errors delegate:_delegate];
                else
                    alert = [[StickyAlertView alloc] initWithErrorMessages:errors delegate:                    [((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject]];
                
                [alert show];
            
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

- (void)requestCancel {
    [_objectRequest cancel];
    _objectRequest = nil;
    
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
    
}

- (void)resetRequestCount {
    _requestCount = 0;
}

@end
