//
//  TKPHomeBannerStore.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPHomeBannerStore.h"
#import "Banner.h"
#import "TKPStoreManager.h"

NSString *const TKPAPIPageKey = @"page";
NSString *const TKPAPILimitKey = @"per_page";
NSInteger const TKPSuccessStatusCode = 200;

@implementation TKPHomeBannerStore

- (instancetype)initWithStoreManager:(TKPStoreManager *)storeManager {
    self = [super init];
    if (self != nil) {
        _storeManager = storeManager;
    }
    
    return self;
}


- (void)fetchBannerWithCompletion:(void (^)(Banner *, NSError *))completion {
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[Banner mapping] method:RKRequestMethodPOST pathPattern:@"banner.pl" keyPath:@"" statusCodes:[NSIndexSet indexSetWithIndex:TKPSuccessStatusCode]];
    [objectManager addResponseDescriptor:responseDescriptor];

    NSDictionary *parameters = [@{@"action" : @"get_banner"} encrypt];
    RKObjectRequestOperation *operation = [objectManager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodPOST path:@"banner.pl" parameters:parameters];

    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *result = [mappingResult dictionary];
        Banner *banner = result[@""];
        if (completion != nil) {
            completion(banner, nil);
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (completion != nil) {
            completion(nil, error);
        }
    }];
    
    [self.storeManager.networkQueue addOperation:operation];
}

@end
