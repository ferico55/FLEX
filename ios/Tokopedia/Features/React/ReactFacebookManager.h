//
//  ReactFacebookManager
//  Tokopedia
//
//  Created by Ferico Samuel on 21/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "FBSDKShareKit.h"

@interface ReactFacebookManager : NSObject<RCTBridgeModule, FBSDKSharingDelegate>

@property (nonatomic, weak, readonly) RCTBridge *bridge;

@end
