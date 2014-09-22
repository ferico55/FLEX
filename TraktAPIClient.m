//
//  TraktAPIClient.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Tkpd.h"
#import "TraktAPIClient.h"

// Set this to your Trakt API Key
NSString * const kTraktAPIKey = @"8b0c367dd3ef0860f5730ec64e3bbdc9";
NSString * const kTraktBaseURLString = kTkpdBaseURLString;

@implementation RKObjectManager (tkpdCategory)

+ (RKObjectManager *)sharedClient {
    static RKObjectManager *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kTraktBaseURLString]];
    });
    return _sharedClient;
}

@end
