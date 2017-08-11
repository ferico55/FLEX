//
//  ReactInteractionHelper.h
//  Tokopedia
//
//  Created by Ferico Samuel on 7/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface ReactInteractionHelper : NSObject<RCTBridgeModule>

@property (nonatomic, weak, readonly) RCTBridge *bridge;

@end
