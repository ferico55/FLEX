//
//  DataRequest.m
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DataRequest.h"

@implementation DataRequest

+ (void)requestWithParameters:(NSDictionary *)parameters
                  pathPattern:(NSString *)pathPattern
           responseDescriptor:(RKResponseDescriptor *)responseDescriptor
                   completion:(void (^)(id))completionBlock {
    
    parameters = [parameters encrypt];
    
    __weak RKObjectManager *objectManager = [RKObjectManager sharedClient];
    [objectManager addResponseDescriptor:responseDescriptor];

    __strong NSOperationQueue *operationQueue = [NSOperationQueue new];
    
    NSInteger maxNumberOfRequest = 0;
    while (maxNumberOfRequest <= 2) {
        maxNumberOfRequest++;
        __weak RKManagedObjectRequestOperation *request = [objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:pathPattern parameters:parameters];

        [operationQueue addOperation:request];
        
        [request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            completionBlock(mappingResult);
            [operationQueue cancelAllOperations];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (maxNumberOfRequest == 2) {
                completionBlock(error);
                [operationQueue cancelAllOperations];
            }
        }];
    }
}

@end
