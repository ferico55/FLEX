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
- (NSDictionary*)getParameter:(int)tag;
- (NSString*)getPath:(int)tag;
- (int)getRequestMethod:(int)tag;
- (id)getObjectManager:(int)tag;
- (id)getObjectRequest:(int)tag;
- (NSString*)getRequestStatus:(id)result withTag:(int)tag;
- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag;
- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag;

@optional
- (id)getRequestObject:(int)tag;
- (void)actionBeforeRequest:(int)tag;
- (void)actionRequestAsync:(int)tag;
- (void)actionAfterFailRequestMaxTries:(int)tag;
- (int)didReceiveRequestMethod:(int)tag;

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
    NSInteger _requestCount;
    NSDictionary *_parameter;
    NSOperationQueue *_operationQueue;
    
    
    BOOL _isNoData;
    NSMutableArray *objectArray;
    
}

@property (weak, nonatomic) id<TokopediaNetworkManagerDelegate> delegate;
@property (nonatomic) int tagRequest;
@property (nonatomic) BOOL isParameterNotEncrypted;
@property (nonatomic) BOOL isUsingHmac;
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic) NSInteger maxTries;

- (void)doRequest;
- (void)requestSuccess:(id)successResult withOperation:(RKObjectRequestOperation*)operation;
- (void)requestFail:(id)errorResult;
- (void)requestTimeout;
- (void)requestMaintenance;
- (void)requestRetryWithButton;
- (void)resetRequestCount;
- (NSString*)splitUriToPage:(NSString*)uri;
- (RKManagedObjectRequestOperation *)getObjectRequest;
- (void)requestCancel;
- (NSString*)explodeURL:(NSString*)URL withKey:(NSString*)key;


- (void) requestWithBaseUrl:(NSString*)baseUrl
                       path:(NSString*)path
                     method:(RKRequestMethod)method
                  parameter:(NSDictionary<NSString*, NSString*>*)parameter
                    mapping:(RKObjectMapping*)mapping
                  onSuccess:(void(^)(RKMappingResult* successResult, RKObjectRequestOperation* operation))successCallback
                  onFailure:(void(^)(NSError* errorResult)) errorCallback;


@end