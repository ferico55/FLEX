//
//  NSString+TPBaseUrl.h
//  Tokopedia
//
//  Created by Tonito Acen on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TPBaseUrl)

+ (NSString*)basicUrl;
+ (NSString*)aceUrl;
+ (NSString*)v4Url;
+ (NSString*)topAdsUrl;
+ (NSString*)keroUrl;

@end
