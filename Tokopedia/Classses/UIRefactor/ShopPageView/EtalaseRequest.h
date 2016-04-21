//
//  EtalaseRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 4/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Etalase.h"
#import "ShopSettings.h"

@interface EtalaseRequest : NSObject
-(void)requestEtalaseFilterWithShopId:(NSString*)shopId
                                 page:(NSInteger)page
                            onSuccess:(void (^)(Etalase *etalase))successCallback
                            onFailure:(void (^)(NSError *error))errorCallback;

-(void)requestMyShopEtalaseWithShopId:(NSString*)shopId
                                 page:(NSInteger)page
                            onSuccess:(void (^)(Etalase *etalase))successCallback
                            onFailure:(void (^)(NSError *error))errorCallback;

-(void)requestActionAddEtalaseWithName:(NSString*)name
                                userId:(NSString*)userId
                             onSuccess:(void (^)(ShopSettings *shopSettings))successCallback
                             onFailure:(void (^)(NSError *error))errorCallback;

-(void)requestActionEditEtalaseWithId:(NSString*)etalaseId
                                 name:(NSString*)name
                               userId:(NSString*)userId
                            onSuccess:(void (^)(ShopSettings *shopSettings, NSString* name))successCallback
                            onFailure:(void (^)(NSError *error))errorCallback;

-(void)requestActionDeleteEtalaseWithId:(NSString*)etalaseId
                                 userId:(NSString*)userId
                              onSuccess:(void (^)(ShopSettings *shopSettings))successCallback
                              onFailure:(void (^)(NSError *error))errorCallback;

-(NSString*)splitUriToPage:(NSString*)uri;
-(void)cancelAllRequest;
@end
