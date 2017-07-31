//
//  ReactUserManager.h
//  Tokopedia
//
//  Created by Tonito Acen on 7/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface ReactUserManager : NSObject<RCTBridgeModule>

- (id)initWithBridge:(RCTBridge *)bridge;

@end
