//
//  UIViewController+TKPAdditions.m
//  Tokopedia
//
//  Created by Harshad Dange on 18/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "UIViewController+TKPAdditions.h"

@implementation UIViewController (TKPAdditions)

- (void)viewDidLoad{
#if DEBUG
    NSLog(@"CLASS NAME: %@", self.class);
#endif
}

+ (id <TKPAppFlow>)TKP_rootController {
    id rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if ([rootController conformsToProtocol:@protocol(TKPAppFlow)]) {
        return rootController;
    }
    return nil;
}

@end
