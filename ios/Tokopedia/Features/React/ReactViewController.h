//
//  ReactViewController.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppNavigationDelegate.h"
#import <React/RCTRootView.h>

@interface ReactViewController : UIViewController {
    id<AppNavigationDelegate> navigation;
    NSString* name;
    NSDictionary* params;
    RCTBridge* bridge;
}

- (id)initWithDelegate:(id<AppNavigationDelegate>)delegate bridge:(RCTBridge *)bridge viewName:(NSString *)name viewParams:(NSDictionary *)params;

@end
