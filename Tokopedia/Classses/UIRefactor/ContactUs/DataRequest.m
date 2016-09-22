//
//  DataRequest.m
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DataRequest.h"
#import "UserAuthentificationManager.h"

@implementation DataRequest

+ (void)requestWithParameters:(NSDictionary *)parameters
                  pathPattern:(NSString *)pathPattern
                         host:(GeneratedHost *)host
           responseDescriptor:(RKResponseDescriptor *)responseDescriptor
                   completion:(void (^)(id))completionBlock {
    
    __strong RKObjectManager *objectManager;
    
    if (host) {
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        parameters = [parameters mutableCopy];
        [parameters setValue:[auth getUserId] forKey:@"user_id"];
        [parameters setValue:[auth getMyDeviceToken] forKey:@"device_id"];
        [parameters setValue:@"2" forKey:@"os_type"];
        
        NSString *path = [NSString stringWithFormat:@"http://%@/ws", host.upload_host];
        objectManager = [RKObjectManager sharedClient:path];
    } else {
        parameters = [parameters encrypt];

        objectManager = [RKObjectManager sharedClient];
    }
    
    [objectManager addResponseDescriptor:responseDescriptor];

    __strong NSOperationQueue *operationQueue = [NSOperationQueue new];
    
    __weak RKManagedObjectRequestOperation *request = [objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:pathPattern parameters:parameters];

    [operationQueue addOperation:request];
    
    [request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        completionBlock(mappingResult);
        [operationQueue cancelAllOperations];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        completionBlock(error);
        [operationQueue cancelAllOperations];
    }];
}

@end
