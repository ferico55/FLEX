//
//  TKPHomeProductsStore.m
//  Tokopedia
//
//  Created by Harshad Dange on 15/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPHomeProductsStore.h"
#import <RestKit/RestKit.h>
#import "Hotlist.h"
#import "NSDictionaryCategory.h"
#import "TKPStoreManager.h"

NSString static *const TKPAPIActionKey = @"action";
NSString static *const TKPAPIPageKey = @"page";
NSString static *const TKPAPILimitKey = @"per_page";
NSString static *const TKPHotListArchiveFileName = @"home-hotlist";
NSString static *const TKPHotListArchiveNextPageKey = @"nextPage";
NSString static *const TKPHotListArchiveProductsKey = @"products";

@implementation TKPHomeProductsStore

- (instancetype)initWithStoreManager:(TKPStoreManager *)storeManager {
    self = [super init];
    if (self != nil) {
        _storeManager = storeManager;
    }
    
    return self;
}

- (void)loadCachedHotListProducts:(void (^)(NSArray *, NSInteger))completion {
    NSString *filePath = [self hotlistFilePath];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *archiveDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        NSArray *products = archiveDictionary[TKPHotListArchiveProductsKey];
        NSInteger nextPage = [archiveDictionary[TKPHotListArchiveNextPageKey] integerValue];
        if (completion != nil) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                completion(products, nextPage);
            });
        }
    });
}


- (void)archiveHotListProducts:(NSArray *)hotlistProducts nextPage:(NSInteger)page completion:(void (^)(BOOL))completion {
    NSString *filePath = [self hotlistFilePath];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL success = NO;
        if (hotlistProducts != nil) {
            NSDictionary *archiveDictionary = @{TKPHotListArchiveNextPageKey : @(page), TKPHotListArchiveProductsKey : hotlistProducts};
            success = [NSKeyedArchiver archiveRootObject:archiveDictionary toFile:filePath];
        }
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success);
            });
        }
    });
}

- (NSString *)hotlistFilePath {
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    if (filePath != nil) {
        filePath = [filePath stringByAppendingPathComponent:TKPHotListArchiveFileName];
    }
    
    return filePath;
}

@end
