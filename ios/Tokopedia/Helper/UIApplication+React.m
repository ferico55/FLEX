//
//  UIApplication+React.m
//  Tokopedia
//
//  Created by Samuel Edwin on 5/2/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "UIApplication+React.h"

#import "HybridNavigationManager.h"

#import <React/RCTBridge.h>
#import <AppHub/AppHub.h>

@import BlocksKit;

static NSURL *bundleUrl() {
    typedef NS_ENUM(NSInteger, ReactBundleSource) {
        ReactBundleSourceLocalServer,
        ReactBundleSourceDevice,
        ReactBundleSourceCodePush
    };
    
    NSURL* jsCodeLocation;
    NSString* localhost = FBTweakValue(@"Others", @"React", @"Local server URL", @"127.0.0.1");
    
    ReactBundleSource source = FBTweakValue(@"Others", @"React", @"Source", ReactBundleSourceCodePush,
                                            (@{
                                               @(ReactBundleSourceDevice): @"Device (QA use this)",
                                               @(ReactBundleSourceCodePush): @"CodePush (Production)",
                                               @(ReactBundleSourceLocalServer): @"Local Server (Devs use this)"
                                               }));
    
    if (source == ReactBundleSourceCodePush) {
        AHBuild *build = [[AppHub buildManager] currentBuild];
        jsCodeLocation = [build.bundle URLForResource:@"main"
                                        withExtension:@"jsbundle"];
    } else if (source == ReactBundleSourceLocalServer) {
        jsCodeLocation = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8081/index.ios.bundle?platform=ios", localhost]];
    } else {
        jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
    }
    
    return jsCodeLocation;

}

@implementation UIApplication(React)

- (RCTBridge *)reactBridge {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:bundleUrl()
                                                  moduleProvider:^{
                                                      return @[
                                                               [HybridNavigationManager new]
                                                               ];
                                                  }
                                                   launchOptions:nil];
        
        [[bridge valueForKey:@"devSettings"] setValue:@NO forKey:@"isShakeToShowDevMenuEnabled"];
        
        [self bk_associateValue:bridge withKey:"reactBridge"];
    });
    
    return [self bk_associatedValueForKey:"reactBridge"];
}

@end
