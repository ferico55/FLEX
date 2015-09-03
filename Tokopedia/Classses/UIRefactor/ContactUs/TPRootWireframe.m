//
//  TPRootWireframe.m
//  Tokopedia
//
//  Created by Tokopedia on 9/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TPRootWireframe.h"

@implementation TPRootWireframe

- (void)showRootViewController:(UIViewController *)viewController
                      inWindow:(UIWindow *)window {
    UINavigationController *navigation = [self navigationControllerFromWindow:window];
    navigation.viewControllers = @[viewController];
}

- (UINavigationController *)navigationControllerFromWindow:(UIWindow *)window {
    UINavigationController *navigation = (UINavigationController *)[window rootViewController];
    return navigation;
}

@end
