//
//  RKObjectManagerCategory.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Tkpd.h"
#import "RKObjectManagerCategory.h"

// Set this to your Trakt API Key
NSString * const kTraktAPIKey = @"8b0c367dd3ef0860f5730ec64e3bbdc9";
NSString * const kTraktBaseURLString = kTkpdBaseURLString;



@implementation RKObjectManager (TkpdCategory)

+ (RKObjectManager *)sharedClient {
    static RKObjectManager *_sharedClient = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kTraktBaseURLString]];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBaseUrl) name:@"didChangeBaseUrl" object:nil];

    return _sharedClient;
}

+ (RKObjectManager *)sharedClient:(NSString*)baseUrl{
    static RKObjectManager *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:baseUrl?:kTraktBaseURLString]];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBaseUrl) name:@"didChangeBaseUrl" object:nil];
    
    return _sharedClient;
}

+ (RKObjectManager *)sharedClientUploadImage:(NSString*)baseURLString {
    static RKObjectManager *_sharedClient = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:baseURLString]];
    });
    return _sharedClient;
}

+ (void)refreshBaseUrl {
    static RKObjectManager *_sharedClient = nil;
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *data = [secureStorage keychainDictionary];

    _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[data objectForKey:@"AppBaseUrl"]?:kTraktBaseURLString]];
}


@end
