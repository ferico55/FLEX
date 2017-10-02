//
//  PromoDetailViewController.m
//  Tokopedia
//
//  Created by Ferico Samuel on 7/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "PromoDetailViewController.h"
#import <React/RCTRootView.h>
#import "UIApplication+React.h"
#import "Tokopedia-Swift.h"

@interface PromoDetailViewController ()

@end

@implementation PromoDetailViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[UIApplication sharedApplication].reactBridge
                                                     moduleName:@"Tokopedia"
                                              initialProperties:@{@"name" : @"PromoDetail", @"params" : self.promoName }];
    self.view = rootView;
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Promo Detail Page"];
}

@end
