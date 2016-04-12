//
//  RequestResolutionAction.h
//  Tokopedia
//
//  Created by Renny Runiawati on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionAction.h"
#import "Tokopedia-Swift.h"
#import "UploadImageValidation.h"

@interface RequestResolutionAction : NSObject

+(void)fetchCancelResolutionID:(NSString*)resolutionID
                       success:(void(^) (ResolutionActionResult* data))success
                       failure:(void(^)(NSError* error))failure;

+(void)fetchCreateResolutionOrderID:(NSString*)orderID
                       flagReceived:(NSString*)flagReceived
                        troubleType:(NSString*)troubleType
                           solution:(NSString*)solution
                       refundAmount:(NSString*)refundAmount
                             remark:(NSString*)remark
                       imageObjects:(NSArray<DKAsset*>*)imageObjects
                            success:(void(^) (ResolutionActionResult* data))success
                            failure:(void(^)(NSError* error))failure;

+(void)fetchReplyResolutionID:(NSString *)resolutionID
                 flagReceived:(NSString *)flagReceived
                  troubleType:(NSString *)troubleType
                     solution:(NSString *)solution
                 refundAmount:(NSString *)refundAmount
                      message:(NSString *)message
               isEditSolution:(NSString *)isEditSolution
                 imageObjects:(NSArray<DKAsset*>*)imageObjects
                      success:(void(^) (ResolutionActionResult* data))success
                      failure:(void(^)(NSError* error))failure;

+(void)fetchReportResolutionID:(NSString*)resolutionID
                       success:(void(^) (ResolutionActionResult* data))success
                       failure:(void(^) (NSError* error))failure;

+(void)fetchInputResiResolutionID:(NSString*)resolutionID
                       shipmentID:(NSString*)shipmentID
                      shippingRef:(NSString*)shippingRef
                          success:(void(^) (ResolutionActionResult* data))success
                          failure:(void(^) (NSError* error))failure;

@end
