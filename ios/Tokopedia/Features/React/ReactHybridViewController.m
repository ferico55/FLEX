//
//  ReactViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactHybridViewController.h"
#import <React/RCTRootView.h>

@interface ReactHybridViewController ()
@end
@implementation ReactHybridViewController

- (id)initWithDelegate:(id<AppNavigationDelegate>)delegate bridge:(RCTBridge *)inBridge viewName:(NSString *)inName viewParams:(NSDictionary *)inParams
{
    self = [super init];
    if (self) {
        navigation = delegate;
        name = inName;
        params = inParams;
        bridge = inBridge;
    }
    return self;
}

- (void)loadView {
    self.navigationItem.title = @"";
    self.view = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"Tokopedia" initialProperties: @{ @"name": name, @"params": params }];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)requestClose:(UIButton*)sender
{
    [self dismissViewControllerAnimated:true completion:^{}];
}

@end
