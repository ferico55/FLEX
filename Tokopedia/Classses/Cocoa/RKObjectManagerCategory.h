//
//  RKObjectManagerCategory.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RKObjectManager.h>

extern NSString * const kTraktAPIKey;
extern NSString * const kTraktBaseURLString;

@interface RKObjectManager (TkpdCategory)

+ (RKObjectManager *)sharedClient;
+ (RKObjectManager *)sharedClientUploadImage:(NSString*)baseURLString;

+ (void)refreshClient;

@end