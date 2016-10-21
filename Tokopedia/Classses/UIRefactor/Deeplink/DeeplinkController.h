//
//  DeeplinkController.h
//  Tokopedia
//
//  Created by Tonito Acen on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeeplinkController : NSObject

+ (BOOL)handleURL:(NSURL *)url;
+ (BOOL)shouldOpenWebViewURL:(NSURL *)url;


@end
