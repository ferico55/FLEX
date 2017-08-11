//
//  RKObjectManagerCategory.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "RKObjectManagerCategory.h"

static RKObjectManager *_sharedClient = nil;
static RKObjectManager *_sharedClientHttps = nil;

@implementation RKObjectManager (TkpdCategory)

+ (RKObjectManager *)sharedClient {
    _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[NSString basicUrl]]];

    return _sharedClient;
}

+ (RKObjectManager *)sharedClientHttps {
    _sharedClientHttps = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[NSString v4Url]]];
    
    return _sharedClientHttps;
}

+ (RKObjectManager *)sharedClient:(NSString*)baseUrl{
    _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:baseUrl?:[NSString basicUrl]]];
    
    return _sharedClient;
}


@end
