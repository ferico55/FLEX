//
//  TKPHomeBannerStore.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPHomeBannerStore.h"
#import "SliderObject.h"
#import "TKPStoreManager.h"
#import "MiniSlideObject.h"
#import "MiniSlide.h"

NSString static *const TKPAPIPageKey = @"page";
NSString static *const TKPAPILimitKey = @"per_page";
NSInteger static const TKPSuccessStatusCode = 200;

@implementation TKPHomeBannerStore

- (instancetype)initWithStoreManager:(TKPStoreManager *)storeManager {
    self = [super init];
    if (self != nil) {
        _storeManager = storeManager;
    }
    
    return self;
}


- (void)fetchBannerWithCompletion:(void (^)(NSArray<Slide*>*, NSError *))completion {
    RKObjectManager *objectManager = [RKObjectManager sharedClient:@"https://mojito.tokopedia.com/api/v1"];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[SliderObject mapping] method:RKRequestMethodGET pathPattern:@"slides" keyPath:@"" statusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 299)]];
    [objectManager addResponseDescriptor:responseDescriptor];

    NSDictionary *parameters = @{@"page[size]" : @"25", @"filter[device]" : @"16", @"filter[target]" : @"65535", @"filter[state]" : @"1"};
    RKObjectRequestOperation *operation = [objectManager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodGET path:@"slides" parameters:[parameters autoParameters]];

    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *result = [mappingResult dictionary];
        SliderObject *banner = result[@""];

        if (completion != nil) {
            completion(banner.data.slides, nil);
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (completion != nil) {
            completion(nil, error);
        }
    }];
    
    [self.storeManager.networkQueue addOperation:operation];
}


- (void)fetchMiniSlideWithCompletion:(void (^)(NSArray<MiniSlide *> *, NSError *))completion {
    RKObjectManager *objectManager = [RKObjectManager sharedClient:@"https://mojito.tokopedia.com/api/v1"];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MiniSlideObject mapping] method:RKRequestMethodGET pathPattern:@"slides" keyPath:@"" statusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 299)]];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    NSDictionary *parameters = @{@"page[size]" : @"25", @"filter[device]" : @"16", @"filter[target]" : @"65535", @"filter[state]" : @"1", @"filter[slide_type]" : @"digital_items", @"filter[expired]" : @"1"};
    
    RKObjectRequestOperation *operation = [objectManager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodGET path:@"slides" parameters:[parameters autoParameters]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *result = [mappingResult dictionary];
        MiniSlideObject *banner = result[@""];
        
        if (completion != nil) {
            completion(banner.data.slides, nil);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (completion != nil) {
            completion(nil, error);
        }
    }];
    
    [self.storeManager.networkQueue addOperation:operation];
}

- (void)stopBannerRequest {
    [self.storeManager.networkQueue cancelAllOperations];
}

@end
