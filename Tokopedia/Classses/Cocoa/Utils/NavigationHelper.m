//
//  NavigationHelper.m
//  Tokopedia
//
//  Created by Samuel Edwin on 11/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "NavigationHelper.h"

@implementation NavigationHelper
+(BOOL) shouldDoDeepNavigation {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}
@end
