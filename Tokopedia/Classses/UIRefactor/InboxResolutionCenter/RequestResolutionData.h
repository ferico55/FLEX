//
//  RequestResolutionData.h
//  Tokopedia
//
//  Created by Renny Runiawati on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RequestResolutionAction.h"
#import "InboxResolutionCenter.h"
#import "ResolutionCenterDetail.h"
#import "ShipmentOrder.h"
#import "ResolutionCenterCreateResponse.h"
#import "ResolutionProductResponse.h"
#import "ResolutionCenterCreatePOSTResponse.h"
@class EditResolutionFormData;

typedef enum{
    TypeResolutionAll,
    TypeResolutionBuyer,
    TypeResolutionMine
} TypeResolution;

@interface RequestResolutionData : NSObject

+(void)fetchDataResolutionType:(NSString*)type
                          page:(NSString*)page
                      sortType:(NSString*)sortType
                 statusProcess:(NSString*)statusProcess
                    statusRead:(NSString*)statusRead
                       success:(void(^) (InboxResolutionCenterResult* data, NSString *nextPage, NSString* uriNext))success
                       failure:(void(^)(NSError* error))failure;

+(void)fetchDataDetailResolutionID:(NSString*)resolutionID
                           success:(void(^) (ResolutionCenterDetailResult* data))success
                           failure:(void(^)(NSError* error))failure;

+(void)fetchDataShowMoreResolutionID:(NSString*)resolutionID
                         hasSolution:(NSString*)hasSolution
                              lastUt:(NSString*)lastUt
                             startUt:(NSString*)startUt
                             success:(void(^) (ResolutionCenterDetailResult* data))success
                             failure:(void(^)(NSError* error))failure;

+(void)fetchListCourierSuccess:(void(^) (NSArray<ShipmentCourier*>* shipments))success
                        failure:(void(^)(NSError* error))failure;

+(void)fetchCreateResolutionDataWithOrderId:(NSString*)orderId
                                    success:(void(^) (ResolutionCenterCreateResponse* data))success
                                    failure:(void(^)(NSError* error))failure;
+(void)fetchAllProductsInTransactionWithOrderId:(NSString*)orderId
                                      success:(void(^) (ResolutionProductResponse* data))success
                                      failure:(void(^)(NSError* error))failure;
+(void)fetchPossibleSolutionWithPossibleTroubleObject:(ResolutionCenterCreatePOSTRequest*)possibleTrouble
                                            troubleId:(NSString*)troubleId
                                              success:(void(^) (ResolutionCenterCreatePOSTResponse* result))success
                                              failure:(void(^) (NSError* error))failure;

+(void)fetchformEditResolutionID:(NSString *)resolutionID
                    isGetProduct:(BOOL)isGetProduct
                       onSuccess:(void(^) (EditResolutionFormData* data))onSuccess
                       onFailure:(void(^)(NSError* error))onFailure;

+(void)fetchformAppealResolutionID:(NSString *)resolutionID
                         onSuccess:(void(^) (EditResolutionFormData* data))onSuccess
                         onFailure:(void(^)(NSError* error))onFailure;
@end
