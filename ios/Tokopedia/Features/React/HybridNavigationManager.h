//
//  HybridNavigationManager.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import "AppNavigationDelegate.h"


@interface HybridNavigationManager : NSObject <RCTBridgeModule>

@property (nonatomic, weak, readonly) RCTBridge *bridge;

@end
