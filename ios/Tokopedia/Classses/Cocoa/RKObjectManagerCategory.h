//
//  RKObjectManagerCategory.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RKObjectManager (TkpdCategory)

+ (RKObjectManager *)sharedClient;
+ (RKObjectManager *)sharedClientHttps;
+ (RKObjectManager *)sharedClient:(NSString*)baseUrl;


@end