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
NSString * const kTraktBaseURLHttpsString = kTkpdBaseURLHttpsString;
NSString *_selectedBaseUrl;
static RKObjectManager *_sharedClient = nil;
static RKObjectManager *_sharedClientHttps = nil;

@implementation RKObjectManager (TkpdCategory)

+ (RKObjectManager *)sharedClient {
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kTraktBaseURLString]];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBaseUrl) name:@"didChangeBaseUrl" object:nil];
    
    return _sharedClient;
}

+ (RKObjectManager *)sharedClientHttps {
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClientHttps = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kTraktBaseURLHttpsString]];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBaseUrl) name:@"didChangeBaseUrl" object:nil];
    
    return _sharedClientHttps;
}

+ (RKObjectManager *)sharedClient:(NSString*)baseUrl{
    static RKObjectManager *_sharedClient = nil;
    
    _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:baseUrl?:kTraktBaseURLString]];
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
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *data = [secureStorage keychainDictionary];
    
    _selectedBaseUrl = [data objectForKey:@"AppBaseUrl"];
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:_selectedBaseUrl]];
    });
}


@end
