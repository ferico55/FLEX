//
//  TokopediaNetworkManager.m
//  Tokopedia
//
//  Created by Tokopedia on 3/11/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TokopediaNetworkManager.h"
#import "MaintenanceViewController.h"

@implementation TokopediaNetworkManager

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
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionBeforeRequest)]) {
        [_delegate actionBeforeRequest];
    }
    
    _objectManager  = [_delegate getObjectManager];
    _objectRequest = [_objectManager appropriateObjectRequestOperationWithObject:_delegate
                                                                          method:RKRequestMethodPOST
                                                                            path:[_delegate getPath]
                                                                      parameters:[[_delegate getParameter] encrypt]];
    
    NSTimer *timer;
    
    [_objectRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        
        if (_delegate && [_delegate respondsToSelector:@selector(actionAfterRequestAsync)]) {
            [_delegate actionAfterRequestAsync];
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFail:error];

        if (_delegate && [_delegate respondsToSelector:@selector(actionAfterRequestFailAsync)]) {
            [_delegate actionAfterRequestFailAsync];
        }
    }];
    
    [_operationQueue addOperation:_objectRequest];
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)requestProcess:(id)processResult withOperation:(RKObjectRequestOperation*)operation{
    if(processResult) {
        if([processResult isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)processResult).dictionary;
            id processResult = [result objectForKey:@""];
            
            if (_delegate && [_delegate respondsToSelector:@selector(actionAfterRequest:withOperation:)]) {
                [_delegate actionAfterRequest:processResult withOperation:operation];
            }
            

        } else {
            NSError *error = processResult;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

- (void)requestSuccess:(id)successResult withOperation:(RKObjectRequestOperation*)operation {
    if(successResult) {
        NSString* status = [_delegate getRequestStatus:successResult];
        if([status isEqualToString:@"OK"]) {
            [self requestProcess:successResult withOperation:operation];
        } else if ([status isEqualToString:@"INVALID_REQUEST"]) {
            
        } else if ([status isEqualToString:@"UNDER_MAINTENANCE"]) {
            [self requestMaintenance];
        }
    }
}

- (void)requestFail:(id)errorResult {
    [self requestProcess:errorResult withOperation:nil];
}

- (void)requestTimeout {
    if(_requestCount < kTKPDREQUESTCOUNTMAX) {
        [self cancel];
        [self doRequest];
    } else {
        if ([_delegate respondsToSelector:@selector(actionAfterFailRequestMaxTries)]) {
            
            [_delegate actionAfterFailRequestMaxTries];        }
    }
}

- (void)requestMaintenance  {
    //TODO:: Create MaintenanceViewController
    MaintenanceViewController *maintenanceController = [MaintenanceViewController new];
    UIViewController *vc = _delegate;
    [vc.navigationController pushViewController:maintenanceController animated:YES];
}

- (void)requestRetryWithButton  {
    
}

#pragma mark - Util
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

- (void)cancel {
    [_objectRequest cancel];
    _objectRequest = nil;
    
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;

}

- (void)resetRequestCount {
    _requestCount = 0;
}


@end
