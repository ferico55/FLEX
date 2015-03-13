//
//  TokopediaNetworkManager.h
//  Tokopedia
//
//  Created by Tokopedia on 3/11/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "URLCacheConnection.h"
#import "URLCacheController.h"

@protocol TokopediaNetworkManagerDelegate <NSObject>

@required
- (NSDictionary*)getParameter;
- (NSString*)getPath;
- (id)getObjectManager;
- (NSString*)getRequestStatus:(id)result;

@optional
- (void)actionBeforeRequest;
- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation;

- (void)actionAfterRequestAsync;
- (void)actionAfterRequestFailAsync;

@end

@interface TokopediaNetworkManager : NSObject {
    URLCacheConnection *_urlCacheConnection;
    URLCacheController *_urlCacheController;
    
    NSOperationQueue *_queueForRequest;
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_objectRequest;
    
    NSTimer *_requestTimer;
    NSInteger *_nextPage;
    NSInteger *_limitPerPage;
    NSInteger *_requestCount;
    NSDictionary *_parameter;
    NSOperationQueue *_operationQueue;
    
    BOOL _isNoData;
    NSMutableArray *objectArray;
    
}

@property (assign, nonatomic) id<TokopediaNetworkManagerDelegate> delegate;

- (void)doRequest;
- (void)requestProcess:(id)processResult;
- (void)requestSuccess:(id)successResult withOperation:(RKObjectRequestOperation*)operation;
- (void)requestFail:(id)errorResult;
- (void)requestTimeout;
- (void)requestMaintenance;
- (void)requestRetryWithButton;
- (NSString*)splitUriToPage:(NSString*)uri;

@end
