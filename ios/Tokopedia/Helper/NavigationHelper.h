//
//  NavigationHelper.h
//  Tokopedia
//
//  Created by Samuel Edwin on 11/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigationHelper : NSObject
+(BOOL) shouldDoDeepNavigation;
+(BOOL) isKeywordRedirectToOfficialStore: (NSString*) keyword;
@end
