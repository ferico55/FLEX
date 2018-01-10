//
//  PromoViewController.m
//  Tokopedia
//
//  Created by Ferico Samuel on 7/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "PromoViewController.h"
#import <React/RCTRootView.h>
#import "ReactEventManager.h"
#import "UIApplication+React.h"

@implementation PromoViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[UIApplication sharedApplication].reactBridge
                                                     moduleName:@"Tokopedia"
                                              initialProperties:@{@"name" : @"Promo", @"params" : @{} }];
    rootView.accessibilityLabel = @"promoMainView";
    self.view = rootView;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Promo Page"];
}

- (void)scrollToTop {
    ReactEventManager *tabManager = [[UIApplication sharedApplication].reactBridge moduleForClass:[ReactEventManager class]];
    [tabManager sendScrollToTopEvent];
}

@end
