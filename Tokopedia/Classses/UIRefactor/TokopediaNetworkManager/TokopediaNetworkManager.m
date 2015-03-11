//
//  TokopediaNetworkManager.m
//  Tokopedia
//
//  Created by Tokopedia on 3/11/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TokopediaNetworkManager.h"

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

- (void)requestProcess:(id)processResult {
    if(processResult) {
        if([processResult isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)processResult).dictionary;
            id processResult = [result objectForKey:@""];
            
            if (_delegate && [_delegate respondsToSelector:@selector(actionAfterRequest:)]) {
                [_delegate actionAfterRequest:processResult];
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
            [self requestProcess:successResult];
        } else if ([status isEqualToString:@"INVALID_REQUEST"]) {
            
        } else if ([status isEqualToString:@"UNDER_MAINTENANCE"]) {
            [self requestMaintenance];
        }
    }
}

- (void)requestFail:(id)errorResult {
    [self requestProcess:errorResult];
}

- (void)requestTimeout {
    
}

- (void)requestMaintenance  {
    //TODO:: Create MaintenanceViewController
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


@end
