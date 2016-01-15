//
//  RKObjectManagerCategory.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Tkpd.h"
#import "RKObjectManagerCategory.h"

NSString * const TKPDBaseUrl = kTkpdBaseURLString;

NSString *_selectedBaseUrl;
static RKObjectManager *_sharedClient = nil;
static RKObjectManager *_sharedClientHttps = nil;

@implementation RKObjectManager (TkpdCategory)

+ (RKObjectManager *)sharedClient {
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TKPDBaseUrl]];
        _sharedClientHttps = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[self TKPDStringHttps:TKPDBaseUrl]]];
        
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBaseUrl) name:@"didChangeBaseUrl" object:nil];
    
    return _sharedClient;
}

+ (RKObjectManager *)sharedClientHttps {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClientHttps = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[self TKPDStringHttps:TKPDBaseUrl]]];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBaseUrl) name:@"didChangeBaseUrl" object:nil];
    
    return _sharedClientHttps;
}

+ (RKObjectManager *)sharedClient:(NSString*)baseUrl{
    static RKObjectManager *_sharedClient = nil;
    
    _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:baseUrl?:TKPDBaseUrl]];
    _sharedClientHttps = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[self TKPDStringHttps:TKPDBaseUrl]]];
    
    return _sharedClient;
}


+ (void)refreshBaseUrl {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *data = [secureStorage keychainDictionary];
    
    _selectedBaseUrl = [data objectForKey:@"AppBaseUrl"];
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:_selectedBaseUrl]];
        _sharedClientHttps = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[self TKPDStringHttps:_selectedBaseUrl]]];
    });
}

+ (NSString*)TKPDStringHttps:(NSString*)url {
    NSString *httpsUrl;
    if([url isEqualToString:@"http://www.tokopedia.com/ws"]) {
        httpsUrl = @"https://ws.tokopedia.com";
    } else {
        httpsUrl = [url stringByReplacingOccurrencesOfString:@"http://" withString:@"https://ws-"];
        httpsUrl = [httpsUrl stringByReplacingOccurrencesOfString:@"com/ws" withString:@"com"];
    }
    
    
    return httpsUrl;
}

@end
