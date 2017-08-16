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
#import <React/RCTDevMenu.h>
#import <CodePush/CodePush.h>

@import BlocksKit;

static const NSString *codePushProductionKey = @"ZSvkwYIcHs4uXYNdxM99fYYlMaoX541ce7e1-ab64-41f9-845c-cde8b0ac2964";
static const NSString *codePushStagingKey = @"z6TUWzXBqXFHk-cxMFh8SOjGiXTc541ce7e1-ab64-41f9-845c-cde8b0ac2964";

static NSURL *bundleUrl() {
    typedef NS_ENUM(NSInteger, ReactBundleSource) {
        ReactBundleSourceLocalServer,
        ReactBundleSourceDevice,
        ReactBundleSourceCodePush
    };
    
    NSURL* jsCodeLocation;
    NSString* localhost = FBTweakValue(@"React Native", @"Bundle", @"Local server URL", @"127.0.0.1");
    
    ReactBundleSource source = FBTweakValue(@"React Native", @"Bundle", @"Source", ReactBundleSourceCodePush,
                                            (@{
                                               @(ReactBundleSourceDevice): @"Device (QA use this)",
                                               @(ReactBundleSourceCodePush): @"CodePush (Production)",
                                               @(ReactBundleSourceLocalServer): @"Local Server (Devs use this)"
                                               }));
    
    if (source == ReactBundleSourceCodePush) {
        NSString *deploymentKey = FBTweakValue(
                                               @"React Native",
                                               @"CodePush",
                                               @"Environment",
                                               codePushProductionKey,
                                               (@{
                                                  codePushProductionKey: @"Production",
                                                  codePushStagingKey: @"Staging"
                                                  }));
        
        [CodePush setDeploymentKey:deploymentKey];
        
        jsCodeLocation = [CodePush bundleURL];
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

+ (void)initialize {
    FBTweakAction(@"React Native", @"", @"Show dev tools", ^{
        [UIApplication.sharedApplication.reactBridge.devMenu show];
    });
}

@end
