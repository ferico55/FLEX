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

@interface TokopediaNetworkManager : NSObject

@property (nonatomic) int tagRequest;
@property (nonatomic) BOOL isParameterNotEncrypted;
@property (nonatomic) BOOL isUsingHmac;
@property (nonatomic) BOOL isUsingDefaultError;
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic) NSInteger maxTries;

- (void)requestMaintenance;
- (void)requestRetryWithButton;
- (void)resetRequestCount;
- (NSString*)splitUriToPage:(NSString*)uri;
- (RKManagedObjectRequestOperation *)getObjectRequest;
- (void)requestCancel;
- (NSString*)explodeURL:(NSString*)URL withKey:(NSString*)key;
+ (NSString *)getPageFromUri:(NSString *)uri;

- (void) requestWithBaseUrl:(nonnull NSString*)baseUrl
                       path:(nonnull NSString*)path
                     method:(RKRequestMethod)method
                  parameter:(nullable NSDictionary<NSString*, NSString*>*)parameter
                    mapping:(nonnull RKObjectMapping*)mapping
                  onSuccess:(nonnull void(^)(RKMappingResult* _Nonnull successResult, RKObjectRequestOperation* _Nonnull operation))successCallback
                  onFailure:(nullable void(^)(NSError* _Nonnull errorResult)) errorCallback;

- (void) requestWithBaseUrl:(nonnull NSString*)baseUrl
                       path:(nonnull NSString*)path
                     method:(RKRequestMethod)method
                     header:(nullable NSDictionary<NSString *, NSString *> *)header
                  parameter:(nullable NSDictionary<NSString*, NSString*>*)parameter
                    mapping:(nonnull RKObjectMapping*)mapping
                  onSuccess:(nonnull void(^)(RKMappingResult* _Nonnull successResult, RKObjectRequestOperation* _Nonnull operation))successCallback
                  onFailure:(nullable void(^)(NSError* _Nonnull errorResult)) errorCallback;

@end
