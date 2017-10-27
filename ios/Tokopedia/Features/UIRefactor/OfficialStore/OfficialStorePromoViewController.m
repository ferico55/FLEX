//
//  OfficialStoreBrandsViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 7/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "OfficialStorePromoViewController.h"
#import <React/RCTRootView.h>
#import "UIApplication+React.h"
#import "Tokopedia-Swift.h"

@interface OfficialStorePromoViewController ()

@end

@implementation OfficialStorePromoViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[UIApplication sharedApplication].reactBridge
                                                     moduleName:@"Tokopedia"
                                              initialProperties:@{@"name" : @"Official Store Promo", @"params" : @{@"slug" : self.promoSlug} }];
    
    self.view = rootView;
    self.view.isAccessibilityElement = true;
    self.view.accessibilityIdentifier = @"officialStorePromo";
    self.title = @"OS Promo";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Official Store Promo Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
