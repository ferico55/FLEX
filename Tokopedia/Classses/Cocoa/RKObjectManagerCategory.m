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

RKObjectManager *_sharedClient = nil;

@implementation RKObjectManager (TkpdCategory)

+ (RKObjectManager *)sharedClient {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *container = appDelegate.container;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[container stringForKey:@"base_url"]?:kTraktBaseURLString]];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBaseUrl) name:@"didChangeBaseUrl" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshClient) name:@"didRefreshGTM" object:nil];

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

    _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[data objectForKey:@"AppBaseUrl"]?:kTraktBaseURLString]];
}

+ (void)refreshClient {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *container = appDelegate.container;

    _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[container stringForKey:@"base_url"]]];
}


@end
