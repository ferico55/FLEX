//
//  CloseShopRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 5/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloseShopResponse.h"
@interface CloseShopRequest : NSObject
//all date will be dd/MM/YYYY
-(void)requestActionCloseShopFromNowUntil:(NSString*)dateUntil
                                closeNote:(NSString*)closeNote
                                onSuccess:(void (^)(CloseShopResponse*))successCallback
                                onFailure:(void (^)(NSError *))errorCallback;

-(void)requestActionOpenShopWithUserId:(NSString*)shopId
                              onSuccess:(void (^)(CloseShopResponse*))successCallback
                              onFailure:(void (^)(NSError *))errorCallback;

-(void)requestActionCloseShopFrom:(NSString*)dateFrom
                            until:(NSString*)dateUntil
                        closeNote:(NSString*)closeNote
                        onSuccess:(void (^)(CloseShopResponse*))successCallback
                        onFailure:(void (^)(NSError *))errorCallback;

-(void)requestActionAbortCloseScheduleOnSuccess:(void (^)(CloseShopResponse*))successCallback
                                      onFailure:(void (^)(NSError *))errorCallback;

-(void)requestActionExtendCloseShopUntil:(NSString*)dateUntil
                               closeNote:(NSString*)closeNote
                               onSuccess:(void (^)(CloseShopResponse*))successCallback
                               onFailure:(void (^)(NSError *))errorCallback;

@end
