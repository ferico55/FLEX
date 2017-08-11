//
//  TKPReactURLManager.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "AppNavigationDelegate.h"

@interface TKPReactURLManager : NSObject<RCTBridgeModule>

- (id)initWithBridge:(RCTBridge*)bridge;

@end
