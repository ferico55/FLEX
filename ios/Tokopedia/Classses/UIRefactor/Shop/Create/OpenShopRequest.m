//
//  OpenShopRequest.m
//  Tokopedia
//
//  Created by Tokopedia on 4/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "OpenShopRequest.h"
#import "AddShop.h"

@implementation OpenShopRequest

+ (void)checkDomain:(NSString *)domain
setCompletionBlockWithSuccess:(void (^)(id))success
            failure:(void (^)(NSArray *))failure {
    NSDictionary *parameter = @{@"shop_domain": domain};
    __strong TokopediaNetworkManager *manager = [TokopediaNetworkManager new];
    [manager requestWithBaseUrl:[NSString v4Url]
                           path:@"/v4/action/myshop/check_domain.pl"
                         method:RKRequestMethodGET
                      parameter:parameter
                        mapping:[AddShop mapping]
                      onSuccess:^(RKMappingResult *successResult,
                                  RKObjectRequestOperation *operation) {
                          success(nil);
                      } onFailure:^(NSError *errorResult) {
                          failure(nil);
                      }];
}

+ (void)submitOpenShopPostKey:(NSString *)key
                 fileUploaded:(NSString *)fileUploaded
setCompletionBlockWithSuccess:(void (^)(id))success
                      failure:(void (^)(NSArray *))failure {
    NSDictionary *parameter = @{@"file_uploaded": fileUploaded, @"post_key": key};
    __strong TokopediaNetworkManager *manager = [TokopediaNetworkManager new];
    [manager requestWithBaseUrl:[NSString v4Url]
                           path:@"/v4/action/myshop/open_shop_submit.pl"
                         method:RKRequestMethodGET
                      parameter:parameter
                        mapping:[AddShop mapping]
                      onSuccess:^(RKMappingResult *successResult,
                                  RKObjectRequestOperation *operation) {
        
    } onFailure:^(NSError *errorResult) {
        
    }];
}

+ (void)validateShopWithParameters:(NSDictionary *)parameter
     setCompletionBlockWithSuccess:(void (^)(id))success
                           failure:(void (^)(NSArray *))failure {
    __strong TokopediaNetworkManager *manager = [TokopediaNetworkManager new];
    [manager requestWithBaseUrl:[NSString v4Url]
                           path:@"/v4/action/myshop/open_shop_validation"
                         method:RKRequestMethodGET
                      parameter:parameter
                        mapping:[AddShop mapping]
                      onSuccess:^(RKMappingResult *successResult,
                                  RKObjectRequestOperation *operation) {
                          
                      } onFailure:^(NSError *errorResult) {
                          
                      }];
}

@end
