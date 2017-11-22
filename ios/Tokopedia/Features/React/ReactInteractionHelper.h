//
//  ReactInteractionHelper.h
//  Tokopedia
//
//  Created by Ferico Samuel on 7/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <UIKit/UIKit.h>
#import "FBSDKShareKit.h"

@interface ReactInteractionHelper : NSObject<RCTBridgeModule, FBSDKSharingDelegate>

@property (nonatomic, weak, readonly) RCTBridge *bridge;

@end
