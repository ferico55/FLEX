//
//  TokopediaDeepLink.h
//  Tokopedia
//
//  Created by Tokopedia on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TokopediaDeepLink : NSObject

+ (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation;

@end
