//
//  OpenShopRequest.h
//  Tokopedia
//
//  Created by Tokopedia on 4/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenShopRequest : NSObject

+ (void)checkDomain:(NSString *)domain setCompletionBlockWithSuccess:(void (^)(id response))success
            failure:(void (^)(NSArray *errorMessages))failure;

+ (void)submitOpenShopPostKey:(NSString *)key
                 fileUploaded:(NSString *)fileUploaded
setCompletionBlockWithSuccess:(void (^)(id response))success
                      failure:(void (^)(NSArray *errorMessages))failure;

+ (void)validateShopWithParameters:(NSDictionary *)parameter
     setCompletionBlockWithSuccess:(void (^)(id))success
                           failure:(void (^)(NSArray *))failure;

@end
