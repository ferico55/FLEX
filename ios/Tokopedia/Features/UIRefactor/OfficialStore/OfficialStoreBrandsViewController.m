//
//  OfficialStoreBrandsViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 7/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "OfficialStoreBrandsViewController.h"
#import <React/RCTRootView.h>
#import "UIApplication+React.h"
#import "Tokopedia-Swift.h"

@interface OfficialStoreBrandsViewController ()

@end

@implementation OfficialStoreBrandsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[UIApplication sharedApplication].reactBridge
                                                     moduleName:@"Tokopedia"
                                              initialProperties:@{@"name" : @"Official Store", @"params" : _data }];
    
    self.view = rootView;
    self.view.isAccessibilityElement = true;
    self.view.accessibilityIdentifier = @"officialStoreBrands";
    self.title = @"Official Store";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Official Store Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
